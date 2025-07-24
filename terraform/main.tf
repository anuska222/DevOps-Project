data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.region
}

# S3 bucket for storing artifacts
resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket = "${var.project_name}-artifact-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "CodePipeline Artifact Bucket"
    Environment = "Dev"
  }
}


# CodeBuild project
resource "aws_codebuild_project" "codebuild" {
  name          = "${var.project_name}-build"
  description   = "Build project for ${var.project_name}"
  build_timeout = 5

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    Environment = "Dev"
  }
}

# CodePipeline definition
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:ap-south-1:562078167718:connection/498d0674-20b2-45b0-8f60-8528cd6687c2"
        FullRepositoryId = "anuska222/DevOps-Masters-Project"
        BranchName       = "main"
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  tags = {
    Environment = "Dev"
  }
}
