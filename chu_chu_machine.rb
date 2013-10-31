#!/usr/bin/env ruby

require 'optparse'
require 'open-uri'
require 'uri'


OPTS = {
  encoding: 'utf-8',  # Use to Encoding.find
  interval: 1
}

OptionParser.new do |parser|
  parser.on('-e', '--encoding ENCODING') {|v| OPTS[:encoding] = v }
  parser.on('-i', '--interval SECONDS') {|v| OPTS[:interval] = v.to_i }
  parser.parse!(ARGV)
end

BASE_URL = ARGV[0]
TARGET_EXT = ARGV[1]
BASE_FILE_NAME = File.basename(BASE_URL) + '.txt'

open(BASE_FILE_NAME, 'wb') do |output|
  open(BASE_URL) {|data| output.write(data.read) }
end

File.read(
  BASE_FILE_NAME,
  encoding: Encoding.find(OPTS[:encoding])
).scan(/href=['"]([^'"]+)['"]/i).uniq.each do |href|

  uriOrPath = href[0]

  next unless /\.#{TARGET_EXT}$/.match(uriOrPath)

  puts "Find \"#{uriOrPath}\" .."
  if /^(https?|ftp)/i.match uriOrPath
    uri = uriOrPath
  else
    uri = URI.join(BASE_URL, uriOrPath).to_s
  end
  puts "Convert to \"#{uri}\" .."

  file_name = File.basename uri
  puts "Start downloading \"#{file_name}\" .."
  open(file_name, 'wb') do |output|
    open(uri) {|data| output.write(data.read) }
  end
  puts "Complete!"

  sleep OPTS[:interval]
end
