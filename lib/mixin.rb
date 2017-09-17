require "errors"


class ObjectItemMixin
    """
    Basic info of the object item
    """
    ID_PROPERTY = "id"
    json_dict = None
    resource = None
    _deleted = False

    def initialize(json_dict, resource)
        @json_dict = json_dict
        @resource = resource

    def id_required_and_not_deleted
        if not @json_dict.fetch(@ID_PROPERTY)
            raise BadUseError("Object don't have ID")
        if @_deleted
            raise BadUseError("Object deleted")
    end

    def to_s
        """
        :return: Name of the object and content
        """
        "%s #{@json_dict}" % self.class.name
    end
end


class DeleteObjectItemMixin < ObjectItemMixin
    """
    Allows delete an object item
    """
    def delete
        """
        Deletes the object item
        """
        self.id_required_and_not_deleted
        @resource.delete(
            @json_dict[@ID_PROPERTY]
        )
        @_deleted = True
    end
end


class RetrieveObjectItemMixin < ObjectItemMixin
    """
    Allows retrieve an object item
    """
    def retrieve
        """
        Retrieves the data of the object item
        """
        self.id_required_and_not_deleted
        obj = @resource.detail(
            @json_dict[@ID_PROPERTY]
        )
        @json_dict = obj.json_dict
    end
end


class CreateObjectItemMixin < ObjectItemMixin
    """
    Allows create an object item
    """
    def _create
        """
        Creates the object item with the json_dict data
        """
        obj = @resource.create(
            @json_dict
        )
        @json_dict = obj.json_dict
    end

    def save
        """
        Executes the internal function _create if the object item don't have id
        """
        if not @json_dict.fetch(@ID_PROPERTY, False)
            self._create
    end
end


class SaveObjectItemMixin < CreateObjectItemMixin
    """
    Allows change an object item
    """
    def _change
        """
        Changes the object item with the json_dict data
        """
        self.id_required_and_not_deleted
        obj = @resource.change(
            @json_dict[@ID_PROPERTY],
            @json_dict
        )
        @json_dict = obj.json_dict
    end

    def save
        """
        Executes the internal function _create if the object item don't have id,
        in other case, call to _change
        """
        if @json_dict.fetch(@ID_PROPERTY, False)
            self._change
        else
            self._create
    end
end


class RefundCaptureVoidObjectItemMixin < ObjectItemMixin
    """
    Allows make refund, capture and void an object item
    """
    def refund(data=nil)
        """
        Refund the object item
        :param data: data to send
        :return: response dictionary
        """
        self.id_required_and_not_deleted
        @resource.refund(
            @json_dict[@ID_PROPERTY],
            data
        )
    end

    def capture(data=None)
        """
        Capture the object item
        :param data: data to send
        :return: response dictionary
        """
        self.id_required_and_not_deleted
        @resource.capture(
            @json_dict[@ID_PROPERTY],
            data
        )
    end

    def void(data=None)
        """
        Void the object item
        :param data: data to send
        :return: response dictionary
        """
        self.id_required_and_not_deleted
        @resource.void(
            @json_dict[@ID_PROPERTY],
            data
        )
    end
end


class CardShareObjectItemMixin < ObjectItemMixin
    """
    Allows make card and share an object item
    """
    def card(gateway_code, data=None)
        """
        Send card details
        :param gateway_code: gateway_code to send
        :param data: data to send
        :return: response dictionary
        """
        self.id_required_and_not_deleted
        @resource.card(
            @json_dict[@ID_PROPERTY],
            gateway_code,
            data
        )
    end

    def share(self, data=None)
        """
        Send share details
        :param data: data to send
        :return: response dictionary
        """
        self.id_required_and_not_deleted
        @resource.share(
            @json_dict[@ID_PROPERTY],
            data
        )
    end
end


class PayURLMixin < ObjectItemMixin
    """
    Add property to get pay_url based on token
    """
    PAY_URL = "https://pay.mychoice2pay.com/#/%s"
    IFRAME_URL = "https://pay.mychoice2pay.com/#/%s/iframe"

    def pay_url
        """
        :return: pay url
        """
        self.id_required_and_not_deleted
        @PAY_URL % @json_dict["token"]
    end

    def iframe_url(self)
        """
        :return: iframe url
        """
        self.id_required_and_not_deleted
        @IFRAME_URL % @json_dict["token"]
    end
end


