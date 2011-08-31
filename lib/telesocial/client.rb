require 'httparty'
require 'hashie'

module Telesocial
  class Client
    include HTTParty
    base_uri 'https://api4.bitmouth.com'
    debug_output $stderr
    disable_rails_query_string_format

    class ResponseParser < HTTParty::Parser
      def parse
        begin
          Hashie::Mash.new(Crack::JSON.parse(body).values.first)
        rescue
          body
        end
      end
    end
    parser ResponseParser

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def get_registration_status(network_id, query = "exists")

      response = post("/api/rest/registrant/#{network_id}", :body => {:query => query, :appkey => @api_key})

      case response.status
      when 200
        response.registered = true
      when 401
        raise Telesocial::Unauthorized.new("The network ID exists but it is not associated with the specified application", response)
      when 404
        raise Telesocial::NotFound.new("The device is not registered.", response)
      else
        raise Telesocial::Error.new(response.message, response)
      end

      return response
    end

    def register(network_id, phone, greeting_id = nil)
      response = post("/api/rest/registrant/", :body => {:networkid => network_id, :phone => phone, :appkey => @api_key, :greetingid => greeting_id})

      case response.status
      when 201
      when 400
        raise Telesocial::BadRequest.new("One or more parameters were invalid or this (phone, networkid) pair is already registered.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to start the phone authorization process.", response)
      else
        raise Telesocial::Error.new(response.message, response)
      end

      response
    end

    def create_media(network_id)
      response = post("/api/rest/media/", :body => {:networkid => network_id, :appkey => @api_key, :action => "create"})

      case response.status
      when 201
      when 400
        raise Telesocial::BadRequest.new("Missing parameter(s)", response)
      when 404
        raise Telesocial::NotFound.new("The application key is invalid.", response)
      end

      response
    end

    def record(network_id, media_id)
      response = post("/api/rest/media/#{media_id}",:body => {:networkid => network_id, :appkey => @api_key, :action => "record"})

      case response.status
      when 201
      when 400
        raise Telesocial::BadRequest.new("Missing parameter(s).", response)
      when 404
        raise Telesocial::NotFound.new("The application key is invalid or the application is not associated with the networkid.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to initiate phone call at this time.", response)
      end

      response

    end

    def blast(network_id, media_id)
      response = post("/api/rest/media/#{media_id}",:body => {:networkid => network_id, :appkey => @api_key, :action => "blast"})

      case response.status
      when 200,201,202
      when 400
        raise Telesocial::BadRequest.new("Missing parameter(s).", response)
      when 404
        raise Telesocial::NotFound.new("The application key is invalid or the application is not associated with the networkid.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to initiate phone call at this time.", response)
      end

      response
    end

    def request_upload_grant(media_id)
      response = post("/api/rest/media/#{media_id}",:body => {:appkey => @api_key, :action => "upload_grant"})

      case response.status
      when 201,202
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("The media ID is invalid or is not associated with the application identified by the appkey parameter.", response)
      end

      response
    end

    def media_status(media_id)
      response = get("/api/rest/media/status/#{media_id}", :query => {:appkey => @api_key})

      case response.status
      when 200,201,202
      when 204
        raise Telesocial::NoContent.new("No media content exists for this Media ID.", response)
      when 404
        raise Telesocial::NotFound.new("The application key or networkid are invalid.", response)
      end

      response
    end

    def remove_media(media_id)
      response = delete("/api/rest/media/#{media_id}",:body => {:appkey => @api_key, :action => "remove"})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("The content associated with the media ID cannot be removed.", response)
      when 404
        raise Telesocial::NotFound.new("The media ID is invalid.", response)
      end

      response
    end

    def create_conference(network_id, recording_id = nil, greeting_id = nil)

      options = {}
      options[:recordingid] = recording_id if recording_id
      options[:greetingid]  = greeting_id if greeting_id

      response = post("/api/rest/conference/", :body => {:networkid => args, :appkey => @api_key}.merge(options))

      case response.status
      when 201
      when 502
        raise Telesocial::BadGateway.new("The request cannot be fulfilled at this time.", response)
      else
        raise Telesocial::Error.new("The request cannot be fulfilled at this time.", response)
      end

      response

    end

    def add_to_conference(conference_id, network_id)
      response = post("/api/rest/conference/#{conference_id}", :body => {:networkid => network_id, :appkey => @api_key, :action => 'add'})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to initiate phone(s) call at this time.", response)
      end

      response

    end

    def close_conference(conference_id)
      response = post("/api/rest/conference//#{conference_id}", :body => {:appkey => @api_key, :action => 'close'})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 404
        raise Telesocial::NotFound.new("The conference ID is invalid.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to terminate conference calls.", response)
      end

      response
    end

    def hangup_call(conference_id, network_id)
      response = post("/api/rest/conference/#{conference_id}/#{network_id}", :body => {:appkey => @api_key, :action => 'hangup'})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("The specified network ID is not associated with the application identified by the application key.", response)
      when 404
        raise Telesocial::NotFound.new("The conference ID is invalid.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to terminate call at this time.", response)
      end

      response
    end

    def move_call(from_conference_id, to_conference_id, network_id)
      response = post("/api/rest/conference/#{from_conference_id}/#{network_id}", :body => {:appkey => @api_key, :toconferenceid => to_conference_id, :action => 'move'})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("The specified network ID is not associated with the application identified by the application key.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to move call.", response)
      end

      response
    end

    def mute(conference_id, network_id)
      response = post("/api/rest/conference/#{conference_id}/#{network_id}", :body => {:app_key => @api_key, :action => "mute"})

      case response.status
      when 200
      when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("One or more of the specified network IDs is not associated with the application identified by the application key.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to mute call(s).", response)
      end

      response
    end

    def unmute(conference_id, network_id)
      response = self.class.post("/api/rest/conference/#{conference_id}/#{network_id}", :body => {:app_key => @api_key, :action => "unmute"})

      case response.status
      when 200
       when 400
        raise Telesocial::BadRequest.new("Missing or invalid parameter(s).", response)
      when 401
        raise Telesocial::Unauthorized.new("One or more of the specified network IDs is not associated with the application identified by the application key.", response)
      when 502
        raise Telesocial::BadGateway.new("Unable to unmute call(s).", response)
      end

      response
    end

    def get_version
      response = self.class.get("/api/rest/version").parsed_response
    end


    # Handling for general errors
    # Specifically, Telesocial API returns 500 wh
    private
    def post(url, options = {})
      response = self.class.post(url, :query => options[:query], :body => options[:body])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise Telesocial::Error.new("Internal Server Error", response)
      end

      parsed_response
    end

     def get(url, options = {})
      response = self.class.get(url, :query => options[:query])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise Telesocial::Error.new("Internal Server Error", response)
      end

      parsed_response
    end

    def delete(url, options = {})
      response = self.class.delete(url, :query => options[:query], :body => options[:body])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise Telesocial::Error.new("Internal Server Error", response)
      end

      parsed_response
    end



  end
end

