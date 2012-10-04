# -*- coding: utf-8 -*-

# fork from https://github.com/fluent/fluent-plugin-mongo/blob/master/bin/mongo-tail

require 'json'
require 'mongo'

module Heartd
  module MongoTail
    extend self

    attr_reader :config

    def run(opts = {})
      configure opts

      collection = capped_collection()

      tail(collection, config)
    end

    def configure(opts)
      @config = {
        d: opts[:d] || "fluent",
        c: opts[:c] || "foo",
        h: opts[:h] || "localhost",
        p: opts[:p] || 27017,
        n: opts[:n] || 10
      }
    end

    def db
      @db ||= Mongo::Connection.new(config[:h], config[:p]).db(config[:d])
    end

    def capped_collection
      unless db.collection_names.include?(config[:c])
        raise ::ArgumentError, "#{config[:c]} not found: server = #{conf[:h]}:#{conf[:p]}"
      end

      collection = db.collection(config[:c])

      unless collection.capped?
        raise ::ArgumentError, "#{config[:c]} is not capped. mongo-tail can not tail normal collection."
      end

      collection
    end

    def create_cursor_conf(collection, conf)
      skip = collection.count - conf[:n]
      cursor_conf = {}
      cursor_conf[:skip] = skip if skip > 0
      cursor_conf
    end

    def tail(collection, conf)
      cursor_conf = create_cursor_conf(collection, conf)
      cursor_conf[:tailable] = true

      cursor = Mongo::Cursor.new(collection, cursor_conf)

      loop {
        # TODO: Check more detail of cursor state if needed
        cursor = Mongo::Cursor.new(collection, cursor_conf) unless cursor.alive?

        if doc = cursor.next_document
          d = doc.to_json
          STDOUT.puts d
          channel << d
        else
          sleep 1
        end
      }
    rescue Mongo::OperationFailure
      # ignore Mongo::OperationFailure at CURSOR_NOT_FOUND
    end

    extend Forwardable
    def_delegators :Heartd, :channel
  end
end
