module MC2P

  # Product object
  class Product < CRUDObjectItem

  end

  # Plan object
  class Plan < CRUDObjectItem

  end

  # Tax object
  class Tax < CRUDObjectItem

  end

  # Shipping object
  class Shipping < CRUDObjectItem

  end

  # Coupon object
  class Coupon < CRUDObjectItem

  end

  # Transaction object
  class Transaction < PayURLCRObjectItem

  end

  # Subscription object
  class Subscription < PayURLCRObjectItem

  end

  # Authorization object
  class Authorization < PayURLCRObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      super(json_dict, resource)
      @charge_mixin = ChargeObjectItemMixin.new(json_dict, resource)
    end

    # Charge the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def refund(data = nil)
      @charge_mixin.json_dict = @json_dict
      @charge_mixin._deleted = @_deleted
      @charge_mixin.charge(data)
      @json_dict = @charge_mixin.json_dict
      @_deleted = @charge_mixin._deleted
    end
  end

  # Sale object
  class Sale < ReadOnlyObjectItem
    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      super(json_dict, resource)
      @rcv_mixin = RefundCaptureVoidObjectItemMixin.new(json_dict, resource)
    end

    # Refund the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def refund(data = nil)
      @rcv_mixin.json_dict = @json_dict
      @rcv_mixin._deleted = @_deleted
      @rcv_mixin.refund(data)
      @json_dict = @rcv_mixin.json_dict
      @_deleted = @rcv_mixin._deleted
    end

    # Capture the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def capture(data = nil)
      @rcv_mixin.json_dict = @json_dict
      @rcv_mixin._deleted = @_deleted
      @rcv_mixin.capture(data)
      @json_dict = @rcv_mixin.json_dict
      @_deleted = @rcv_mixin._deleted
    end

    # Void the object item
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def void(data = nil)
      @rcv_mixin.json_dict = @json_dict
      @rcv_mixin._deleted = @_deleted
      @rcv_mixin.void(data)
      @json_dict = @rcv_mixin.json_dict
      @_deleted = @rcv_mixin._deleted
    end

  end

  # Currency object
  class Currency < ReadOnlyObjectItem

  end

  # Gateway object
  class Gateway < ReadOnlyObjectItem

  end

  # PayData object
  class PayData < ReadOnlyObjectItem

    # Initializes an object item
    # Params:
    # +json_dict+:: Data of the object
    # +resource+:: Resource used to delete, save, create or retrieve the object
    def initialize(json_dict, resource)
      super(json_dict, resource, 'token')
      @cs_mixin = CardShareObjectItemMixin.new(json_dict, resource, 'token')
    end

    # Send card details
    # Params:
    # +gateway_code+:: gateway_code to send
    # +data+:: data to send
    # Returns: response dictionary
    def card(gateway_code, data = nil)
      @cs_mixin.json_dict = @json_dict
      @cs_mixin._deleted = @_deleted
      @cs_mixin.card(gateway_code, data)
      @json_dict = @cs_mixin.json_dict
      @_deleted = @cs_mixin._deleted
    end

    # Send share details
    # Params:
    # +data+:: data to send
    # Returns: response dictionary
    def share(data = nil)
      @cs_mixin.json_dict = @json_dict
      @cs_mixin._deleted = @_deleted
      @cs_mixin.share(data)
      @json_dict = @cs_mixin.json_dict
      @_deleted = @cs_mixin._deleted
    end
  end
end
