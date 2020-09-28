require 'socket'
require 'wab_sarvar/request'
require 'wab_sarvar/response'

module WabSarvar
  class HTTPServer
    class << self
      def start
        host = ENV.fetch('HOST', '0.0.0.0')
        port = ENV.fetch('PORT', '1234')
        socket = TCPServer.new(host, port)

        puts "Listening on #{host}:#{port}. Press CTRL+C to cancel."

        loop do
          Thread.start(socket.accept) do |client|
            handle_connection(client)
          end
        end
      end

      def handle_connection(client)
        request_text = client.readpartial(2048)

        request = Request.new(request_text)
        puts "#{client.peeraddr[3]} #{request.path}"

        response = handle_request(request)

        response.send(client)
        client.shutdown
      rescue => e
        puts "Error: #{e}"

        response = Response.new(code: 500, data: "Internal Server Error")
        response.send(client)

        client.close
      end

      def handle_request(request)
        params = request.params
        puts "[PARAMS]: #{params.inspect}"

        case request.path
        when '/'
          Response.new(code: 200, data: 'HELLO!!!')
        else
          Response.new(code: 404, data: 'Path not found')
        end
      end
    end
  end
end
