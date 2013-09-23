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
  def response(env)
    case env['PATH_INFO']
      when '/hello'
        [200, {}, File.open("app.html", "rb").read]
      when '/push'

      when '/stream'
        i = 1
        pt = EM.add_periodic_timer(1) do
          env.stream_send("id: #{i}\ndata: #{i}\nevent:#{i % 2 == 0 ? 'a' : 'b'}\n\n")
          i += 1
        end

        EM.add_timer(5) do
          pt.cancel
          #env.stream_send("DONE! Davey\n\n\n\n")
          env.stream_close
        end
        [200,{"Content-Type" => "text/event-stream", "Connection" => "keepalive", "Cache-Control" => "no-cache, no-store"},Goliath::Response::STREAMING]
      else
        raise Goliath::Validation::NotFoundError
    end

  end
end

