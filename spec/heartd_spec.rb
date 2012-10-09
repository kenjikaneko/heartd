# -*- coding: utf-8 -*-

require 'spec_helper'

describe Heartd do
  describe "#run" do
    it "should call Heartd#WebSocketServer and Heartd#MongoTail" do
      thread = Thread.new do
        Heartd::WebSocketServer.should_receive(:run)
        Heartd::MongoTail.should_receive(:run)
        described_class.run()
      end
      thread.kill
    end
  end
end
