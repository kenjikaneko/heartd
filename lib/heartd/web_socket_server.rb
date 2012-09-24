module HeartD
  module WebSocketServer
    extend self

    def run
      @subscribers = {}
      EM.run {
        EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
          ws.onopen(&onopen(ws))
          ws.onclose(&onclose(ws))
          ws.onmessage(&onmessage)
        end
      }
    end

    def onopen(socket)
      proc do
        socket.send "Hello Client"

        @subscribers[socket.object_id] = channel.subscribe { |msg| socket.send msg }
      end
    end

    def onclose(socket)
      proc do
        channel.unsubscribe(@subscribers[socket.object_id])
        puts "Connection closed"
      end
    end

    def onmessage
      proc do |msg|
        puts "Recieved message: #{msg}"
        channel << "Pong: #{msg}"
      end
    end

    extend Forwardable
    def_delegators :HeartD, :channel
  end
end
