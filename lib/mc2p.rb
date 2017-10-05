require 'unirest'

require_relative 'errors'
require_relative 'request'
require_relative 'mixins'
require_relative 'base'
require_relative 'objects'
require_relative 'resources'
require_relative 'notification'

module MC2P
  VERSION = '0.1.2'

  # MC2P - class used to manage the communication with MyChoice2Pay API
  class MC2PClient
    attr_accessor :api_request

    attr_accessor :product_resource
    attr_accessor :plan_resource
    attr_accessor :tax_resource
    attr_accessor :shipping_resource
    attr_accessor :coupon_resource
    attr_accessor :transaction_resource
    attr_accessor :subscription_resource
    attr_accessor :sale_resource
    attr_accessor :currency_resource
    attr_accessor :gateway_resource
    attr_accessor :pay_data_resource

    # Initializes a resource
    # Params:
    # +api_request+:: Api request used to make all the requests to the API
    # +path+:: Path used to make all the requests to the API
    # +object_item_class+:: Object item class used to return values
    def initialize(key, secret_key)
      @api_request = APIRequest.new(key, secret_key)

      @product_resource = ProductResource.new(@api_request,
                                              '/product/',
                                              Product)
      @plan_resource = PlanResource.new(@api_request,
                                        '/plan/',
                                        Plan)
      @tax_resource = TaxResource.new(@api_request,
                                      '/tax/',
                                      Tax)
      @shipping_resource = ShippingResource.new(@api_request,
                                                '/shipping/',
                                                Shipping)
      @coupon_resource = CouponResource.new(@api_request,
                                            '/coupon/',
                                            Coupon)
      @transaction_resource = TransactionResource.new(@api_request,
                                                      '/transaction/',
                                                      Transaction)
      @subscription_resource = SubscriptionResource.new(@api_request,
                                                        '/subscription/',
                                                        Subscription)
      @authorization_resource = AuthorizationResource.new(@api_request,
                                                          '/authorization/',
                                                          Authorization)
      @sale_resource = SaleResource.new(@api_request,
                                        '/sale/',
                                        Sale)
      @currency_resource = CurrencyResource.new(@api_request,
                                                '/currency/',
                                                Currency)
      @gateway_resource = GatewayResource.new(@api_request,
                                              '/gateway/',
                                              Gateway)
      @pay_data_resource = PayDataResource.new(@api_request,
                                               '/pay/',
                                               PayData)
    end

    def _wrapper(cls, resource, data)
      cls.new(data, resource)
    end

    def product(data)
      _wrapper(Product, @product_resource, data)
    end

    def plan(data)
      _wrapper(Plan, @plan_resource, data)
    end

    def tax(data)
      _wrapper(Tax, @tax_resource, data)
    end

    def shipping(data)
      _wrapper(Shipping, @shipping_resource, data)
    end

    def coupon(data)
      _wrapper(Coupon, @coupon_resource, data)
    end

    def transaction(data)
      _wrapper(Transaction, @transaction_resource, data)
    end

    def subscription(data)
      _wrapper(Subscription, @subscription_resource, data)
    end

    def authorization(data)
      _wrapper(Authorization, @authorization_resource, data)
    end

    def sale(data)
      _wrapper(Sale, @sale_resource, data)
    end

    def currency(data)
      _wrapper(Currency, @currency_resource, data)
    end

    def gateway(data)
      _wrapper(Gateway, @gateway_resource, data)
    end

    def pay_data(data)
      _wrapper(PayData, @pay_data_resource, data)
    end

    def notification_data(data)
      NotificationData.new(data, self)
    end
  end
end
