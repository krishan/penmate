require 'rubygems'
require 'sinatra/base'

$remote_port = (10000 + rand * 50000).to_i.to_s
$editor_command = "mate -w"

client_source = File.read(File.join(File.expand_path(File.dirname(__FILE__)), "client.rb"))
client_source.gsub!("remote_port", $remote_port).gsub!("\n", ";")
raise "single quotes in client.rb" if client_source.include?("'")

$shell_command = <<-EOS
MATE_SRC='#{client_source}'
function mate { echo $MATE_SRC|ruby -w - $@ & }
`which clear`
echo 'penmate installed, usage: mate <file-to-edit>'
echo
EOS

$shell_command.gsub!("\n", ";")
$shell_command.gsub!("& }", "&\n}")
$shell_command << "\n"

class PenmateServer < Sinatra::Base
  get '/' do
    "penmate server on #{`hostname`}"
  end

  get '/port' do
    $remote_port
  end

  get '/command' do
    $shell_command
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
