# Replace VARIABLES with valid strings.
# Will prompt for bucket name and current token value.
# Must run using root access keys; doesn't work as an IAM user.
# PSA: Don't forget to disable root access keys when you're done with 'em.

require 'aws-sdk-v1'

mfa_serial = 'arn:aws:iam::YOURACCOUNTNUMBER:mfa/root-account-mfa-device'

s3= AWS::S3.new(
  :access_key_id => 'ROOT_ACCESSKEYID',
  :secret_access_key => 'ROOT_SECRETACCESSKEY')

puts 'Bucket: '
bucket_name = gets.chomp
puts 'Current Token Value: '
mfa_token = gets.chomp
bucket = s3.buckets[bucket_name]
bucket.enable_versioning(
      mfa_delete: 'Enabled',
      mfa: mfa_serial + " " + mfa_token)
