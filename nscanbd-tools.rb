#!/bin/env ruby
# encoding: utf-8

require 'savon'

# # create a client for the service
# client = Savon.client(wsdl: 'http://service.example.com?wsdl')
# client = Savon.client(wsdl: 'http://10.4.30.22:80/wsd/mex')

# or: create a client with a wsdl provided as a string
# client = Savon.client do |config|
#   wsdl_content = File.read("wsdl/WS-Discovery (oasis)/wsdd-discovery-1.1-wsdl-os.wsdl").gsub ("portType", "binding")
#   config.wsdl wsdl_content  
#   config.endpoint "http://10.4.30.30:80/wsd/mex"
#   config.log_level :debug 
# end

# Savon.client(endpoint: "10.4.30.22")
# pp client
# pp client.operations
# => [:find_user, :list_users]

# call the 'findUser' operation
# pp response = client.call(:HelloOp, message: { id: 42 })
# pp response = client.call("http://10.4.30.30:80/wsd/mex")

# response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }


# client = Savon.client do
#   endpoint "http://example.com"
#   namespace "http://v1.example.com"
# end

# pp client.operations

# =================================================================================================



# frozen_string_literal: true

# This example implements an IP discover mechanism for IPv4 and IPv6.  Run
# server with `ruby server.rb` and query with something like `dig my.ip
# @[address_of_server]` This server is not intended for production use unless
# you want to experiment with Ractors!
# This example originally comes from this blog post:
# https://kirshatrov.com/2020/09/08/ruby-ractor-web-server/

require "socket"
# require "dnsmessage"
require "ipaddr"
# require "etc"

LISTEN_ADDR = "10.4.30.178"
# LISTEN_ADDR = "127.0.0.1"
LISTEN_PORT = 3702
MSG_LENGTH  = 1400
FLAGS       = 0

pipe = Ractor.new do
  loop do
    Ractor.yield(Ractor.recv)
  end
end

# Create socket outside of Ractor context
server_socket = UDPSocket.new :AF_INET
server_socket.bind(LISTEN_ADDR, LISTEN_PORT)

# CPU_COUNT = Etc.nprocessors
# workers = CPU_COUNT.times.map do
workers = 4.times.map do  
  Ractor.new(pipe, server_socket) do |pipe, server_socket|
    loop do
      message, client = pipe.take
      puts "taken from pipe by #{Ractor.current}"

      pp message

      # msg = DNSMessage::Message.parse(message)

      # Extract client information given as array and log connection
      # addr_info = Addrinfo.new(client)
      # puts "Client connected from #{addr_info.ip_address} using " \
      #      "#{addr_info.ipv6_v4mapped? ? "IPv4" : "IPv6"}"

      # response = DNSMessage::Message.reply_to(msg)
      # opt = DNSMessage::RR.default_opt(512)

      # Set IPv6 defaults
      # type = DNSMessage::Type::AAAA
      # ip = addr_info.ip_address

      # # See if we need to fall back to IPv4
      # if addr_info.ipv6_v4mapped?
      #   type = DNSMessage::Type::A
      #   ip = addr_info.ipv6_to_ipv4.ip_address
      # end

      # response.answers << DNSMessage::RR.new(name: "your.ip", type: type,
      #   ttl: 10, rdata: IPAddr.new(ip))

      # # Be nice and add an EDNS record
      # response.additionals << opt

      # # Write back to client with AddressFamily and reversed original message
      # server_socket.send(response.build,
      #                    FLAGS, addr_info.ip_address, addr_info.ip_port)
    end
  end
end

listener = Ractor.new(pipe, server_socket) do |pipe, server_socket|
  loop do
    msg, client = server_socket.recvfrom(MSG_LENGTH)
    pipe.send([msg, client])
  end
end

loop do
  Ractor.select(listener, *workers)
  # if the line above returned, one of the workers or the listener has crashed
end