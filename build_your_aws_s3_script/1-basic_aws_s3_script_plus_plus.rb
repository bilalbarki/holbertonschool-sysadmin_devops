#!/usr/bin/ruby

require 'aws-sdk'
require 'optparse'
require 'yaml'

options = {}
help = ""

OptionParser.new do |opts|
	opts.banner = "Usage: 0-manage_ec2_instances.rb [options]"

	# for verbose
	opts.on('-v', '--verbose', 'Run verbosely') do |v|
		options[:verbose] = v
	end

	# for bucket name
	opts.on('-b', '--bucketname [BUCKET_NAME]', 'Name of the bucket to perform the action on') do |s|
		options[:bucketname] = s
	end

	# for file path
	opts.on('-f', '--filepath [FILE_PATH]', 'Path to the file to upload') do |n|
		options[:filepath] = n
	end

	# main actions
	opts.on('-a','--action [ACTION]', [:list, :upload, :delete, :download, :size], "Select action to perform [list, upload, delete, download]") do |t|
		options[:action] = t
	end

	help = opts

end.parse!

if options[:action].nil? then
	puts help
	exit
end

# load yaml file
config = YAML.load_file('config.yaml')

client = Aws::S3::Client.new({
		region: 'us-west-2',
		access_key_id: config['access_key_id'],
		secret_access_key: config['secret_access_key']
	})

if options[:action] == :list then
	if options[:bucketname] then
		resp = client.list_objects({
  			bucket: options[:bucketname], # required
		})
		resp.contents.each do |items|
			puts "#{items['key']} => #{items['etag']}"
			puts items['size']
		end
	else
		resp = client.list_buckets()
		resp.buckets.each do |bucket|
			puts bucket['name']
		end
	end

elsif options[:action] == :upload then
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:bucketname].nil?
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:filepath].nil?
	s3 = Aws::S3::Resource.new(client: client)
	bucket = s3.bucket(options[:bucketname])

	begin
	  bucket.object(File.basename options[:filepath]).upload_file(options[:filepath])
	end


elsif options[:action] == :delete then
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:bucketname].nil?
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:filepath].nil?
	#name = File.basename options[:filepath]
	resp = client.delete_object({
  		bucket: options[:bucketname], # required
  		key: options[:filepath], # required
	})

elsif options [:action] == :download then
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:bucketname].nil?
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:filepath].nil?
	name = File.basename options[:filepath]
	resp = client.get_object(
  		response_target: name,
  		bucket: options[:bucketname],
  		key: options[:filepath])

elsif options[:action] == :size then
	raise OptionParser::MissingArgument, "Error: bucketname is required" if options[:bucketname].nil?
	size = 0
	resp = client.list_objects({
			bucket: options[:bucketname], # required
	})
	resp.contents.each do |items|
		size += Integer(items['size'])
	end
	mo = (size/1048576.0).round(2) 
	puts "#{mo}Mo"
end