#!/opt/opscode/embedded/bin/ruby
require "fileutils"

permision_file = File.stat(ENV["SSL_CRT"]).mode.to_s(8).split("")[-4..-1].join.to_i(8)
if permision_file == 420
  path = "/opt/opscode/custom_ssl"
  FileUtils.cp(ENV["SSL_CRT"], "#{path}.crt")
  FileUtils.cp(ENV["SSL_KEY"], "#{path}.key")
  File.chmod(0766,"#{path}.crt")
  File.chmod(0766,"#{path}.key")
  ENV["SSL_CRT"] = "#{path}.crt"
  ENV["SSL_KEY"] = "#{path}.key"
end

if ENV["SSL_CRT"].nil? || ENV["SSL_KEY"].nil?
  puts "certificate variables not configured"
  exit
end
unless  File.exist?(ENV["SSL_CRT"]) && File.exist?(ENV["SSL_KEY"])
  puts "Certificate files does not exist"
  exit
end

File.open("/opt/opscode/embedded/cookbooks/private-chef/attributes/default.rb", 'r+') do |file|
  lines = file.each_line.to_a
  lines.each_with_index do |line,index|
    check_l = line.split("'")
    if check_l[5] == "ssl_certificate"
      r_line = line.split("=")
      unless r_line[1].to_s.include? "nil"
        puts "already configured"
        exit
      end
      lines[index] = "#{r_line[0]}= \"#{r_line[1].gsub(" nil","#{ENV["SSL_CRT"]}").gsub("\n","\"\n")}"
    end
    if check_l[5] == "ssl_certificate_key"
      r_line = line.split("=")
      lines[index] = "#{r_line[0]}= \"#{r_line[1].gsub(" nil","#{ENV["SSL_KEY"]}").gsub("\n","\"\n")}"
    end
  file.rewind
  file.write(lines.join)
  end
end
