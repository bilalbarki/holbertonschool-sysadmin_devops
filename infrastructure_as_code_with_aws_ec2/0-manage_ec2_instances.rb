#!/usr/bin/ruby

require 'aws-sdk'
require 'optparse'
require 'yaml'

options = {}
help = ""

OptionParser.new do |opts|
	opts.banner = "Usage: 0-manage_ec2_instances.rb [options]"

	# main actions
	opts.on('-a','--action [ACTION]', [:launch, :stop, :start, :terminate, :status, :change_name], "Select action from launch, stop, start, terminate, status, change_name") do |t|
		options[:action] = t
	end

	# for server id
	opts.on('-i', '--instance_id [INSTANCE_ID]', 'Provide the server id') do |s|
		options[:instance_id] = s
	end

	#to input name
	opts.on('-n', '--name [name]', 'Provide the name for changing it') do |n|
		options[:n] = n
	end

	# for verbose
	opts.on('-v', '--verbose', 'Provide extra information') do |v|
		options[:verbose] = v
	end

	# for help
	opts.on('-h', '--help', 'Show help message') do |v|
		puts opts
		exit
	end

	help = opts

end.parse!

# Check if an action was passed by the user
if options[:action].nil? then
	puts help
	exit
end

# load yaml file
config = YAML.load_file('config.yaml')

client = Aws::EC2::Client.new({
		region: 'us-west-2',
		access_key_id: config['access_key_id'],
		secret_access_key: config['secret_access_key']
	})

################ LAUNCH ################
if options[:action] == :launch then
	ec2 = Aws::EC2::Resource.new(client: client)
	instance = ec2.create_instances({
  		image_id: config["image_id"],
  		min_count: 1,
  		max_count: 1,
  		key_name: config['key_pair'],
  		security_group_ids: config["security_group_ids"],
  		instance_type: config['instance_type'],
  		placement: {
    		availability_zone: config['us-west-2a']
  		}
	})

	# Wait for the instance to be created, running, and passed status checks
	ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance[0].id]})
	inst = instance[0]
	inst.load()
	puts inst.id, inst.public_dns_name

################# STOP #################
elsif options[:action] == :stop then
	raise OptionParser::MissingArgument, "Error: INSTANCE_ID is required" if options[:instance_id].nil?
	client.stop_instances({
		  dry_run: false,
		  instance_ids: [options[:instance_id]],
		  force: false,
		})

################ START ################
elsif options[:action] == :start then
	raise OptionParser::MissingArgument, "Error: INSTANCE_ID is required" if options[:instance_id].nil?
	out = client.start_instances({
		  instance_ids: [options[:instance_id]],
		  dry_run: false,
		})
	out = client.wait_until(:instance_running, instance_ids:[options[:instance_id]])
	dns_name = out.reservations[0].instances[0].public_dns_name
	puts dns_name


############## TERMINATE ##############
elsif options[:action] == :terminate then
	raise OptionParser::MissingArgument, "Error: INSTANCE_ID is required" if options[:instance_id].nil?
	client.terminate_instances({
		  dry_run: false,
		  instance_ids: [options[:instance_id]],
	})

elsif options[:action] == :status then
	raise OptionParser::MissingArgument, "Error: INSTANCE_ID is required" if options[:instance_id].nil?
	ec2 = Aws::EC2::Resource.new(client: client)
	i = ec2.instance(options[:instance_id])
	if i.exists?
		puts i.state.name
	end

elsif options[:action] == :change_name then
	raise OptionParser::MissingArgument, "Error: INSTANCE_ID is required" if options[:instance_id].nil?
	raise OptionParser::MissingArgument, "Error: NAME is required" if options[:n].nil?

	ec2 = Aws::EC2::Resource.new(client: client)
	i = ec2.instance(options[:instance_id])
	if i.exists?
		i.create_tags({ tags: [{ key: 'Name', value: options[:n] }]})
	end
end
