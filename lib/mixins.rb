module MC2P

  # Basic info of the object item
  class ObjectItemMixin
    @@id_property = 'id'
    attr_accessor :json_dict
    attr_accessor :resource
    attr_accessor :_deleted

    def initialize(json_dict, resource)
      @json_dict = json_dict
      @resource = resource
      @_deleted = nil
    end

    def id_required_and_not_deleted
      if not @json_dict.fetch(@@id_property, false)
        raise BadUseError('Object don\'t have ID')
      end
      if @_deleted
        raise BadUseError('Object deleted')
      end
    end

    # Returns: Name of the object and content
    def to_s
      "%s #{@json_dict}" % self.class.name
    end
  end

  # Allows delete an object item
  class DeleteObjectItemMixin < ObjectItemMixin
    # Deletes the object item
    def delete
      id_required_and_not_deleted
      @resource.delete(
        @json_dict[@@id_property]
      )
      @_deleted = true
    end
  end

  # Allows retrieve an object item
  class RetrieveObjectItemMixin < ObjectItemMixin
    # Retrieves the data of the object item
    def retrieve
      id_required_and_not_deleted
      obj = @resource.detail(
        @json_dict[@@id_property]
      )
      @json_dict = obj.json_dict
    end
  end

  # Allows create an object item
  class CreateObjectItemMixin < ObjectItemMixin
    # Creates the object item with the json_dict data
    def _create
      obj = @resource.create(
        @json_dict
      )
      @json_dict = obj.json_dict
    end

    # Executes the internal function _create if the object item don't have id
    def save
      if not @json_dict.fetch(@@id_property, false)
        _create
      end
    end
  end

  # Allows change an object item
  class SaveObjectItemMixin < CreateObjectItemMixin
    # Changes the object item with the json_dict data
    def _change
      id_required_and_not_deleted
      obj = @resource.change(
        @json_dict[@@id_property],
        @json_dict
      )
      @json_dict = obj.json_dict
    end

    # Executes the internal function _create if the object item don't have id,
    # in other case, call to _change
    def save
      if @json_dict.fetch(@@id_property, false)
        _change
      else
        _create
      end
    end
  end

  # Allows make refund, capture and void an object item
  class RefundCaptureVoidObjectItemMixin < ObjectItemMixin
    # Refund the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def refund(data = nil)
      id_required_and_not_deleted
      @resource.refund(
        @json_dict[@@id_property],
        data
      )
    end

    # Capture the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def capture(data = nil)
      id_required_and_not_deleted
      @resource.capture(
        @json_dict[@@id_property],
        data
      )
    end

    # Void the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def void(data = nil)
      id_required_and_not_deleted
      @resource.void(
        @json_dict[@@id_property],
        data
      )
    end
  end

  # Allows make card and share an object item
  class CardShareObjectItemMixin < ObjectItemMixin
    # Send card details
    # Params:
    # +gateway_code+:: gateway_code to send
    # +data+:: data to send
    # Returns: response dictionary
    def card(gateway_code, data = nil)
      id_required_and_not_deleted
      @resource.card(
        @json_dict[@@id_property],
        gateway_code,
        data
      )
    end

    # Send share details
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def share(data = nil)
      id_required_and_not_deleted
      @resource.share(
        @json_dict[@@id_property],
        data
      )
    end
  end

  # Add property to get pay_url based on token
  class PayURLMixin < ObjectItemMixin
    def initialize(json_dict, resource)
      super(json_dict, resource)
      @pay_url = 'https://pay.mychoice2pay.com/#/%s'
      @iframe_url = 'https://pay.mychoice2pay.com/#/%s/iframe'
    end

    # Returns: pay url
    def pay_url
      id_required_and_not_deleted
      @pay_url % @json_dict['token']
    end

    # Returns: iframe url
    def iframe_url
      id_required_and_not_deleted
      @iframe_url % @json_dict['token']
    end
  end

  # Basic info of the resource
  class ResourceMixin
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    # +paginator_class+:: Paginator class used to return values
    def initialize(api_request, path, object_item_class, paginator_class)
      @api_request = api_request
      @path = path
      @object_item_class = object_item_class
      @paginator_class = paginator_class
    end

    # Params:
    # +resource_id+:: id used on the url returned
    # Returns: url to request or change an item
    def detail_url(resource_id)
      "#{@path}#{resource_id}/"
    end

    # Help function to make a request that return one item
    # Params:
    # +func+:: function to make the request
    # +data+:: data passed in the request
    # +resource_id+:: id to use on the requested url
    # Returns: an object item that represent the item returned
    def _one_item(func, data = nil, resource_id = nil)
      url = resource_id.nil? ? @path : detail_url(resource_id)

      obj_data = @api_request.send(
        func,
        url,
        data,
        nil,
        self,
        resource_id
      )

      @object_item_class.new(obj_data, self)
    end
  end

  # Allows send requests of detail
  class DetailOnlyResourceMixin < ResourceMixin
    # Params:
    # +resource_id+:: id to request
    # Returns: an object item class with the response of the server
    def detail(resource_id)
      _one_item('get',
                resource_id: resource_id)
    end
  end

  # Allows send requests of list and detail
  class ReadOnlyResourceMixin < DetailOnlyResourceMixin
    # Params:
    # +abs_url+:: if is passed the request is sent to this url
    # Returns: a paginator class with the response of the server
    def list(abs_url = nil)
      json_dict = @api_request.get(
        abs_url.nil? ? @path : nil,
        nil,
        abs_url,
        self
      )

      @paginator_class.new(
        json_dict,
        @object_item_class,
        self
      )
    end
  end

  # Allows send requests of create
  class CreateResourceMixin < ResourceMixin
    # Params:
    # +data+:: data used on the request
    # Returns: an object item class with the response of the server
    def create(data)
      _one_item('post',
                data)
    end
  end

  # Allows send requests of change
  class ChangeResourceMixin < ResourceMixin
    # Params:
    # +resource_id+:: id to request
    # +data+:: data used on the request
    # Returns: an object item class with the response of the server
    def change(resource_id, data)
      _one_item('patch',
                data,
                resource_id)
    end
  end

  # Allows send requests of delete
  class DeleteResourceMixin < ResourceMixin
    # Params:
    # +resource_id+::id to request
    def delete(resource_id)
      _one_item('delete',
                nil,
                resource_id)
    end
  end

  # Allows send requests of actions
  class ActionsResourceMixin < ResourceMixin
    # Params:
    # +resource_id+:: id used on the url returned
    # +action+:: action used on the url returned
    # Returns: url to make an action in an item
    def detail_action_url(resource_id, action)
      "#{@path}#{resource_id}/#{action}/"
    end

    # Params:
    # +func+:: function to make the request
    # +resource_id+:: id to use on the requested url
    # +action+:: action to use on the requested url
    # +data+:: data passed in the request
    # Returns: response dictionary
    def _one_item_action(func, resource_id, action, data = nil)
      url = detail_action_url(resource_id, action)
      @api_request.send(
        func,
        url,
        data,
        nil,
        self,
        resource_id
      )
    end
  end

  # Allows send action requests of refund, capture and void
  class RefundCaptureVoidResourceMixin < ActionsResourceMixin
    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def refund(resource_id, data = nil)
      _one_item_action('post200',
                       resource_id,
                       'refund',
                       data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def capture(resource_id, data = nil)
      _one_item_action('post200',
                       resource_id,
                       'capture',
                       data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def void(resource_id, data = nil)
      _one_item_action('post200',
                       resource_id,
                       'void',
                       data)
    end
  end

  # Allows send action requests of card and share
  class CardShareResourceMixin < ActionsResourceMixin
    # Params:
    # +resource_id+:: id to request
    # +gateway_code+:: gateway_code to send
    # +data+:: data to send
    # Returns: response dictionary
    def card(resource_id, gateway_code, data = nil)
      _one_item_action('post',
                       resource_id,
                       "card/#{gateway_code}",
                       data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def share(resource_id, data = nil)
      _one_item_action('post',
                       resource_id,
                       'share',
                       data)
    end
  end
end
