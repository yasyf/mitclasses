require 'socket'

module ML
  module Learners
    class Learner
      SOCKET_PROTOCOL = 0
      SOCKET_BUFFSIZE = 1048576
      SOCKET_MESSAGES_IN_FLIGHT = 80
      LARGE_SOCKET_MESSAGES_IN_FLIGHT = 10
      PYTHON_BINARY = %w(python external/ml/mitclasses)

      def initialize(model)
        @model = model
        @num_features = Array.wrap(model.num_features)
        setup_sockets
        spawn_process
      end

      def preprocess(preprocess_vectors)
        send_vectors preprocess_vectors, :preprocess, in_flight: LARGE_SOCKET_MESSAGES_IN_FLIGHT
      end

      def build(feature_vectors)
        send_vectors feature_vectors, :features
        send_message nil, :eof
        receive
      end

      def eval(feature_vector)
        send_message [feature_vector], :features
        receive['data'].flatten
      end

      def destroy
        send_message nil, :quit
        @ruby_socket.close
        Process.waitpid(@pid)
      end

      private

      def send_vectors(vectors, type, in_flight: SOCKET_MESSAGES_IN_FLIGHT)
        vectors.in_groups_of(in_flight, false) do |group|
          send_message group, type
        end
      end

      def send_message(data, type = 'info')
        @ruby_socket.send(JSON.dump(type: type, data: data), SOCKET_PROTOCOL)
      rescue Errno::ENOBUFS => e
        Rails.logger.warn e.message
        sleep 0.1
        retry
      end

      def receive
        JSON.parse(@ruby_socket.recv(SOCKET_BUFFSIZE))
      end

      def setup_sockets
       @ruby_socket, @python_socket = Socket.pair :UNIX, :DGRAM, SOCKET_PROTOCOL

       [@ruby_socket, @python_socket].each do |socket|
         socket.setsockopt :SOCKET, :SO_RCVBUF, SOCKET_BUFFSIZE
         socket.setsockopt :SOCKET, :SO_SNDBUF, SOCKET_BUFFSIZE
       end
      end

      def spawn_process
        @pid = Process.spawn *PYTHON_BINARY, @python_socket.fileno.to_s,
          @num_features.join(','), self.class.type.to_s, @model.name,
          @python_socket => @python_socket
        @python_socket.close
      end
    end
  end
end
