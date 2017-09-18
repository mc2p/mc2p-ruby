module MC2P

  # MC2P Error - class used to manage the exceptions related with mc2p library
  class MC2PError < StandardError
    attr_accessor :json_body
    attr_accessor :resource
    attr_accessor :resource_id

    # Initializes an error
    # Params:
    # +message+:: Error type
    # +json_body+:: Response from server
    # +resource+:: Class resource used when the error raised
    # +resource_id+:: Resource id requested when the error raised
    def initialize(message=nil, json_body=nil, resource=nil, resource_id=nil)
      super(message)

      @_message = message
      @json_body = json_body
      @resource = resource
      @resource_id = resource_id
    end

    # Returns: Error type and response
    def to_s
      "#{@_message} #{@json_body}"
    end
  end

  # Invalid request error
  class InvalidRequestError < MC2PError

  end


  # Bad use error
  class BadUseError < MC2PError

  end

end
