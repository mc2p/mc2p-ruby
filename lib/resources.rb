module MC2P

  # Product resource
  class ProductResource < CRUDResource

  end

  # Plan resource
  class PlanResource < CRUDResource

  end

  # Tax resource
  class TaxResource < CRUDResource

  end

  # Shipping resource
  class ShippingResource < CRUDResource

  end

  # Coupon resource
  class CouponResource < CRUDResource

  end

  # Transaction resource
  class TransactionResource < CRResource

  end

  # Subscription resource
  class SubscriptionResource < CRResource

  end

  # Sale resource
  class SaleResource < ReadOnlyResource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @rcv_resource_mixin = RefundCaptureVoidResourceMixin.new(api_request, path, object_item_class, @paginator_class)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def refund(resource_id, data = nil)
      @rcv_resource_mixin.refund(resource_id, data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def capture(resource_id, data = nil)
      @rcv_resource_mixin.capture(resource_id, data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def void(resource_id, data = nil)
      @rcv_resource_mixin.void(resource_id, data)
    end
  end

  # Currency resource
  class CurrencyResource < ReadOnlyResource

  end

  # Gateway resource
  class GatewayResource < ReadOnlyResource

  end

  # PayData resource
  class PayDataResource < DetailOnlyResource
    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(api_request, path, object_item_class)
      super(api_request, path, object_item_class)
      @cs_resource_mixin = CardShareResourceMixin.new(api_request, path, object_item_class, @paginator_class)
    end

    # Params:
    # +resource_id+:: id to request
    # +gateway_code+:: gateway_code to send
    # +data+:: data to send
    # Returns: response dictionary
    def card(resource_id, gateway_code, data = nil)
      @cs_resource_mixin.card(resource_id, gateway_code, data)
    end

    # Params:
    # +resource_id+:: id to request
    # +data+:: data to send
    # Returns: response dictionary
    def share(resource_id, data = nil)
      @cs_resource_mixin.share(resource_id, data)
    end
  end

end

