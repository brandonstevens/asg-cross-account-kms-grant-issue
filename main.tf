terraform {
  required_version = "~> 0.11.0"
}

provider "aws" {
  alias   = "security"
  version = "~> 1.14.0"

  region  = "us-west-2"
  profile = "kms-issue-security"
}

provider "aws" {
  alias   = "dev"
  version = "~> 1.14.0"

  region  = "us-west-2"
  profile = "kms-issue-dev"
}

data "aws_iam_role" "asg" {
  provider = "aws.dev"
  name     = "AWSServiceRoleForAutoScaling"
}

data "aws_caller_identity" "security" {
  provider = "aws.security"
}

data "aws_caller_identity" "dev" {
  provider = "aws.dev"
}

data "aws_iam_policy_document" "key_policy" {
  provider = "aws.security"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.security.account_id}:root"]
    }

    actions = [
      "kms:*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "AllowCreationOfGrant"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.dev.account_id}:root"]
    }

    actions = [
      "kms:CreateGrant",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_kms_key" "main" {
  provider                = "aws.security"
  description             = "KMS key 1"
  policy                  = "${data.aws_iam_policy_document.key_policy.json}"
  deletion_window_in_days = 10
}

resource "aws_kms_grant" "by_key_id" {
  provider          = "aws.dev"
  name              = "by_key_id"
  key_id            = "${aws_kms_key.main.key_id}"
  grantee_principal = "${data.aws_iam_role.asg.arn}"

  operations = [
    "Encrypt",
    "Decrypt",
    "ReEncryptFrom",
    "ReEncryptTo",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "DescribeKey",
    "CreateGrant",
  ]
}

resource "aws_kms_grant" "by_arn" {
  provider          = "aws.dev"
  name              = "by_arn"
  key_id            = "${aws_kms_key.main.arn}"
  grantee_principal = "${data.aws_iam_role.asg.arn}"

  operations = [
    "Encrypt",
    "Decrypt",
    "ReEncryptFrom",
    "ReEncryptTo",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "DescribeKey",
    "CreateGrant",
  ]
}
