aws-ruby-utilities
==================

<B><I>Tools &amp; utilities for AWS, written in Ruby.</b></I>


<h2>backupmyvolumes.rb</h2>
Script will back up all volumes in the active region (eg: using <code>AWS_REGION</code> environment variable)

Assumes presence of valid credentials, whether using a shared credentials file, ec2 instance role (preferred), or environment variables.

Snapshots will be named as <code>YY.MM.DD.TAG</code>
  * TAG is volume tag Name
  * if tag not specified on volume, then TAG uses the Name tag of instance to which volume is attached.
  * If both are blank, TAG will say UNTAGGED.


<h2>enable-mfa-delete.rb</h2>
Enable a bucket for MFA delete.

To use:
* Uses virtual MFA device enabled on the root account.
* Replace VARIABLES with valid strings.
* Script will prompt for bucket name and current token value.
* Must run using root access keys; doesn't work as an IAM user.

<b><i>PSA: Don't forget to disable root access keys when you're done with 'em.</i></b>
