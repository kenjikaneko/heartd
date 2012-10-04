# -*- coding: utf-8 -*-

require 'spec_helper'

describe Heartd::MongoTail do
  before(:each) do
    STDOUT.stub(:puts)
  end
  describe '#configure' do
    it 'should set opts to config' do
      opts = { d: "fluent", c: "foo", h: "localhost", p: 27017, n: 10 }
      described_class.configure(opts)
      described_class.config.should eq(opts)
    end
  end

  describe '#run' do
    it "should call #configure" do
      opts = { d: "fluent", c: "foo", h: "localhost", p: 27017, n: 10 }
      described_class.stub(:capped_collection).and_return(true)
      described_class.stub(:tail)

      described_class.should_receive(:configure).with(opts)
      described_class.run(opts)
    end
  end

  describe "#capped_collection" do
    context "when recievied collection is capped" do
      before :each do
        described_class.stub(:config).and_return({ d: "fluent", c: "foo", h: "localhost", p: 27017, n: 10 })
        described_class.stub(:db).and_return(
          double(
            collection_names: double(include?: true),
            collection: double(capped?: true))
        )
      end

      it "should not raise error" do
        proc { described_class.capped_collection }.should_not raise_error
      end

      it "should return capped collection" do
        described_class.capped_collection.should_not be_nil
      end
    end

    context "when recievied collection is not capped" do
      it "call the error message which means 'collection is not capped'" do 
        opts = { d: "fluent", c: "foo", h: "localhost", p: 27017, n: 10 }
        proc {
          described_class.capped_collection(opts)
        }.should raise_error(ArgumentError)  
      end
    end

    context "when recievied collection did not exist in db" do
      it "should raise ArgumentError." do

      end
      it "call the error message which means 'collection did not exist in db'" do
        opts = { d: "fluent", c: "wrong_collection", h: "localhost", p: 27017, n: 10 }
        proc {
          described_class.capped_collection(opts)
        }.should raise_error(ArgumentError)
      end
    end
  end

  describe "#create_cursor_conf" do
    context "when collection count is 5" do
      let (:collection) { double(count: 5) }

      context "when conf[:n] is 3" do
        let (:conf) { { n: 3 } }

        it "should return Hash. And it is 2 for key `:skip`" do
          described_class.create_cursor_conf(collection, conf)[:skip].should eq(2)
        end
      end
    end
  end

  describe "#tail" do
    context "when give args `collection` and `conf` to Cursor.new" do
      let (:collection) { { obj: "obj" } }
      let (:cursor_new) { Mongo::Cursor.stub(:new) }
      context "when Cursor#next_document return value except nil or false" do
        before (:each) do
          cursor = double(next_document: { foo: "bar" })
          cursor.stub(:alive?).and_return(true)
          cursor_new.and_return(cursor)
        end

        it "should push (return value).to_json to channel" do
          # `and_raise` is for aborting loop
          Heartd.channel.should_receive(:<<).with({ foo: "bar" }.to_json).and_raise(Mongo::OperationFailure)
          described_class.tail(collection, { n: 0 })
        end
      end

      context "when Cursor#next_document return nil" do
        before (:each) do
          cursor = double(next_document: nil)

          cursor.stub(:alive?).and_return(true)
          cursor_new.and_return(cursor)
        end

        it "should sleep" do
          described_class.should_receive(:sleep).with(1).and_raise(Mongo::OperationFailure)
          described_class.tail(collection, { n: 0 })
        end
      end
    end
  end

end
