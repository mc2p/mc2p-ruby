module MC2P

  # API request - class used to connect with the API
  class APIRequest
    @authorization_header = 'AppKeys'
    @api_url = 'api.mychoice2pay.com/v1'

    # Initializes an api request
    # Params:
    # +key+:: key to connect with API
    # +secret_key+:: secret key to connect with API
    def initialize(key, secret_key)
      @key = key
      @secret_key = secret_key
    end

    # Creates the headers to include in the request
    # Returns: A dictionary with the headers needed for the API
    def headers
      {
        'authorization' => "#{@authorization_header} #{@key}:#{@secret_key}",
        'content-type' => 'application/json'
      }
    end

    # Params:
    # +path+:: relative url
    # Returns: The absolute url to send the request
    def get_abs_url(path)
      "https://#{@api_url}#{path}"
    end

    # Decorator to make the request based on the method received
    # Params:
    # +method+:: method to make the request
    # +status_code+:: value to check if the request receive a correct response
    # Returns: a function to make the request
    def _request(method, status_code=200, path=nil, data=nil,
                 abs_url=nil, resource=nil, resource_id=nil)
      url = abs_url.nil? ? get_abs_url(path) : abs_url

      request = Unirest.send(method.downcase, url,
                             headers: headers,
                             parameters: data)

      if request.code != status_code
        raise InvalidRequestError.new(
          "Error #{request.code}",
          json_body: request.to_json,
          resource: resource,
          resource_id: resource_id
        )
      end

      status_code != 204 ? request.to_json : {}
    end

    # POST 201 function
    def post(path = nil, data = nil, abs_url = nil,
             resource = nil, resource_id = nil)
      _request('post', 201, path, data, abs_url, resource, resource_id)
    end

    # POST 200 function
    def post200(path = nil, data = nil, abs_url = nil,
                resource = nil, resource_id = nil)
      _request('post', 200, path, data, abs_url, resource, resource_id)
    end

    # GET 200 function
    def get(path = nil, data = nil, abs_url = nil,
            resource = nil, resource_id = nil)
      _request('get', 200, path, data, abs_url, resource, resource_id)
    end

    # PATCH 200 function
    def patch(path = nil, data = nil, abs_url = nil,
              resource = nil, resource_id = nil)
      _request('patch', 200, path, data, abs_url, resource, resource_id)
    end

    # DELETE 204 function
    def delete(path = nil, data = nil, abs_url = nil,
               resource = nil, resource_id = nil)
      _request('delete', 204, path, data, abs_url, resource, resource_id)
    end
  end

end
