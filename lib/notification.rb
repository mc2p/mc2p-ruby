module MC2P

  # Notification data - class to manage notification from MyChoice2Pay
  class NotificationData
    # Initializes a notification data
    # Params:
    # +json_body+:: content of request from MyChoice2Pay
    # +mc2p+:: MC2PClient
    def initialize(json_body, mc2p)
      @json_body = json_body
      @mc2p = mc2p
    end

    # Returns: status of payment
    def status
      @json_body['status']
    end

    # Returns: status of subscription
    def subscription_status
      @json_body['subscription_status']
    end

    # Returns: type of payment
    def type
      @json_body['type']
    end

    # Returns: order_id sent when payment was created
    def order_id
      @json_body['order_id']
    end

    # Returns: action executed
    def action
      @json_body['action']
    end

    # Returns: transaction generated when payment was created
    def transaction
      ret = nil
      if type == 'P'
        ret = @mc2p.transaction({'id' => @json_body['id']})
        ret.retrieve
      end
      ret
    end

    # Returns: subscription generated when payment was created
    def subscription
      ret = nil
      if type == 'S'
        ret = @mc2p.subscription({'id' => @json_body['id']})
        ret.retrieve
      end
      ret
    end

    # Returns: sale generated when payment was paid
    def sale
      ret = nil
      if @json_body.include?('sale_id')
        ret = @mc2p.sale({'id' => @json_body['sale_id']})
        ret.retrieve
      end
      ret
    end

    # Returns: action of sale executed
    def sale_action
      @json_body['sale_action']
    end
  end
end
