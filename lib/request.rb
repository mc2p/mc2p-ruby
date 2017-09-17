require "unirest"
require "errors"


class APIRequest
    """
    API request - class used to connect with the API
    """
    AUTHORIZATION_HEADER = "AppKeys"
    API_URL = "api.mychoice2pay.com/v1"

    attr_accessor :post
    attr_accessor :post_200
    attr_accessor :get
    attr_accessor :patch
    attr_accessor :delete

    def initialize(key, secret_key):
        """
        Initializes an api request
        :param key: key to connect with API
        :param secret_key: secret key to connect with API
        """
        @key = key
        @secret_key = secret_key

        @post = self._request('POST', 201)
        @post_200 = self._request('POST', 200)
        @get = self._request('GET')
        @patch = self._request('PATCH')
        @delete = self._request('DELETE', 204)
    end

    def headers
        """
        Creates the headers to include in the request
        :return: A dictionary with the headers needed for the API
        """
        {
            "authorization" => "#{@AUTHORIZATION_HEADER} #{@key}:#{@secret_key}",
            "content-type": "application/json"
        }
    end

    def get_abs_url(self, path):
        """
        :param path: relative url
        :return: The absolute url to send the request
        """
        "https://#{@API_URL}#{path}"
    end

    def _request(self, method, status_code=200):
        """
        Decorator to make the request based on the method received
        :param method: method to make the request
        :param status_code: value to check if the request receive a correct response
        :return: a function to make the request
        """
        def func(path=nil, data=nil, abs_url=nil, resource=nil, resource_id=nil):
            if abs_url
                url = abs_url
            else
                url = self.get_abs_url(path)

            request = Unirest.send(method.downcase)(url,
                headers:self.headers,
                parameters:data)

            if request.code != status_code
                raise InvalidRequestError.new(
                    'Error %s' % request.code,
                    json_body:request.to_json,
                    resource:resource,
                    resource_id:resource_id
                )

            ret = {}
            if status_code != 204
                ret = request.to_json
            ret
        end
        func
    end
end
