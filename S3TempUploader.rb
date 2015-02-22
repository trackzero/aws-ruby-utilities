require 'base64'
require 'openssl'
require 'date'
require 'time'

#Credentials for an IAM user with limited access rights....eg, write-only to target bucket/key.
#TODO: Change this to use STS temp creds
@accesskey = 'AKIAIAAAAAAEXAMPLE'
aws_secret_key = 'ABCDEFGHIJKLMNO1234567890EXAMPLEKEY'

@bucket = 'yourS3uploadbucket' # => target bucket
@bkey = 'incoming/'  # => target folder
@region='us-east-1'
t = Time.now + (24*60*60) # => form expires in 24 hours (24*60*60)
@expy = Time.parse(t.to_s).utc.iso8601
@sar = 'http://www.example.com/success.html' # => redirect page when upload is successful. Use your own page here.
@thisday =  DateTime.now.strftime('%Y%m%d')
@xac = "#{@accesskey}/#{@thisday}/#{@region}/s3/aws4_request"

policy_document = <<"END"
{"expiration": "#{@expy}",
  "conditions": [
    {"bucket": "#{@bucket}"},
    ["starts-with", "$key", "#{@bkey}"],
    {"acl": "private"},
    {"success_action_redirect": "#{@sar}"},
    ["starts-with", "$Content-Type", ""],
    {"x-amz-credential": "#{@xac}"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "#{@thisday}T000000Z" }
  ]
}
END

policy = Base64.encode64(policy_document).gsub("\n","").strip()

def getSignatureKey key, dateStamp, regionName, serviceName
    kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
    kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
    kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
    kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")
    kSigning
end

def OutputDoc(pol,sig)
    doc = <<"ENDDOC"
    <html> 
      <head>
        <title>Secure Upload to #{@bucket} bucket...</title> 
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
      </head>

      <body> 
      <H2>Secure Upload to #{@bucket}</H2>
      <p>
      Form valid until <b>#{@expy}</b>.<BR>
    <p>
        <form action="https://#{@bucket}.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
          <input type="hidden" name="acl" value="private"> 
          <input type="hidden" name="key" value="incoming/${filename}">
          <input type="hidden" name="success_action_redirect" value="#{@sar}">
          <input type="hidden" name="policy" value="#{pol}">
          <input type="hidden" name="Content-Type" value="application/octet">
          <input type="hidden" name="x-amz-credential" value="#{@xac}">
          <input type="hidden" name="x-amz-algorithm" value="AWS4-HMAC-SHA256">
          <input type="hidden" name="x-amz-date" value="#{@thisday}T000000Z">
          <input type="hidden" name="x-amz-signature" value="#{sig}">

          File to upload to S3:<br><br> 
          <input name="file" type="file"> 
          <br> <p>
          <input type="submit" value="Upload File!"> 
        </form> 
      </body>
    </html>
ENDDOC
  File.write("upload.html",doc)
end

signkey = getSignatureKey(aws_secret_key,@thisday,@region,'s3')
signature=OpenSSL::HMAC.digest('sha256', signkey,policy)
signaturehex = signature.each_byte.map{|b| b.to_s(16).rjust(2,'0')}.join
OutputDoc(policy,signaturehex)
puts "Open upload.html in your default browser."
system("explorer upload.html")  # => Launch in default browser if you're on windows.
