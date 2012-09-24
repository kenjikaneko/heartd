#!/usr/bin/env ruby

require "eventmachine"
require "em-websocket"

require "heartd/web_socket_server"
require "heartd/mongo_tail"

module Heartd
  extend self

  def run
    Thread.abort_on_exception = true
    EM.run do
      EM.defer { WebSocketServer.run }
      EM.defer { MongoTail.run }
    end
  end

  def channel
    @channel ||= EM::Channel.new
  end
end
