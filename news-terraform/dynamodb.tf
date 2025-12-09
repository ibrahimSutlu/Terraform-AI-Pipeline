resource "aws_dynamodb_table" "news_table" {
  name           = "DailyDigests"
  billing_mode   = "PAY_PER_REQUEST" # Kullandığın kadar öde
  hash_key       = "category"
  range_key      = "news_id"

  attribute {
    name = "category"
    type = "S"
  }

  attribute {
    name = "news_id"
    type = "S"
  }

  tags = {
    Project = "HaberBulteni"
  }
}