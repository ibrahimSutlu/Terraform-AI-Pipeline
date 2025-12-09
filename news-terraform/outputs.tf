output "api_endpoint" {
  description = "React uygulamasının kullanacağı API adresi"
  
  # HATA ÇÖZÜMÜ:
  # 'aws_api_gateway_deployment' yerine 'aws_api_gateway_stage' kullanıyoruz.
  # Çünkü invoke_url özelliği Stage kaynağında bulunur.
  value       = "${aws_api_gateway_stage.prod_stage.invoke_url}/news"
}

output "s3_audio_bucket" {
  description = "Ses dosyalarının yüklendiği S3 bucket adı"
  value       = aws_s3_bucket.audio_bucket.bucket
}