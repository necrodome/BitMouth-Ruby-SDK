module BitMouth
  class Error < StandardError
    attr_reader :response

    def initialize(message, response)
      @response = response
      super(message)
    end
  end

  class NotFound < Error; end
  class Unauthorized < Error; end
  class BadRequest < Error; end;

end

