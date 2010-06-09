require 'rubygems'
require 'sinatra/base'
require 'penmate/compress.rb'

$remote_port = (10000 + rand * 50000).to_i.to_s
$editor_command = "mate -w"

def client_code
  client_source = File.read(File.join(File.dirname(__FILE__), "client.rb"))
  raise "single quotes in client.rb" if client_source.include?("'")
  compress(client_source).gsub("remote_port", $remote_port)
end

def shell_command
  "function mate { echo '#{client_code}'|ruby -w -rnet/http -rfileutils - $@;}"
end

class PenmateServer < Sinatra::Base
  get '/' do
    "penmate server on #{`hostname`}"
  end

  get '/port' do
    $remote_port
  end

  get '/command' do
    shell_command
  end

  post '/' do
    name = params[:n]
    content = params[:c]
    raise "No Name given" unless name
    basename = name.split("/").last

    Dir.mktmpdir do |dir|
      filename = "#{dir}/#{basename}"
      tempfile = File.open(filename, "w+")
      tempfile.write(content)
      tempfile.close

      %x{#{$editor_command} #{tempfile.path}}
      tempfile = File.open(filename)
      tempfile.read.tap do
        tempfile.close
      end
     end
  end
end
