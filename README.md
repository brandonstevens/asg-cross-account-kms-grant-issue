# asg-cross-account-kms-grant-issue
Code for reproducing https://github.com/terraform-providers/terraform-provider-aws/issues/4141. This also partially implements the steps necessary for Case 2 of [Using Encrypted EBS Volumes in Auto Scaling Groups with Service-Linked Role](https://forums.aws.amazon.com/thread.jspa?threadID=277523).

## Getting Started

Create named profiles for AWS called _kms-issue-security_ and _kms-issue-dev_ and configure its credentials. Note, profiles must be for different AWS accounts to reproduce the issue.

Initialize project and get dependencies
```
terraform init
```

## Running the Example

```
terraform plan -out example.plan
terraform apply example.plan

...

Error: Error applying plan:

2 error(s) occurred:

* aws_kms_grant.by_key_id: 1 error(s) occurred:

* aws_kms_grant.by_key_id: NotFoundException: Key 'arn:aws:kms:us-west-2:081480024710:key/84f459e6-2166-4317-bb6c-2bd479f42d29' does not exist
	status code: 400, request id: 2649a355-3cd9-11e8-8f25-d50620697f11
* aws_kms_grant.by_arn: 1 error(s) occurred:

* aws_kms_grant.by_arn: unexpected format of ID ("arn:aws:kms:us-west-2:598202605839:key/84f459e6-2166-4317-bb6c-2bd479f42d29:74cdd4a0d511d2e67f22d900e59456d64202c34e4f5ffa5e90dd72bee6889550"), expected KeyID:GrantID

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.

```

## Clean Up

```
terraform destroy
```
