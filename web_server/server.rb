require 'socket'
require 'json'

server = TCPServer.open(2000)

loop do
  Thread.start(server.accept) do |client|

    request = client.read_nonblock(256)
    header, body = request.split("\r\n\r\n", 2)
    method = header.split[0]
    path = header.split[1][1..-1]
    version = header.split[2]

    if File.exist?(path)
      response = File.open(path)

      if method == "GET"
        client.puts "GET /index.html HTTP/1.0 200 OK\n#{Time.now.ctime}\n" \
                    "Content-Length: #{path.size}\r\n\r\n#{response.read}"

      elsif method == "POST"
        params = JSON.parse(body)

        data = "<li>Name: #{params['user']['name']}</li>\n<li>Email: " \
               "#{params['user']['email']}</li>"

        client.puts "POST /thanks.html HTTP/1.0 200 OK\n#{Time.now.ctime}\n" \
                    "Content-Length: #{path.size}\r\n\r\n" \
                    "#{response.read.gsub("<%= yield %>", data)}"
      end

    else
      client.puts "#{version} 404 Not Found"
    end
    client.close
  end
end
