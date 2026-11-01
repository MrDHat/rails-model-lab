# frozen_string_literal: true

# Runs outside the agent jail, inside its Docker sandbox. No published port,
# filesystem mounts or provider credentials: requests leave only over stdio.
require "socket"
require "json"

STDOUT.sync = true
server = TCPServer.new("127.0.0.1", 0)
token = ENV.fetch("SANDBOX_RELAY_TOKEN")
puts JSON.generate(port: server.addr[1])

loop do
  # EOF from docker exec closes the relay even while it is idle.
  ready = IO.select([server, STDIN]).first
  break if ready.include?(STDIN)
  client = server.accept
  begin
    line = client.gets or next
    method, path, = line.split
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(":", 2)
      headers[key.downcase] = value.to_s.strip
    end
    raise "Unauthorized" unless headers["authorization"] == "Bearer #{token}"
    raise "Unexpected route" unless method == "POST" && path == "/v1/chat/completions"
    size = Integer(headers.fetch("content-length"))
    raise "Invalid size" unless size.between?(1, 16 * 1024 * 1024)
    body = client.read(size)
    raise "Incomplete body" unless body && body.bytesize == size
    request = JSON.parse(body)
    raise "Streaming unsupported" if request["stream"]
    puts JSON.generate(request: request)
    response = JSON.parse(STDIN.gets || raise("Host relay disconnected"))
    status = Integer(response.fetch("status"))
    body = response.fetch("body")
  rescue StandardError => error
    status = 502
    body = JSON.generate(error: { message: error.message })
  ensure
    if status && body
      client.write("HTTP/1.1 #{status} Response\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n")
      client.write(body)
    end
    client.close
    status = body = nil
  end
end
