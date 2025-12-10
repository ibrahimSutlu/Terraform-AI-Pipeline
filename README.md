📰 Serverless AI Haber Botu (Terraform & AWS & React)

AWS üzerinde çalışan, tamamen sunucusuz (serverless) bir yapay zeka haber botu ve bu botun ürettiği içerikleri sunan React tabanlı web arayüzü.

Tüm altyapı Terraform ile yönetilir ve CI/CD süreçleri otomatik olarak GitHub Actions + CodePipeline üzerinden çalışır.

Bot; haberleri toplar → AWS Bedrock ile özetler → AWS Polly ile doğal insan sesiyle podcast formatında çıktı üretir. React arayüzü ise bu içerikleri son kullanıcıya sunar.

🚀 Mimari ve Teknolojiler

Bu proje aşağıdaki teknolojileri ve AWS servislerini kullanır:

Terraform: Tüm altyapının kod ile yönetilmesi (IaC).

React (Vite): Modern ve hızlı web arayüzü.

GitHub Actions: CI/CD süreçleri ve otomatik deployment.

AWS CodePipeline: Lambda fonksiyonlarının sürekli dağıtımı.

AWS Lambda: Haber toplama ve işleme (Python).

AWS Bedrock: Haber metinlerinin AI ile özetlenmesi.

AWS Polly: Metnin doğal insan sesine dönüştürülmesi.

Amazon S3: Ses dosyalarının, web sitesinin ve Terraform state'in saklanması.

Amazon DynamoDB: İşlenen haberlerin takibi (Mükerrerliği önleme).

Amazon EventBridge: Botun her sabah otomatik tetiklenmesi.

📂 Proje Yapısı

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


🛠️ Kurulum ve Dağıtım (Deployment)

Bu proje CI/CD ile tamamen otomatiktir. Manuel kurulum gerekmez.

1. Gerekli GitHub Secrets

GitHub → Settings → Secrets and variables → Actions bölümüne gidin ve şu değerleri ekleyin:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

2. Deploy

Kodu main branch'ine push ettiğinizde tüm AWS kaynakları otomatik olarak oluşturulur.

💻 Yerel Geliştirme (Local Development)

Projeyi bilgisayarınızda geliştirmek ve test etmek için aşağıdaki adımları izleyin.

A. React Arayüzünü Çalıştırma

Web arayüzünü yerel ortamda (localhost) çalıştırmak için:

Frontend klasörüne gidin:

cd frontend


Bağımlılıkları yükleyin:

npm install


Uygulamayı başlatın:

npm run dev


Tarayıcınızda http://localhost:5173 (veya terminalde belirtilen port) adresine giderek arayüzü görebilirsiniz.

B. Python Botunu Test Etme (ingestor.py)

AWS'ye deploy etmeden önce botun haber çekme ve işleme mantığını test etmek için:

Lambda kodlarının olduğu klasöre gidin:

cd news-terraform/lambda


(Not: Klasör yolu projenize göre değişebilir)

Sanal ortamı kurun ve kütüphaneleri yükleyin (Önerilen):

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


Test kodunu çalıştırın:

python ingestor.py


Bu komut, botu manuel olarak tetikler ve terminalde haberlerin çekilip işlendiğini simüle eder.

🧪 Terraform Manuel Çalıştırma (Opsiyonel)

Sadece altyapıyı yerel bilgisayarınızdan güncellemek isterseniz:

cd news-terraform
terraform init
terraform plan
terraform apply


📜 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır.