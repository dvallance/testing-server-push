require 'sinatra'
require 'sinatra/streaming'
require 'slim'

set server: 'thin'
set connections: []

class MyConnection
  attr_accessor :channel, :out

  def initialize channel, out
    self.channel = channel
    self.out = out
  end
end

get '/index' do
 File.read(File.join('public', 'index.html'))
end

get '/view/:channel' do
  slim :view
end

get '/stream/:channel', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << MyConnection.new(params[:channel], out)
    out.callback { settings.connections.delete_if{|conn| conn.out == out }}
  end
end

post '/put/:channel' do
  settings.connections.select{|conn| conn.channel == params[:channel]}.each{ |conn| conn.out << "data: #{params[:msg]}\n\n"}
  204
end

post '/all' do
  settings.connections.each{ |conn| conn.out << "data: #{params[:msg]}\n\n"}
  204
end
