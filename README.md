📰 Serverless AI Haber Botu (Terraform & AWS)

Bu proje, AWS üzerinde çalışan, tamamen sunucusuz (serverless) bir yapay zeka haber botudur. Terraform kullanılarak "Infrastructure as Code" (IaC) prensibiyle geliştirilmiştir.

Bot, belirli kaynaklardan haberleri toplar, Yapay Zeka (AWS Bedrock) ile özetler ve AWS Polly kullanarak bunları sesli "Podcast" formatına dönüştürür.

🚀 Mimari ve Teknolojiler

Bu proje aşağıdaki AWS hizmetlerini otomatik olarak kurar ve yapılandırır:

Terraform: Tüm altyapının kod ile yönetilmesi.

GitHub Actions: CI/CD süreçleri ve otomatik deployment.

AWS CodePipeline: Lambda fonksiyonlarının sürekli dağıtımı.

AWS Lambda: Haber toplama ve işleme (Python).

AWS Bedrock: Haber metinlerinin AI ile özetlenmesi.

AWS Polly: Metnin doğal insan sesine dönüştürülmesi.

Amazon S3: Ses dosyalarının ve Terraform state'inin saklanması.

Amazon DynamoDB: İşlenen haberlerin takibi (Mükerrerliği önleme).

Amazon EventBridge: Botun her sabah otomatik tetiklenmesi.

📂 Proje Yapısı

.
├── .github/workflows/   # GitHub Actions (CI/CD) tanımları
├── news-terraform/      # Terraform altyapı kodları
│   ├── main.tf          # Ana AWS kaynakları (Lambda, IAM, DynamoDB vb.)
│   ├── pipeline.tf      # AWS CodePipeline tanımları
│   ├── variables.tf     # Değişken tanımları
│   └── outputs.tf       # Çıktı değerleri
└── README.md            # Proje dokümantasyonu


🛠️ Kurulum ve Dağıtım (Deployment)

Bu proje CI/CD ile otomatize edilmiştir. Manuel kuruluma gerek yoktur.

Bu repoyu Fork edin veya klonlayın.

GitHub Reposunun Settings > Secrets and variables > Actions kısmına gidin.

Aşağıdaki Secret'ları ekleyin:

AWS_ACCESS_KEY_ID: AWS Erişim Anahtarınız

AWS_SECRET_ACCESS_KEY: AWS Gizli Anahtarınız

Kodu main dalına push ettiğinizde sistem otomatik olarak kurulacaktır.

🧪 Manuel Çalıştırma (Opsiyonel)

Eğer Terraform'u yerel bilgisayarınızdan çalıştırmak isterseniz:

cd news-terraform
terraform init
terraform plan
terraform apply


📜 Lisans

Bu proje MIT lisansı ile lisanslanmıştır.