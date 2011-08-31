module Telesocial
  class Error < StandardError
    attr_reader :response

    def initialize(message, response)
      @response = response
      super(info(message, response))
    end

    def info(text = '', env = Hashie::Mash.new)
      "#{text} - (server message: #{env.message})"
    end
  end

  class NotFound < Error; end;
  class Unauthorized < Error; end;
  class BadRequest < Error; end;
  class BadGateway < Error; end;
  class RequestEntityTooLarge < Error; end;
  class UnsupportedMediaTpe < Error; end;

end

