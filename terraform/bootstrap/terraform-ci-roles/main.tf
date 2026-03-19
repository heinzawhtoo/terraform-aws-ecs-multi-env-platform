data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::066506852481:oidc-provider/token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "terraform_dev" {
  name               = var.dev_role_name
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
}

resource "aws_iam_role" "terraform_prod" {
  name               = var.prod_role_name
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
}

data "aws_iam_policy_document" "terraform_dev_permissions" {
  statement {
    sid    = "AllowStsCallerIdentity"
    effect = "Allow"

    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowStateBucketList"
    effect = "Allow"

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1"]
  }

  statement {
    sid    = "AllowDevStateObjectAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1/envs/dev/terraform.tfstate",
      "arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1/envs/dev/terraform.tfstate.tflock"
    ]
  }
}

data "aws_iam_policy_document" "terraform_prod_permissions" {
  statement {
    sid    = "AllowStsCallerIdentity"
    effect = "Allow"

    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowStateBucketList"
    effect = "Allow"

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1"]
  }

  statement {
    sid    = "AllowProdStateObjectAccess"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1/envs/prod/terraform.tfstate",
      "arn:aws:s3:::heinzawhtoo-tf-state-066506852481-apse1/envs/prod/terraform.tfstate.tflock"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_dev_permissions" {
  name   = "${var.dev_role_name}-backend"
  role   = aws_iam_role.terraform_dev.id
  policy = data.aws_iam_policy_document.terraform_dev_permissions.json
}

resource "aws_iam_role_policy" "terraform_prod_permissions" {
  name   = "${var.prod_role_name}-backend"
  role   = aws_iam_role.terraform_prod.id
  policy = data.aws_iam_policy_document.terraform_prod_permissions.json
}