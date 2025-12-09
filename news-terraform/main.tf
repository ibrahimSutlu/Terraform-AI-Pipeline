terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "haber-botu-terraform-state-ibrahim" # BURAYA AZ ÖNCE AÇTIĞIN KOVA ADINI YAZ
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# ==========================================
# S3 BUCKET (Ses Dosyaları İçin)
# ==========================================
# ==========================================
# S3 BUCKET VE İZİNLER (DÜZELTİLMİŞ)
# ==========================================
# ==========================================
# 2. S3 BUCKET (Ses Dosyaları - TAM PUBLIC)
# ==========================================
resource "aws_s3_bucket" "audio_bucket" {
  bucket_prefix = "haber-sesleri-"
  force_destroy = true
}

# Public Erişim Engelini Kaldır
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.audio_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CORS Ayarı (React Erişebilsin Diye)
resource "aws_s3_bucket_cors_configuration" "audio_cors" {
  bucket = aws_s3_bucket.audio_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# Kova Politikası: HERKESE OKUMA İZNİ (GetObject)
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.audio_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.audio_bucket.arn}/*"
      },
    ]
  })
}