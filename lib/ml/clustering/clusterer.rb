require 'socket'

module Ml
  module Clustering
    class Clusterer
      SOCKET_PROTOCOL = 0
      SOCKET_BUFFSIZE = 4096
      SOCKET_MESSAGES_IN_FLIGHT = 5
      PYTHON_BINARY = %w(python external/ml/mitclasses/__main__.py)

      def initialize(num_features)
        @num_features = num_features
        setup_sockets
        spawn_process
      end

      def build(feature_vectors)
        feature_vectors.in_groups_of(SOCKET_MESSAGES_IN_FLIGHT, false) do |group|
          send_message group, :features
          sleep 0.1
        end
        send_message nil, :eof
        receive
      end

      def eval(feature_vector)
        send_message [feature_vector], :features
        receive['data'].flatten
      end

      def destroy
        @ruby_socket.close
        Process.waitpid(@pid)
      end

      private

      def send_message(data, type = 'info')
        @ruby_socket.send(JSON.dump(type: type, data: data), SOCKET_PROTOCOL)
      end

      def receive
        JSON.parse(@ruby_socket.recv(SOCKET_BUFFSIZE))
      end

      def setup_sockets
       @ruby_socket, @python_socket = Socket.pair :UNIX, :DGRAM, SOCKET_PROTOCOL
       @ruby_socket.sync = true
      end

      def spawn_process
        @pid = Process.spawn *PYTHON_BINARY, @python_socket.fileno.to_s,
          @num_features.to_s, @python_socket => @python_socket
        @python_socket.close
      end
    end
  end
end
