# from www.github.com/trackzero/aws-ruby-utilities
# Script will back up all volumes in the current region
# assumes presence of valid credentials
# Snapshots will be named as YY.MM.DD.TAG
#   TAG is volume Name, if tag not specified on volume, then TAG uses the Name tag of attached instance.
#   If both are blank, TAG is UNTAGGED.

require 'json'
require 'open-uri'
require 'cgi'
require 'aws-sdk-v1'

AWS.config(region: "us-east-1")
@ec2 = AWS::EC2.new

def FindAttachments(vol)
		if vol.attachments.any?
			raise 'Unexpected plurality of attachments.' if vol.attachments.count > 1
			vol.attachments.each do |attachment|
				return attachment.instance.instance_id
			end
		else
			return "NOT_ATTACHED"
		end
end

def CreateSnapshot(vol)
	snapshot_name = SnapshotName(vol)
	vol.create_snapshot(snapshot_name)
    puts snapshot_name + " created."
end

def SnapshotName(vol)
	time=DateTime.now
	time=time.strftime("%Y.%m.%d")
	if vol.tags.Name 
		name_string = vol.tags.Name
	else
		inst_id = FindAttachments(vol)
		if inst_id == "NOT_ATTACHED"
			name_string = "DETACHED"
		else
			this_instance = @ec2.instances[inst_id]
			if this_instance.tags.Name
				name_string = this_instance.tags.Name
			else
				name_string = "UNTAGGED"
			end
		end
	end

    return time.to_s + "." + name_string.to_s + "." + "Snapshot"
end

@ec2.volumes.each do |vol|
	CreateSnapshot(vol)
end

