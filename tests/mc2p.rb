require 'mc2p'

key = 'fd1e7e20a676'
secret = 'a88402f080b54547ad07114a13c1a375'

mc2p = MC2P::MC2PClient.new(key, secret)

# Create transaction
transaction = mc2p.transaction('currency' => 'EUR',
                               'products' => [{
                                                'amount' => 1,
                                                'product' => {
                                                  'name' => 'Product',
                                                  'price' => 5
                                                }
                               }])
transaction.save
transaction.pay_url # Send user to this url to pay
transaction.iframe_url # Use this url to show an iframe in your site

# Get plans
plans_paginator = mc2p.plan_resource.list
plans_paginator.count
plans_paginator.results # Application's plans
plans_paginator.next_list

# Get product, change and save
product = mc2p.product('id' => '59ba4752-1679-43b5-b0c7-2c48fdb77e4e')
product.retrieve
product.set('price', 10)
product.save

# Create and delete tax
tax = mc2p.tax('name' => 'Tax', 'percent' => 5)
tax.save
tax.delete

# Check if transaction was paid
transaction = mc2p.transaction('id' => 'c8325bb3-c24e-4c0c-b0ff-14fe89bf9f1f')
transaction.retrieve
transaction.status == 'D' # Paid

# Create subscription
subscription = mc2p.subscription('currency' => 'EUR',
                                 'plan' => {
                                   'name' => 'Plan',
                                   'price' => 5,
                                   'duration' => 1,
                                   'unit' => 'M',
                                   'recurring' => true
                                 },
                                 'note' => 'Note example'
)
subscription.save
subscription.pay_url # Send user to this url to pay
subscription.iframe_url # Use this url to show an iframe in your site

# Receive a notification
notification_data = mc2p.notification_data('status' => 'D', 'type' => 'P',
                                           'id' => 'c8325bb3-c24e-4c0c-b0ff-14fe89bf9f1f',
                                           'sale_id' => 'd1bb7082-7a97-48c6-893d-4d5febcd463b')
notification_data.status == 'D' # Paid
notification_data.transaction # Transaction Paid
notification_data.sale # Sale generated

# Exceptions

# Incorrect data
shipping = mc2p.shipping('name' => 'Normal shipping',
                         'price' => 'text') # Price must be number
begin
  shipping.save
rescue MC2P::InvalidRequestError => e
  puts e.message # Status code of error
  puts e.json_body # Info from server
  puts e.resource # Resource used to make the server request
  puts e.resource_id # Resource id requested
end
