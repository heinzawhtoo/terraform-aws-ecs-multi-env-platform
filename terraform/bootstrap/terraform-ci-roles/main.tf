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

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

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

  statement {
    sid    = "AllowTerraformAwsReadAccess"
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "elasticloadbalancing:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListTagsForResource",
      "ecr:GetAuthorizationToken",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:ListTagsForResource",
      "iam:GetRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "application-autoscaling:Describe*",
      "cloudwatch:DescribeAlarms"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformEc2NetworkingWrite"
    effect = "Allow"

    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRoute",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformAlbAccess"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformEcsAccess"
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformLogsAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:066506852481:log-group:/aws/ecs/terraform-aws-ecs-multi-env-platform-dev*"
    ]
  }

  statement {
    sid    = "AllowTerraformEcrAccess"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:066506852481:repository/terraform-aws-ecs-multi-env-platform*"
    ]
  }

  statement {
    sid    = "AllowTerraformAppAutoScalingAccess"
    effect = "Allow"

    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:TagResource",
      "application-autoscaling:UntagResource",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformPassOnlyProjectRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::066506852481:role/terraform-aws-ecs-multi-env-platform-dev-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "AllowTerraformManageOnlyProjectRoles"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy"
    ]

    resources = [
      "arn:aws:iam::066506852481:role/terraform-aws-ecs-multi-env-platform-dev-*"
    ]
  }

  statement {
    sid    = "AllowTerraformCreateServiceLinkedRoles"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "ecs.amazonaws.com",
        "ecs.application-autoscaling.amazonaws.com",
        "elasticloadbalancing.amazonaws.com"
      ]
    }
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

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

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

  statement {
    sid    = "AllowTerraformAwsReadAccess"
    effect = "Allow"

    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeManagedPrefixLists",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcAttribute",
      "elasticloadbalancing:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListTagsForResource",
      "ecr:GetAuthorizationToken",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:ListTagsForResource",
      "iam:GetRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "application-autoscaling:Describe*",
      "cloudwatch:DescribeAlarms"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformEc2NetworkingWrite"
    effect = "Allow"

    actions = [
      "ec2:AllocateAddress",
      "ec2:AssociateRouteTable",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVpc",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateRouteTable",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRoute",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformAlbAccess"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformEcsAccess"
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:UpdateService",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformLogsAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:DeleteRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:066506852481:log-group:/aws/ecs/terraform-aws-ecs-multi-env-platform-prod*"
    ]
  }

  statement {
    sid    = "AllowTerraformEcrAccess"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:066506852481:repository/terraform-aws-ecs-multi-env-platform*"
    ]
  }

  statement {
    sid    = "AllowTerraformAppAutoScalingAccess"
    effect = "Allow"

    actions = [
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy",
      "application-autoscaling:TagResource",
      "application-autoscaling:UntagResource",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowTerraformPassOnlyProjectRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::066506852481:role/terraform-aws-ecs-multi-env-platform-prod-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "AllowTerraformManageOnlyProjectRoles"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy"
    ]

    resources = [
      "arn:aws:iam::066506852481:role/terraform-aws-ecs-multi-env-platform-prod-*"
    ]
  }

  statement {
    sid    = "AllowTerraformCreateServiceLinkedRoles"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "ecs.amazonaws.com",
        "ecs.application-autoscaling.amazonaws.com",
        "elasticloadbalancing.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "terraform_dev_permissions" {
  name   = "${var.dev_role_name}-backend-and-platform"
  role   = aws_iam_role.terraform_dev.id
  policy = data.aws_iam_policy_document.terraform_dev_permissions.json
}

resource "aws_iam_role_policy" "terraform_prod_permissions" {
  name   = "${var.prod_role_name}-backend-and-platform"
  role   = aws_iam_role.terraform_prod.id
  policy = data.aws_iam_policy_document.terraform_prod_permissions.json
}