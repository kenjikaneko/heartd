# encoding: UTF-8

# --
# Copyright (C) 2008-2011 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

module Mongo

  # Instantiates and manages connections to a MongoDB sharded cluster for high availability.
  class ShardedConnection < ReplSetConnection

    SHARDED_CLUSTER_OPTS = [:refresh_mode, :refresh_interval]

    attr_reader :seeds, :refresh_interval, :refresh_mode,
                :refresh_version, :manager

    # Create a connection to a MongoDB sharded cluster.
    #
    # If no args are provided, it will check <code>ENV["MONGODB_URI"]</code>.
    #
    # @param [Array] seeds "host:port" strings
    #
    # @option opts [String] :name (nil) The name of the sharded cluster to connect to. You
    #   can use this option to verify that you're connecting to the right sharded cluster.
    # @option opts [Boolean, Hash] :safe (false) Set the default safe-mode options
    #   propagated to DB objects instantiated off of this Connection. This
    #   default can be overridden upon instantiation of any DB by explicitly setting a :safe value
    #   on initialization.
    # @option opts [Logger] :logger (nil) Logger instance to receive driver operation log.
    # @option opts [Integer] :pool_size (1) The maximum number of socket connections allowed per
    #   connection pool. Note: this setting is relevant only for multi-threaded applications.
    # @option opts [Float] :pool_timeout (5.0) When all of the connections a pool are checked out,
    #   this is the number of seconds to wait for a new connection to be released before throwing an exception.
    #   Note: this setting is relevant only for multi-threaded applications.
    # @option opts [Float] :op_timeout (nil) The number of seconds to wait for a read operation to time out.
    # @option opts [Float] :connect_timeout (30) The number of seconds to wait before timing out a
    #   connection attempt.
    # @option opts [Boolean] :ssl (false) If true, create the connection to the server using SSL.
    # @option opts [Boolean] :refresh_mode (false) Set this to :sync to periodically update the
    #   state of the connection every :refresh_interval seconds. Sharded cluster connection failures
    #   will always trigger a complete refresh. This option is useful when you want to add new nodes
    #   or remove sharded cluster nodes not currently in use by the driver.
    # @option opts [Integer] :refresh_interval (90) If :refresh_mode is enabled, this is the number of seconds
    #   between calls to check the sharded cluster's state.
    # Note: that the number of seed nodes does not have to be equal to the number of sharded cluster members.
    # The purpose of seed nodes is to permit the driver to find at least one sharded cluster member even if a member is down.
    #
    # @example Connect to a sharded cluster and provide two seed nodes.
    #   Mongo::ShardedConnection.new(['localhost:30000', 'localhost:30001'])
    #
    # @raise [MongoArgumentError] This is raised for usage errors.
    #
    # @raise [ConnectionFailure] This is raised for the various connection failures.
    def initialize(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}

      nodes = args.flatten

      if nodes.empty? and ENV.has_key?('MONGODB_URI')
        parser = URIParser.new ENV['MONGODB_URI']
        if parser.direct?
          raise MongoArgumentError, "Mongo::ShardedConnection.new called with no arguments, but ENV['MONGODB_URI'] implies a direct connection."
        end
        opts = parser.connection_options.merge! opts
        nodes = [parser.nodes]
      end

      unless nodes.length > 0
        raise MongoArgumentError, "A ShardedConnection requires at least one seed node."
      end

      @seeds = nodes.map do |host_port|
        host, port = host_port.split(":")
        [ host, port.to_i ]
      end

      # TODO: add a method for replacing this list of node.
      @seeds.freeze

      # Refresh
      @last_refresh = Time.now
      @refresh_version = 0

      # No connection manager by default.
      @manager = nil
      @old_managers = []

      # Lock for request ids.
      @id_lock = Mutex.new

      @pool_mutex = Mutex.new
      @connected = false

      @safe_mutex_lock = Mutex.new
      @safe_mutexes = Hash.new {|hash, key| hash[key] = Mutex.new}

      @connect_mutex = Mutex.new
      @refresh_mutex = Mutex.new

      check_opts(opts)
      setup(opts)
    end

    def valid_opts
      GENERIC_OPTS + SHARDED_CLUSTER_OPTS
    end

    def inspect
      "<Mongo::ShardedConnection:0x#{self.object_id.to_s(16)} @seeds=#{@seeds.inspect} " +
          "@connected=#{@connected}>"
    end

    # Initiate a connection to the sharded cluster.
    def connect(force = !@connected)
      return unless force
      log(:info, "Connecting...")
      @connect_mutex.synchronize do
        discovered_seeds = @manager ? @manager.seeds : []
        @old_managers << @manager if @manager
        @manager = ShardingPoolManager.new(self, discovered_seeds | @seeds)

        Thread.current[:managers] ||= Hash.new
        Thread.current[:managers][self] = @manager

        @manager.connect
        @refresh_version += 1
        @last_refresh = Time.now
        @connected = true
      end
    end

    # Force a hard refresh of this connection's view
    # of the sharded cluster.
    #
    # @return [Boolean] +true+ if hard refresh
    #   occurred. +false+ is returned when unable
    #   to get the refresh lock.
    def hard_refresh!
      log(:info, "Initiating hard refresh...")
      connect(true)
      return true
    end

    def connected?
      @connected && @manager.primary_pool
    end

    # Returns +true+ if it's okay to read from a secondary node.
    # Since this is a sharded cluster, this must always be false.
    #
    # This method exist primarily so that Cursor objects will
    # generate query messages with a slaveOkay value of +true+.
    #
    # @return [Boolean] +true+
    def slave_ok?
      false
    end

    def checkout(&block)
      2.times do
        if connected?
          sync_refresh
        else
          connect
        end

        begin
          socket = block.call
        rescue => ex
          checkin(socket) if socket
          raise ex
        end

        if socket
          return socket
        else
          @connected = false
          #raise ConnectionFailure.new("Could not checkout a socket.")
        end
      end
    end

    private

    # Parse option hash
    def setup(opts)
      # Refresh
      @refresh_mode = opts.fetch(:refresh_mode, false)
      @refresh_interval = opts.fetch(:refresh_interval, 90)

      if @refresh_mode && @refresh_interval < 60
        @refresh_interval = 60 unless ENV['TEST_MODE'] = 'TRUE'
      end

      if @refresh_mode == :async
        warn ":async refresh mode has been deprecated. Refresh
        mode will be disabled."
      elsif ![:sync, false].include?(@refresh_mode)
        raise MongoArgumentError,
          "Refresh mode must be either :sync or false."
      end

      opts[:connect_timeout] = opts[:connect_timeout] || 30

      super opts
    end

  end
end
