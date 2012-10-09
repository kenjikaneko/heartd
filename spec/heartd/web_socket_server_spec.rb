# -*- coding: utf-8 -*-

require 'spec_helper'

describe Heartd::WebSocketServer do
  before(:each) do
    STDOUT.stub(:puts)
  end
  describe '#onopen' do
    let (:socket) { double(send: true) }

    context "when proc object that return form #onopen called" do
      it "should call socket.send'" do
        socket.should_receive(:send).with("Hello Client")
        described_class.onopen(socket).call
      end

      it "should set subscriber to @subscribers[socket.object_id]" do
        subscriber = proc {}
        described_class.channel.stub(:subscribe).and_return(subscriber)
        described_class.subscribers.should_receive(:[]=).with(socket.object_id, subscriber)
        described_class.onopen(socket).call
      end
    end
  end 

  describe '#onclose' do
    let (:socket) { double() }
    let (:subscriber) { "subscriber" }
    let (:all_subscribers) {
      _all_subscribers = {}
      _all_subscribers[socket.object_id] = subscriber
      _all_subscribers
    }
    context "call #onclose's return object" do
      before(:each) do
        described_class.stub(:subscribers).and_return(all_subscribers)
      end
      it "should close the connection " do
        Heartd.channel.should_receive(:unsubscribe).with(subscriber)
        described_class.onclose(socket).call
      end
    end
  end

  describe '#onmessage' do
    let (:msg) { "message" }
    context "when call proc return from #onmessage" do
      it "should send a message to the channel" do
        Heartd.channel.should_receive(:<<).with("Pong: #{msg}")
        described_class.onmessage.call(msg)
      end
    end
  end  

end
