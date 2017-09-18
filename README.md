# MyChoice2Pay Ruby


# Overview

MyChoice2Pay Ruby provides integration access to the MyChoice2Pay API.

# Installation

Add this line to your application's Gemfile:

    gem 'mc2p-ruby'
    
And then execute:

    $ bundle

Or install it yourself as:

    gem install mc2p-ruby

# Quick Start Example

    require 'mc2p'
    
    mc2p = MC2P::MC2PClient.new('KEY', 'SECRET_KEY')
    
    # Create transaction
    transaction = mc2p.transaction({
                                       'currency' => 'EUR',
                                       'products' => [{
                                                          'amount' => 1,
                                                          'product_id' => 'PRODUCT-ID'
                                                      }]
                                   })
    # or with product details
    transaction = mc2p.transaction({
                                       'currency' => 'EUR',
                                       'products' => [{
                                                          'amount' => 1,
                                                          'product' => {
                                                              'name' => 'Product',
                                                              'price' => 5
                                                          }
                                                      }]
                                   })
    transaction.save
    transaction.pay_url # Send user to this url to pay
    transaction.iframe_url # Use this url to show an iframe in your site

    # Get plans
    plans_paginator = mc2p.plan_resource.list
    plans_paginator.count
    plans_paginator.results # Application's plans
    plans_paginator.next_list
    
    # Get product, change and save
    product = mc2p.product({
                               'id' => 'PRODUCT-ID'
                           })
    product.retrieve
    product.set('price', 10)
    product.save
    
    # Create and delete tax
    tax = mc2p.tax({
                       'name' => 'Tax',
                       'percent' => 5
                   })
    tax.save
    tax.delete
    
    # Check if transaction was paid
    transaction = mc2p.transaction({
                                       'id' => 'TRANSACTION-ID'
                                   })
    transaction.retrieve
    transaction.status == 'D' # Paid
    
    # Create subscription
    subscription = mc2p.subscription({
                                         'currency' => 'EUR',
                                         'plan_id' => 'PLAN-ID',
                                         'note' => 'Note example'
                                     })
    # or with plan details
    subscription = mc2p.subscription({
                                         'currency' => 'EUR',
                                         'plan' => {
                                             'name' => 'Plan',
                                             'price' => 5,
                                             'duration' => 1,
                                             'unit' => 'M',
                                             'recurring' => true
                                         },
                                         'note' => 'Note example'
                                     })
    subscription.save
    subscription.pay_url # Send user to this url to pay
    subscription.iframe_url # Use this url to show an iframe in your site

    # Receive a notification
    notification_data = mc2p.notification_data(JSON_DICT_RECEIVED_FROM_MYCHOICE2PAY)
    notification_data.status == 'D' # Paid
    notification_data.transaction # Transaction Paid
    notification_data.sale # Sale generated

# Exceptions
    
    require 'mc2p'
    
    # Incorrect data
    shipping = mc2p.shipping({
                                 'name' => 'Normal shipping',
                                 'price' => 'text' # Price must be number
                             })
    begin
      shipping.save
    rescue MC2P::InvalidRequestError => e
      puts e.message # Status code of error
      puts e.json_body # Info from server
      puts e.resource # Resource used to make the server request
      puts e.resource_id # Resource id requested
    end

