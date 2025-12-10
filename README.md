# 📰 Serverless AI Haber Botu (Terraform & AWS & React)

AWS üzerinde çalışan tamamen **sunucusuz (serverless)** bir yapay zeka haber botu ve bu botun ürettiği içerikleri sunan **React tabanlı web arayüzünden** oluşur.

Tüm altyapı **Terraform** ile yönetilir; CI/CD süreçleri ise **GitHub Actions** ve **AWS CodePipeline** üzerinden otomatik çalışır.

Bot; haberleri toplar → **AWS Bedrock** ile özetler → **AWS Polly** ile doğal insan sesiyle **podcast formatında** çıktı üretir. React arayüzü bu içerikleri kullanıcıya sunar.

---

## 🚀 Mimari ve Teknolojiler

Bu proje aşağıdaki teknolojileri ve AWS servislerini kullanır:

* **Terraform** – Infrastructure as Code (IaC)
* **React (Vite)** – Modern, hızlı web arayüzü
* **GitHub Actions** – Otomatik CI/CD pipeline
* **AWS CodePipeline** – Lambda fonksiyonlarının sürekli dağıtımı
* **AWS Lambda** – Haber toplama ve işleme (Python)
* **AWS Bedrock** – AI ile haber özetleme
* **AWS Polly** – Metnin doğal insan sesine dönüştürülmesi
* **Amazon S3** – Ses dosyaları, web sitesi ve Terraform state
* **Amazon DynamoDB** – İşlenen haberlerin takibi (mükerrerlik önleme)
* **Amazon EventBridge** – Botun her sabah otomatik tetiklenmesi

---

## 📂 Proje Yapısı

```
.
├── .github/workflows/      # GitHub Actions (CI/CD)
├── news-terraform/         # Terraform altyapı kodları
│   ├── main.tf             # AWS kaynakları
│   ├── pipeline.tf         # CI/CD tanımları
│   └── lambda/             # Python bot kodları
│       ├── ingestor.py     # Test edilecek ana bot dosyası
│       └── ...
├── frontend/               # React Web Uygulaması
│   ├── src/
│   ├── package.json
│   └── ...
└── README.md               # Proje dokümantasyonu
```

---

## 🛠️ Kurulum ve Dağıtım (Deployment)

Bu proje CI/CD ile tamamen otomatiktir. Manuel işlem gerektirmez.

### **1️⃣ Gerekli GitHub Secrets**

GitHub → **Settings → Secrets and variables → Actions** bölümüne gidip şu değerleri ekleyin:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### **2️⃣ Deploy**

Kodu **main branch**'ine push ettiğinizde altyapı ve bot otomatik olarak deploy edilir.

---

## 💻 Yerel Geliştirme (Local Development)

Yerel ortamda hem React arayüzünü hem de botu çalıştırabilirsiniz.

---

### **A. React Arayüzünü Çalıştırma**

Frontend klasörüne gidin:

```bash
cd haber-sitesi
```

Bağımlılıkları yükleyin:

```bash
npm install
```

Uygulamayı başlatın:

```bash
npm run dev
```

Tarayıcıdan:

```
http://localhost:5173
```

adresine gidin.

---

### **B. Python Botunu Test Etme (ingestor.py)**

Lambda bot koduna gidin:

```bash
cd news-terraform/src
```


Bu projede bot, AWS EventBridge üzerinden 2 saatte bir otomatik olarak tetiklenir.
Yani sistem normalde tamamen otomatik çalışır. Ancak geliştirme veya test amaçlı olarak botu manuel tetiklemek isterseniz:

```bash
python3 ingestor.py
```

Bu komut haber çekmek,haber özetlemek ve seslendirmek için oluşturulan lambda fonksiyondur.

---

## 🧪 Terraform Manuel Çalıştırma (Opsiyonel)

Altyapıyı yerelden yönetmek isterseniz:

```bash
cd news-terraform
terraform init
terraform plan
terraform apply
```

---

## 📜 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır.

---

