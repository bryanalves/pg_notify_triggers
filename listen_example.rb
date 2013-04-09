#!/urs/bin/env ruby
require 'pg'
require 'json'

args = ARGV
connstring = args.shift

conn = PGconn.open(connstring)
args.each do |a|
  conn.exec("LISTEN #{conn.escape(a)}")
end

while true
  res = conn.wait_for_notify do |event, pid, payload|
    puts JSON.parse(payload)
  end
end
