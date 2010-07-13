require "net/http"
require "fileutils"
file_name = ARGV[0] or exit
FileUtils.touch file_name
file_content = File.read file_name

url = URI.parse("http://localhost:remote_port/")
req = Net::HTTP::Post.new(url.path)
req.set_form_data({:n => file_name, :c => file_content})
result = Net::HTTP.new(url.host, url.port).start {|http| http.read_timeout = 86400; http.request(req) }
result.is_a? Net::HTTPSuccess or result.error!
edited_content = result.body

edited_content == file_content or edited_content.empty? or open(file_name, "w") { |handle| handle.write edited_content }