class ResourceMixin
    """
    Basic info of the resource
    """
    PATH = "/resource/"
    OBJECT_ITEM_CLASS = nil
    PAGINATOR_CLASS = nil
    api_request = nil

    def detail_url(resource_id)
        """
        :param resource_id: id used on the url returned
        :return: url to request or change an item
        """
        '#{@PATH}#{resource_id}/'
    end

    def _one_item(func, data=nil, resource_id=nil)
        """
        Help function to make a request that return one item
        :param func: function to make the request
        :param data: data passed in the request
        :param resource_id: id to use on the requested url
        :return: an object item that represent the item returned
        """
        if not resource_id
            url = @PATH
        else
            url = self.detail_url(resource_id)

        @OBJECT_ITEM_CLASS.new(
            func(
                url,
                data,
                resource:self,
                resource_id:resource_id
            ),
            self
        )
    end
end


class DetailOnlyResourceMixin < ResourceMixin
    """
    Allows send requests of detail
    """
    def detail(resource_id)
        """
        :param resource_id: id to request
        :return: an object item class with the response of the server
        """
        self._one_item(@api_request.get,
                       resource_id:resource_id)
    end
end


class ReadOnlyResourceMixin < DetailOnlyResourceMixin
    """
    Allows send requests of list and detail
    """
    def list(abs_url=nil)
        """
        :param abs_url: if is passed the request is sent to this url
        :return: a paginator class with the response of the server
        """
        if abs_url
            json_dict = @api_request.get(
                abs_url:abs_url,
                resource:self
            )
        else:
            json_dict = @api_request.get(
                @PATH,
                resource:self
            )

        @PAGINATOR_CLASS.new(
            json_dict,
            @OBJECT_ITEM_CLASS,
            self
        )
    end
end


class CreateResourceMixin < ResourceMixin
    """
    Allows send requests of create
    """
    def create(data)
        """
        :param data: data used on the request
        :return: an object item class with the response of the server
        """
        self._one_item(@api_request.post,
                       data:data)
    end
end


class ChangeResourceMixin < ResourceMixin
    """
    Allows send requests of change
    """
    def change(resource_id, data)
        """
        :param resource_id: id to request
        :param data: data used on the request
        :return: an object item class with the response of the server
        """
        self._one_item(@api_request.patch,
                       data:data,
                       resource_id:resource_id)
    end
end


class DeleteResourceMixin < ResourceMixin
    """
    Allows send requests of delete
    """
    def delete(resource_id)
        """
        :param resource_id: id to request
        """
        self._one_item(@api_request.delete,
                       resource_id:resource_id)
    end
end


class ActionsResourceMixin < ResourceMixin
    """
    Allows send requests of actions
    """
    def detail_action_url(resource_id, action)
        """
        :param resource_id: id used on the url returned
        :param action: action used on the url returned
        :return: url to make an action in an item
        """
        '#{@PATH}#{resource_id}/#{action}/'
    end

    def _one_item_action(func, resource_id, action, data=nil)
        """
        Help function to make an action in an item
        :param func: function to make the request
        :param resource_id: id to use on the requested url
        :param action: action to use on the requested url
        :param data: data passed in the request
        :return: response dictionary
        """
        url = self.detail_action_url(resource_id, action)

        func(
            url,
            data,
            resource:self,
            resource_id:resource_id
        )
    end
end


class RefundCaptureVoidResourceMixin < ActionsResourceMixin
    """
    Allows send action requests of refund, capture and void
    """
    def refund(resource_id, data=nil)
        """
        :param resource_id: id to request
        :param data: data to send
        :return: response dictionary
        """
        self._one_item_action(@api_request.post_200,
                              resource_id,
                              "refund",
                              data)
    end

    def capture(resource_id, data=nil)
        """
        :param resource_id: id to request
        :param data: data to send
        :return: response dictionary
        """
        self._one_item_action(@api_request.post_200,
                              resource_id,
                              "capture",
                              data)
    end

    def void(resource_id, data=nil)
        """
        :param resource_id: id to request
        :param data: data to send
        :return: response dictionary
        """
        self._one_item_action(@api_request.post_200,
                              resource_id,
                              "void",
                              data)
    end
end


class CardShareResourceMixin < ActionsResourceMixin
    """
    Allows send action requests of card and share
    """
    def card(resource_id, gateway_code, data=nil)
        """
        :param resource_id: id to request
        :param gateway_code: gateway_code to send
        :param data: data to send
        :return: response dictionary
        """
        self._one_item_action(@api_request.post,
                              resource_id,
                              "card/#{gateway_code}",
                              data)
    end

    def share(resource_id, data=nil):
        """
        :param resource_id: id to request
        :param data: data to send
        :return: response dictionary
        """
        self._one_item_action(@api_request.post,
                              resource_id,
                              "share",
                              data)
    end
end
