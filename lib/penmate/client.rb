file_name = ARGV[0] or exit
FileUtils.touch file_name
file_content = File.read file_name

result = Net::HTTP.post_form(URI.parse("http://localhost:remote_port/"), {:n => file_name, :c => file_content})
result.is_a? Net::HTTPSuccess or result.error!
edited_content = result.body

edited_content == file_content or edited_content.empty? or open(file_name, "w") { |handle| handle.write edited_content }
