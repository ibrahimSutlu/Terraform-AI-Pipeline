# 📰 Serverless AI Haber Botu (Terraform & AWS)

AWS üzerinde çalışan tamamen **sunucusuz (serverless)** bir yapay zeka haber botudur. Tüm altyapı **Terraform** ile yönetilir ve CI/CD süreçleri otomatik olarak GitHub Actions + CodePipeline üzerinden çalışır.

Bot; haberleri toplar → **AWS Bedrock** ile özetler → **AWS Polly** ile doğal insan sesiyle **podcast formatında** çıktı üretir.

---

## 🚀 Mimari ve Teknolojiler

Bu proje aşağıdaki AWS servislerini otomatik olarak kurar ve yapılandırır:

* **Terraform** – Tüm altyapının kod ile yönetilmesi
* **GitHub Actions** – CI/CD süreçleri ve otomatik deployment
* **AWS CodePipeline** – Lambda fonksiyonlarının sürekli dağıtımı
* **AWS Lambda** – Haber toplama ve işleme (Python)
* **AWS Bedrock** – Haber metinlerinin AI ile özetlenmesi
* **AWS Polly** – Metnin doğal insan sesine dönüştürülmesi
* **Amazon S3** – Ses dosyalarının ve Terraform state'in saklanması
* **Amazon DynamoDB** – İşlenen haberlerin takibi (mükerrerliği önleme)
* **Amazon EventBridge** – Botun her sabah otomatik tetiklenmesi

---

## 📂 Proje Yapısı

```
.
├── .github/workflows/      # GitHub Actions (CI/CD)
├── news-terraform/         # Terraform altyapı kodları
│   ├── main.tf             # AWS kaynakları (Lambda, IAM, DynamoDB vb.)
│   ├── pipeline.tf         # AWS CodePipeline tanımları
│   ├── variables.tf        # Değişken tanımları
│   └── outputs.tf          # Çıktı değerleri
└── README.md               # Proje dokümantasyonu
```

---

## 🛠️ Kurulum ve Dağıtım (Deployment)

Bu proje CI/CD ile **tamamen otomatiktir**. Manuel kurulum gerekmez.

### 🔐 1. Gerekli GitHub Secrets

GitHub → **Settings → Secrets and variables → Actions** bölümüne gidin ve şu değerleri ekleyin:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### 🚀 2. Deploy

Kodu **main branch**'ine push ettiğinizde tüm AWS kaynakları otomatik olarak oluşturulur.

---

## 🧪 Manuel Çalıştırma (Opsiyonel)

Yerel olarak Terraform çalıştırmak isterseniz:

```bash
tcd news-terraform
terraform init
terraform plan
terraform apply
```

---

## 📜 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır.

---

Hazırlanmıştır: **Serverless AI Haber Botu – Terraform & AWS**
