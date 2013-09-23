require 'goliath'
class Body
  include EM::Deferrable
  
  def each(&block)
    @callback = block
  end

  def write(data, id = nil)
    @callback.call(data)
  end
end

class App < Goliath::API

  def initialize()
    @dave = Body.new
  end

  puts "START: #{@body}"
  def response(env)
    case env['PATH_INFO']
      when '/index'
        [200, {}, File.open("app.html", "rb").read]
      when '/push'
        @dave.write("id: 1\ndata: Hello\nenvent:a\n\n") 
      when '/stream'
        puts "STREAM: #{@dave}"

        [200,{"Content-Type" => "text/event-stream", "Connection" => "keepalive", "Cache-Control" => "no-cache, no-store"}, @dave ]
      else
        raise Goliath::Validation::NotFoundError
    end
  end
end

