#!/usr/bin/ruby
Dir.foreach(ARGV[0]) do |i|
  if i.include? "bread"
   puts i
  end
end
