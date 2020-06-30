
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
    privileged_mode             = "true"
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
      output_artifacts = ["${var.app}"]

      configuration = {
        Owner                = var.github_org
        Repo                 = var.project
        PollForSourceChanges = "true"
        Branch               = var.branch
        OAuthToken           = var.github_token
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
      }
    }
  }


}
