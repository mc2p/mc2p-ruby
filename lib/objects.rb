require "base"
require "mixin"


class Product < CRUDObjectItem
    """
    Product object
    """
end


class Plan < CRUDObjectItem
    """
    Plan object
    """
end


class Tax < CRUDObjectItem
    """
    Tax object
    """
end


class Shipping < CRUDObjectItem
    """
    Shipping object
    """
end


class Coupon < CRUDObjectItem
    """
    Coupon object
    """
end


class Transaction(PayURLMixin, CRObjectItem):
    """
    Transaction object
    """
    pass


class Subscription(PayURLMixin, CRObjectItem):
    """
    Subscription object
    """
    pass


class Sale(RefundCaptureVoidObjectItemMixin, ReadOnlyObjectItem):
    """
    Sale object
    """
    pass


class Currency(ReadOnlyObjectItem):
    """
    Currency object
    """
    pass


class Gateway(ReadOnlyObjectItem):
    """
    Gateway object
    """
    pass


class PayData(CardShareObjectItemMixin, ReadOnlyObjectItem):
    """
    PayData object
    """
    ID_PROPERTY = 'token'

