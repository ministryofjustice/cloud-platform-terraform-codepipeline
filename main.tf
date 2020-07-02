
resource "aws_codebuild_project" "project" {
  name          = var.project
  description   = "${var.project} CodeBuild Project"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = var.spec_location
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codepipeline" "project" {
  name     = "${var.app}-pipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = var.artifact_store
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source" 
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = [var.app]

      configuration = {
        Owner                = var.github_org
        Repo                 = var.project
        PollForSourceChanges = "true"
        Branch               = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [var.app]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.project.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_VAR_cluster_name"
            value = var.cluster_name
            type  = "PLAINTEXT"
          },
          {
            name  = "TF_VAR_cluster_state_bucket"
            value = var.cluster_state_bucket
            type  = "PLAINTEXT"
          },
          {
            name  = "KOPS_STATE_STORE"
            value = var.kops_state_store
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    actions = [
      "s3:*",
      "codebuild:*",
      "cloudtrail:LookupEvents",
      "logs:*",
      "rds:*",
      "iam:GetUser",
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:UpdateUser",
      "iam:ListAccessKeys",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:PutUserPolicy",
      "iam:GetUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:ListGroupsForUser",
      "iam:PutUserPermissionsBoundary",
      "iam:GetPolicy",
      "iam:ListEntitiesForPolicy",
      "iam:GetPolicyVersion",
      "iam:DeleteUserPermissionsBoundary",
      "ec2:*",
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  name   = "codebuild-role-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}



