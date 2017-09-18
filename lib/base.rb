module MC2P
  # Paginator - class used on list requests
  class Paginator
    attr_accessor :count
    attr_accessor :results

    # Initializes a paginator
    # Params:
    # +json_dict+:: Response from server
    # +object_item_class+:: Class to wrapper all the items from results field
    # +resource+:: Resource used to get next and previous items
    def initialize(json_dict, object_item_class, resource)
      @count = json_dict.fetch('count', 0)
      @_previous = json_dict.fetch('previous', nil)
      @_next = json_dict.fetch('next', nil)
      @results = []
      json_dict.fetch('results', []).each do |result|
        @results.push(object_item_class.new(result, resource))
        @resource = resource
      end
    end

    # Params:
    # Returns: Paginator object with the next items
    def next_list
      @_next ? @resource.list(abs_url: @_next) : nil
    end

    # Params:
    # Returns: Paginator object with the previous items
    def previous_list
      @_previous ? @resource.list(abs_url: @_previous) : nil
    end
  end

  # Object item - class used to wrap the data from API that represent an item
  class ObjectItem < ObjectItemMixin
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @json_dict = json_dict.nil? ? {} : json_dict
      @resource = resource
      @_deleted = false
      @id_property = 'id'
    end

    # Allows use the following syntax to get a field of the object:
    #     obj.name
    # Params:
    # +key+:: Field to return
    # Returns: Value of the field from json_dict
    def method_missing(key, *args)
      @json_dict.include?(key.to_s) ? @json_dict[key.to_s] : super
    end

    def respond_to_missing?(key, include_private = false)
      @json_dict.include?(key.to_s) || super
    end

    def respond_to?(key, include_private = false)
      @json_dict.include?(key.to_s) || super
    end

    # Allows use the following syntax to set a field of the object:
    #     obj.name = 'example'
    # Params:
    # +key+:: Field to change
    # +value+:: Content to replace the current value
    def set(key, value)
      @json_dict[key] = value
    end
  end

  # Object item that allows retrieve an item
  class ReadOnlyObjectItem < ObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @retrieve_mixin = RetrieveObjectItemMixin.new(json_dict, resource)
      super(json_dict, resource)
    end

    # Retrieve object with object_id and return
    # Params:
    # +object_id+:: Id to retrieve
    # Returns: Object after retrieve
    def self.get(object_id)
      obj = new({
                  @id_property => object_id
                }, resource)
      obj.retrieve
      obj
    end

    # Retrieves the data of the object item
    def retrieve
      @retrieve_mixin.json_dict = @json_dict
      @retrieve_mixin._deleted = @_deleted
      @retrieve_mixin.retrieve
      @json_dict = @retrieve_mixin.json_dict
    end
  end

  # Object item that allows retrieve and create an item
  class CRObjectItem < ReadOnlyObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @create_mixin = CreateObjectItemMixin.new(json_dict, resource)
      super(json_dict, resource)
    end

    # Creates the object item with the json_dict data
    def _create
      @create_mixin.json_dict = @json_dict
      @create_mixin._deleted = @_deleted
      @create_mixin._create
      @json_dict = @create_mixin.json_dict
    end

    # Executes the internal function _create if the object item don't have id
    def save
      @create_mixin.json_dict = @json_dict
      @create_mixin._deleted = @_deleted
      @create_mixin.save
      @json_dict = @create_mixin.json_dict
    end
  end

  # Object item that allows retrieve, create and change an item
  class CRUObjectItem < ReadOnlyObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @save_mixin = SaveObjectItemMixin.new(json_dict, resource)
      super(json_dict, resource)
    end

    # Creates the object item with the json_dict data
    def _create
      @save_mixin.json_dict = @json_dict
      @save_mixin._deleted = @_deleted
      @save_mixin._create
      @json_dict = @save_mixin.json_dict
    end

    # Creates the object item with the json_dict data
    def _change
      @save_mixin.json_dict = @json_dict
      @save_mixin._deleted = @_deleted
      @save_mixin._change
      @json_dict = @save_mixin.json_dict
    end

    # Executes the internal function _create if the object item don't have id
    def save
      @save_mixin.json_dict = @json_dict
      @save_mixin._deleted = @_deleted
      @save_mixin.save
      @json_dict = @save_mixin.json_dict
    end
  end

  # Object item that allows retrieve, create, change and delete an item
  class CRUDObjectItem < CRUObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @delete_mixin = DeleteObjectItemMixin.new(json_dict, resource)
      super(json_dict, resource)
    end

    # Deletes the object item
    def delete
      @delete_mixin.json_dict = @json_dict
      @delete_mixin._deleted = @_deleted
      @delete_mixin.delete
      @json_dict = @delete_mixin.json_dict
      @_deleted = @delete_mixin._deleted
    end
  end

  # Object item that allows retrieve, create and to get pay_url based
  # on token of an item
  class PayURLCRObjectItem < CRObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      @pay_url_mixin = PayURLMixin.new(json_dict, resource)
      super(json_dict, resource)
    end

    # Returns: pay_url
    def pay_url
      @pay_url_mixin.json_dict = @json_dict
      @pay_url_mixin.pay_url
    end

    # Returns: iframe_url
    def iframe_url
      @pay_url_mixin.json_dict = @json_dict
      @pay_url_mixin.iframe_url
    end
  end

  # Resource - class used to manage the requests to the API related with
  # a resource
  # ex: product
  class Resource < ResourceMixin
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      @paginator_class = Paginator
      super(api_request, path, object_item_class, @paginator_class)
    end
  end

  # Resource that allows send requests of detail
  class DetailOnlyResource < Resource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @do_resource_mixin = DetailOnlyResourceMixin.new(api_request, path,
                                                       object_item_class,
                                                       @paginator_class)
    end

    # Params:
    # +resource_id+:: id to request
    # Returns: an object item class with the response of the server
    def detail(resource_id)
      @do_resource_mixin.detail(resource_id)
    end
  end

  # Resource that allows send requests of list and detail
  class ReadOnlyResource < DetailOnlyResource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @ro_resource_mixin = ReadOnlyResourceMixin.new(api_request, path,
                                                     object_item_class,
                                                     @paginator_class)
    end

    # Params:
    # +abs_url+:: if is passed the request is sent to this url
    # Returns: a paginator class with the response of the server
    def list(abs_url = nil)
      @ro_resource_mixin.list(abs_url)
    end
  end

  # Resource that allows send requests of create, list and detail
  class CRResource < ReadOnlyResource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @create_resource_mixin = CreateResourceMixin.new(api_request, path,
                                                       object_item_class,
                                                       @paginator_class)
    end

    # Params:
    # +data+:: data used on the request
    # Returns: an object item class with the response of the server
    def create(data)
      @create_resource_mixin.create(data)
    end
  end

  # Resource that allows send requests of delete, change, create,
  # list and detail
  class CRUDResource < CRResource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @change_resource_mixin = ChangeResourceMixin.new(api_request, path,
                                                       object_item_class,
                                                       @paginator_class)
      @delete_resource_mixin = DeleteResourceMixin.new(api_request, path,
                                                       object_item_class,
                                                       @paginator_class)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data used on the request
    # Returns: an object item class with the response of the server
    def change(resource_id, data)
      @change_resource_mixin.change(resource_id, data)
    end

    # Params:
    # +resource_id+::id to request
    def delete(resource_id)
      @delete_resource_mixin.delete(resource_id)
    end
  end
end
