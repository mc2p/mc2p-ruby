class MC2PError < Exception
    """
    MC2P Error - class used to manage the exceptions related with mc2p library
    """
    attr_accessor :json_body
    attr_accessor :resource
    attr_accessor :resource_id

    def initialize(message=None, json_body=None, resource=None, resource_id=None):
        """
        Initializes an error
        :param message: Error type
        :param json_body: Response from server
        :param resource: Class resource used when the error raised
        :param resource_id: Resource id requested when the error raised
        """
        super(message)

        @_message = message
        @json_body = json_body
        @resource = resource
        @resource_id = resource_id
    end

    def to_s
        """
        :return: Error type and response
        """
        return "#{@_message} #{@json_body}"
    end
end


class InvalidRequestError < MC2PError
    """
    Invalid request error
    """
end


class BadUseError < MC2PError
    """
    Bad use error
    """
end
