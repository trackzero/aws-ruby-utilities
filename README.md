aws-ruby-utilities
==================
-----
### 2023-May-11: Archiving repository, this code is old. :D
-----

<B><I>Tools &amp; utilities for AWS, written in Ruby.</b></I>


<h2>backupmyvolumes.rb</h2>
Script will back up all volumes in the active region (eg: using <code>AWS_REGION</code> environment variable)

Assumes presence of valid credentials, whether using a shared credentials file, ec2 instance role (preferred), or environment variables.

Snapshots will be named as <code>YY.MM.DD.TAG</code>
  * TAG is volume tag Name
  * if tag not specified on volume, then TAG uses the Name tag of instance to which volume is attached.
  * If both are blank, TAG will say UNTAGGED.

<H2>S3TempUploader.rb</h2>
Running this script creates a local "upload.html" file, good for 24 hours, to allow secure uploads via browser to a target S3 bucket/folder.  You can send the resulting upload.html (not the S3TempUploader.rb script!!!) file to others; they will be able to upload to your target location without needing access to your secret key.

Adjust the "t" variable if you want the uploader to be valid for more than 24 hours.

Note: you must specify your own access key/secret key. The IAM user you create should ONLY have access to write to the target S3 bucket/folder.  Policy attached to user will look something like this:
<pre>
     {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "S3Uploader",
          "Effect": "Allow",
          "Action": [
            "s3:PutObject"
          ],
          "Resource": [
            "arn:aws:s3:::YOURBUCKET/YOURFOLDER/*"
          ]
        }
      ]
    }
</pre>

<h2>enable-mfa-delete.rb</h2>
Enable a bucket for MFA delete.

To use:
* Uses virtual MFA device enabled on the root account.
* Replace VARIABLES with valid strings.
* Script will prompt for bucket name and current token value.
* Must run using root access keys; doesn't work as an IAM user.

<b><i>PSA: Don't forget to disable root access keys when you're done with 'em.</i></b>
