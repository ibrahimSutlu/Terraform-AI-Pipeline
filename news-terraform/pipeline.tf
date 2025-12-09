#
# HABER BOTU CI/CD PIPELINE KAYNAKLARI
#

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "haber-botu-ci-cd-artifacts-${random_string.suffix.result}"
  tags = {
    Name = "HaberBotu-Pipeline-Artifacts"
  }
}

# 1. Pipeline IAM Rolü
resource "aws_iam_role" "codepipeline_role" {
  name = "HaberBotu-CodePipeline-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# 2. Pipeline Politikası
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "HaberBotu-Pipeline-Policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.artifact_bucket.arn,
          "${aws_s3_bucket.artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration"
        ],
        Resource = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:HaberGetiriciTF"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# 3. CodePipeline Tanımı
resource "aws_codepipeline" "haber_botu_ci_cd" {
  name     = "HaberBotu-CI-CD" # DÜZELTME: Boşluklar kaldırıldı
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        # DİKKAT: Buradaki ARN ve Repo ID'yi kendi bilgilerinizle değiştirin
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:123456789012:connection/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        FullRepositoryId = "sutluibrahim3-netizen/Terraform-AI-Pipeline"
        BranchName       = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "DeployLambda"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "Lambda"
      version         = "1"
      input_artifacts = ["SourceOutput"]

      configuration = {
        FunctionName = "HaberGetiriciTF"
      }
    }
  }
}