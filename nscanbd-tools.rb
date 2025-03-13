#!/bin/env ruby
# encoding: utf-8

require 'savon'

# # create a client for the service
# client = Savon.client(wsdl: 'http://service.example.com?wsdl')

# or: create a client with a wsdl provided as a string
client = Savon.client do |config|
  wsdl_content = File.read("./wsdl/WS-Discovery (MS)/ws-discovery.wsdl")
  config.wsdl wsdl_content  
  config.endpoint "10.4.30.22"
end

# Savon.client(endpoint: "10.4.30.22")
pp client
pp client.operations
# => [:find_user, :list_users]

# call the 'findUser' operation
pp response = client.call(:HelloOp, message: { id: 42 })

# response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }


# client = Savon.client do
#   endpoint "http://example.com"
#   namespace "http://v1.example.com"
# end

# pp client.operations