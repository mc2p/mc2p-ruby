require "mixin"


class Paginator
    """
    Paginator - class used on list requests
    """
    attr_accessor :count
    attr_accessor :results

    def initialize(json_dict, object_item_class, resource)
        """
        Initializes a paginator
        :param json_dict: Response from server
        :param object_item_class: Class to wrapper all the items from results field
        :param resource: Resource used to get next and previous items
        """
        @count = json_dict.fetch("count", 0)
        @_previous = json_dict.fetch("previous", nil)
        @_next = json_dict.fetch("next", nil)
        @results = []
        json_dict.fetch("results", []).each do |result|
            @results.push(object_item_class.new(result, resource))
        @resource = resource
    end

    def get_next_list
        """
        :return: Paginator object with the next items
        """
        ret = nil
        if @_next
            ret = @resource.list(abs_url:@_next)
        ret
    end

    def get_previous_list
        """
        :return: Paginator object with the previous items
        """
        ret = nil
        if @_previous
            ret = @resource.list(abs_url:self._previous)
        ret
    end
end


class ObjectItem < ObjectItemMixin
    """
    Object item - class used to wrap the data from API that represent an item
    """
    def initialize(json_dict, resource)
        """
        Initializes an object item
        :param json_dict: Data of the object
        :param resource: Resource used to delete, save, create or retrieve the object
        """
        if json_dict.nil?
            json_dict = {}
        @json_dict = json_dict

        @resource = resource

        @_deleted = False
    end

    def method_missing(name, *args)
        """
        Allows use the following syntax to get a field of the object:
          obj.name
        :param key: Field to return
        :return: Value of the field from json_dict
        """
        @json_dict[key]
    end

    def set(key, value)
        """
        Allows use the following syntax to set a field of the object:
          obj.name = 'example'
        :param key: Field to change
        :param value: Content to replace the current value
        """
        @json_dict[key] = value
    end
end


class ReadOnlyObjectItem < ObjectItem
    """
    Object item that allows retrieve an item
    """
    def initialize(json_dict, resource)
        @retrieve_mixin = RetrieveObjectItemMixin.new(json_dict, resource)
        super(json_dict, resource)
    end

    def self.get(object_id)
        """
        Retrieve object with object_id and return
        :param object_id: Id to retrieve
        :return: Object after retrieve
        """
        obj = self.new({
            self.ID_PROPERTY => object_id
        }, self.resource)
        obj.retrieve()
        obj
    end

    def retrieve
        """
        Retrieves the data of the object item
        """
        @retrieve_mixin.json_dict = @json_dict
        @retrieve_mixin._deleted = @_deleted
        @retrieve_mixin.retrieve
        @json_dict = @retrieve_mixin.json_dict
    end
end


class CRObjectItem < ReadOnlyObjectItem
    """
    Object item that allows retrieve and create an item
    """
    def initialize(json_dict, resource)
        @create_mixin = CreateObjectItemMixin.new(json_dict, resource)
        super(json_dict, resource)
    end

    def _create
        """
        Creates the object item with the json_dict data
        """
        @create_mixin.json_dict = @json_dict
        @create_mixin._deleted = @_deleted
        @create_mixin._create
        @json_dict = @create_mixin.json_dict
    end

    def save
        """
        Executes the internal function _create if the object item don't have id
        """
        @create_mixin.json_dict = @json_dict
        @create_mixin._deleted = @_deleted
        @create_mixin.save
        @json_dict = @create_mixin.json_dict
    end
end


class CRUObjectItem < ReadOnlyObjectItem
    """
    Object item that allows retrieve, create and change an item
    """
    def initialize(json_dict, resource)
        @save_mixin = SaveObjectItemMixin.new(json_dict, resource)
        super(json_dict, resource)
    end

    def _create
        """
        Creates the object item with the json_dict data
        """
        @save_mixin.json_dict = @json_dict
        @save_mixin._deleted = @_deleted
        @save_mixin._create
        @json_dict = @save_mixin.json_dict
    end

    def _change
        """
        Creates the object item with the json_dict data
        """
        @save_mixin.json_dict = @json_dict
        @save_mixin._deleted = @_deleted
        @save_mixin._change
        @json_dict = @save_mixin.json_dict
    end

    def save
        """
        Executes the internal function _create if the object item don't have id
        """
        @save_mixin.json_dict = @json_dict
        @save_mixin._deleted = @_deleted
        @save_mixin.save
        @json_dict = @save_mixin.json_dict
    end
end


class CRUDObjectItem < CRUObjectItem
    """
    Object item that allows retrieve, create, change and delete an item
    """
    def initialize(json_dict, resource)
        @delete_mixin = DeleteObjectItemMixin.new(json_dict, resource)
        super(json_dict, resource)
    end

    def delete
        """
        Deletes the object item
        """
        @delete_mixin.json_dict = @json_dict
        @delete_mixin._deleted = @_deleted
        @delete_mixin.save
        @json_dict = @delete_mixin.json_dict
        @_deleted = @delete_mixin._deleted
    end
end


class PayURLCRObjectItem < CRObjectItem
    """
    Object item that allows retrieve, create and to get pay_url based on token of an item
    """
    def initialize(json_dict, resource)
        @pay_url_mixin = PayURLMixin.new(json_dict, resource)
        super(json_dict, resource)
    end

    def pay_url
        """
        :return: pay url
        """
        @pay_url_mixin.json_dict = @json_dict
        @pay_url_mixin.pay_url
    end

    def iframe_url(self)
        """
        :return: iframe url
        """
        @pay_url_mixin.json_dict = @json_dict
        @pay_url_mixin.iframe_url
    end
end



class Resource < ResourceMixin
    """
    Resource - class used to manage the requests to the API related with a resource
    ex: product
    """
    PAGINATOR_CLASS = Paginator

    def __init__(self, api_request):
        """
        Initializes a resource
        :param api_request: Api request used to make all the requests to the API
        """
        self.api_request = api_request


class DetailOnlyResource(DetailOnlyResourceMixin, Resource):
    """
    Resource that allows send requests of detail
    """
    pass


class ReadOnlyResource(ReadOnlyResourceMixin, Resource):
    """
    Resource that allows send requests of list and detail
    """
    pass


class CRResource(CreateResourceMixin, ReadOnlyResource):
    """
    Resource that allows send requests of create, list and detail
    """
    pass


class CRUDResource(DeleteResourceMixin, ChangeResourceMixin, CRResource):
    """
    Resource that allows send requests of delete, change, create, list and detail
    """
    pass
