require 'httparty'
require 'hashie'

module BitMouth
  class Client
    include HTTParty
    base_uri 'https://api4.bitmouth.com/api/rest'
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
      options = {:query => query, :appkey => @api_key}
      response = self.class.get("/registrant/#{network_id}", :query => options).parsed_response

      case response.status
      when 200
        response.registered = true
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      else
        raise BitMouth::Error.new(response.message, response)
      end

      return response
    end

    def register(network_id, phone)
      response = self.class.post("/registrant/", :body => {:networkid => network_id, :phone => phone, :appkey => @api_key}).parsed_response

      case response.status
      when 201
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      else
        raise BitMouth::Error.new(response.message, response)
      end

      response
    end

    def create_conference(*args)
      if args.last.is_a? Hash
        options = args.pop
      end

      record = false
      if options
        record = options[:record]
      end

      response = self.class.post("/call/", :body => {:networkid => args, :appkey => @api_key, :record => record}).parsed_response

      case response.status
      when 201
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      else
        raise BitMouth::Error.new(response.message, response)
      end

      response

    end

    def create_media(network_id)
      response = self.class.post("/media/", :body => {:networkid => network_id, :appkey => @api_key, :action => "create"}).parsed_response

      case response.status
      when 201
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      end

      response
    end

    def record(network_id, media_id)
      response = self.class.post("/media/#{media_id}",:body => {:networkid => network_id, :appkey => @api_key, :action => "record"}).parsed_response

      case response.status
      when 201
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response

    end

    def blast(network_id, media_id)
      response = self.class.post("/media/#{media_id}",:body => {:networkid => network_id, :appkey => @api_key, :action => "blast"}).parsed_response

      case response.status
      when 200,201,202
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def media_status(media_id)
      response = self.class.get("/media/#{media_id}", :query => {:appkey => @api_key}).parsed_response

      case response.status
      when 200,201,202
      when 204
        raise BitMouth::NoContent.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      end

      response
    end

    def add_to_conference(network_id, conference_id)
      response = self.class.post("/conference/#{conference_id}", :body => {:networkid => network_id, :appkey => @api_key}).parsed_response

      case response.status
      when 200,201,202
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response

    end

    def upload_grant_request(media_id)
      response = self.class.post("/media/#{media_id}",:body => {:appkey => @api_key, :action => "upload_grant"}).parsed_response

      case response.status
      when 201,202
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      end

      response
    end

    def remove_media(media_id)
      response = self.class.delete("/media/#{media_id}",:body => {:appkey => @api_key, :action => "upload_grant"}).parsed_response

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      end

      response
    end

    def close_conference(conference_id)
      response = self.class.post("/#{conference_id}/close", :body => {:appkey => @api_key}).parsed_response

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def hangup_call(conference_id, network_id)
      response = self.class.post("/conference/#{conference_id}#{network_id}/hangup", :body => {:appkey => @api_key}).parsed_response

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def move_call(network_id, from, to)
      response = self.class.post("/conference/#{from}/#{to}/#{network_id}/move", :body => {:appkey => @api_key}).parsed_response

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 404
        raise BitMouth::NotFound.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def mute(network_id, conference_id)
      response = self.class.post("/conference/#{conference_id}", :body => {:app_key => @api_key, :conferenceid => conference_id, :networkid => network_id, :action => "mute"})

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def unmute()
      response = self.class.post("/conference/#{conference_id}", :body => {:app_key => @api_key, :conferenceid => conference_id, :networkid => network_id, :action => "unmute"})

      case response.status
      when 200
      when 400
        raise BitMouth::BadRequest.new(response.message, response)
      when 401
        raise BitMouth::Unauthorized.new(response.message, response)
      when 502
        raise BitMouth::BadGateway.new(response.message, response)
      end

      response
    end

    def get_version
      response = self.class.get("/version").parsed_response
    end


    # Handling for general errors
    # Specifically, BitMouth API returns 500 wh
    private
    def post(url, options = {})
      response = self.class.post(url, :query => options[:query], :body => options[:body])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise BitMouth::Error.new("Internal Server Error", response)
      end

      parsed_response
    end

     def get(url, options = {})
      response = self.class.get(url, :query => options[:query])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise BitMouth::Error.new("Internal Server Error", response)
      end

      parsed_response
    end

    def delete(url, options = {})
      response = self.class.delete(url, :query => options[:query], :body => options[:body])
      parsed_response = response.parsed_response

      case response.code
      when 500
        raise BitMouth::Error.new("Internal Server Error", response)
      end

      parsed_response
    end



  end
end

