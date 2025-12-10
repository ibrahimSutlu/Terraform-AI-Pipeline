# 📰 Serverless AI Haber Botu (Terraform & AWS)

# Bu proje, AWS üzerinde çalışan tamamen sunucusuz (serverless) bir yapay zeka haber botudur.
# Terraform kullanılarak Infrastructure as Code (IaC) prensibiyle geliştirilmiştir.

# Bot, haberleri toplar → AWS Bedrock ile özetler → AWS Polly ile “podcast” sesine dönüştürür.


# 🚀 Mimari ve Teknolojiler
# ------------------------------------------------
# Terraform – Altyapının kod ile yönetilmesi
# GitHub Actions – CI/CD süreçleri ve otomatik deployment
# AWS CodePipeline – Lambda fonksiyonlarının sürekli dağıtımı
# AWS Lambda – Haber toplama ve işleme (Python)
# AWS Bedrock – AI ile haber özetleme
# AWS Polly – Haberleri doğal insan sesine dönüştürme
# Amazon S3 – Ses dosyaları ve Terraform state depolama
# Amazon DynamoDB – İşlenmiş haber takibi (mükerrerliği önleme)
# Amazon EventBridge – Botun her sabah otomatik çalışması


# 📂 Proje Yapısı
# ------------------------------------------------
# .
# ├── .github/workflows/      # GitHub Actions tanımları
# ├── news-terraform/         # Terraform altyapı kodları
# │   ├── main.tf             # Lambda, IAM, DynamoDB vb.
# │   ├── pipeline.tf         # AWS CodePipeline tanımı
# │   ├── variables.tf        # Değişkenler
# │   └── outputs.tf          # Çıktı değerleri
# └── README.md               # Dokümantasyon


# 🛠️ Kurulum ve Dağıtım (Deployment)
# ------------------------------------------------
# Bu proje CI/CD ile tamamen otomatiktir.
# Manuel kurulum yapmanıza gerek yoktur.

# 1) Repoyu fork edin veya klonlayın.
# 2) GitHub → Settings → Secrets and variables → Actions kısmına girin.

# Eklenmesi gereken Secret'lar:
#   AWS_ACCESS_KEY_ID       = AWS erişim anahtarı
#   AWS_SECRET_ACCESS_KEY   = AWS gizli anahtarı

# 3) main dalına push edin → CI/CD otomatik kurulum yapacaktır.


# 🧪 Manuel Çalıştırma (Opsiyonel)
# ------------------------------------------------
cd news-terraform
terraform init
terraform plan
terraform apply


# 📜 Lisans
# ------------------------------------------------
# Bu proje MIT Lisansı ile lisanslanmıştır.
