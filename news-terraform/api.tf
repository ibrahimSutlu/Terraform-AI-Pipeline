# API Gateway için REST API Oluştur
resource "aws_api_gateway_rest_api" "api" {
  name        = "NewsAPI-REST-TF"
  description = "React uygulamasının haberleri çektiği API"
}

# 'news' Kaynağını (Resource) Tanımla
resource "aws_api_gateway_resource" "news_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "news"
}

# GET Metodunu Tanımla
resource "aws_api_gateway_method" "news_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.news_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda Entegrasyonu
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.news_resource.id
  http_method             = aws_api_gateway_method.news_get_method.http_method
  integration_http_method = "POST" # Lambda Proxy için POST kullanır
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.news_fetcher.invoke_arn
}

# CORS için OPTIONS Metodunu Tanımla (Gerekli)
resource "aws_api_gateway_method" "news_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.news_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS Entegrasyonu (CORS'u aktif etmek için Mock Integration kullanılır)
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.news_resource.id
  http_method             = aws_api_gateway_method.news_options_method.http_method
  type                    = "MOCK"
  integration_http_method = "OPTIONS"
  
  # Mock yanıtının tüm header'ları döndürmesini sağla
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# OPTIONS Yanıtı (Response)
resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.news_resource.id
  http_method = aws_api_gateway_method.news_options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  # CORS Header'ları Ekle
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS Yanıt Entegrasyonu (Integration Response)
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.news_resource.id
  http_method = aws_api_gateway_method.news_options_method.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code
  
  # CORS Header değerlerini atama
  response_templates = {
    "application/json" = ""
  }
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  
  depends_on = [
    aws_api_gateway_method.news_options_method,
    aws_api_gateway_integration.options_integration
  ]
}

# Dağıtım (Deployment)
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # stage_name BURADAN KALDIRILDI

  # Bu triggers bloğu çok önemlidir.
  # API'de (Method, Integration vb.) değişiklik yaparsanız
  # Terraform'un yeni bir dağıtım (Redeploy) yapmasını sağlar.
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.news_resource.id,
      aws_api_gateway_method.news_get_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration_response.options_integration_response
  ]

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

# Lambda'nın API Gateway tarafından çağrılması için izin
resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.news_fetcher.function_name
  principal     = "apigateway.amazonaws.com"

  # İzin, API'nin tüm yürütme yollarını kapsamalı
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}