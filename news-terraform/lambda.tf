data "archive_file" "app_zip" {
  type        = "zip"
  source_file = "src/app.py"
  output_path = "app_function.zip"
}

data "archive_file" "ingestor_zip" {
  type        = "zip"
  source_file = "src/ingestor.py"
  output_path = "ingestor_function.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "haber_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_dynamo_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_bedrock_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_polly_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPollyFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "news_fetcher" {
  filename      = "app_function.zip"
  function_name = "HaberGetiriciTF"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"
  source_code_hash = data.archive_file.app_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.news_table.name
      AUDIO_BUCKET_NAME = aws_s3_bucket.audio_bucket.id 
    }
  }
}


resource "aws_lambda_function" "news_ingestor" {
  filename      = "ingestor_function.zip"
  function_name = "HaberToplayiciBotTF"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "ingestor.lambda_handler"
  runtime       = "python3.12"
  timeout       = 60 
  source_code_hash = data.archive_file.ingestor_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.news_table.name
      AUDIO_BUCKET_NAME = aws_s3_bucket.audio_bucket.id 
    }
  }
}


resource "aws_cloudwatch_event_rule" "every_morning" {
  name                = "her-iki-saatte-bir"
  description         = "Haber botunu tetikler"
  schedule_expression = "rate(2 hours)" 
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.every_morning.name
  target_id = "TriggerIngestor"
  arn       = aws_lambda_function.news_ingestor.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_ingestor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_morning.arn
}