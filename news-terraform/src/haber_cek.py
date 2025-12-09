import urllib.request
import xml.etree.ElementTree as ET
import boto3
import uuid
import time
from datetime import datetime

# --- AYARLAR ---
# Senin API adresin us-east-1'de olduğu için burayı ona göre ayarladım.
REGION = 'us-east-1' 
TABLE_NAME = 'DailyDigests'
RSS_URL = "http://feeds.bbci.co.uk/turkce/rss.xml" # BBC Türkçe Kaynağı

def haberleri_cek_ve_kaydet():
    print(f"📡 {RSS_URL} adresine bağlanılıyor...")
    
    # 1. RSS Verisini Çek (İnternetten)
    try:
        with urllib.request.urlopen(RSS_URL) as response:
            xml_data = response.read()
    except Exception as e:
        print(f"❌ Bağlantı hatası: {e}")
        return

    # 2. XML Verisini Parçala
    root = ET.fromstring(xml_data)
    
    # 3. AWS DynamoDB'ye Bağlan
    print(f"☁️  AWS DynamoDB ({REGION}) tablosuna bağlanılıyor...")
    dynamodb = boto3.resource('dynamodb', region_name=REGION)
    table = dynamodb.Table(TABLE_NAME)
    
    items = root.findall('./channel/item')
    print(f"🔎 Toplam {len(items)} haber bulundu. Veritabanına yazılıyor...")

    count = 0
    for item in items:
        # Verileri ayıkla
        title = item.find('title').text
        link = item.find('link').text
        description = item.find('description').text
        
        # Basit kategori ataması (BBC başlıklarında genelde kategori olmaz, hepsine Gündem diyelim şimdilik)
        # Gerçek projede bunu Yapay Zeka yapacak.
        category = "Gündem" 
        
        # Bazı haberleri rastgele kategorilere dağıtalım ki sitende filtreler çalışsın
        if "ekonomi" in title.lower() or "dolar" in title.lower(): category = "Finans"
        elif "teknoloji" in title.lower() or "yapay" in title.lower(): category = "Teknoloji"
        elif "spor" in title.lower() or "maç" in title.lower(): category = "Spor"

        # Veritabanı formatı
        news_item = {
            'category': category,              # Partition Key
            'news_id': str(uuid.uuid4()),      # Sort Key (Rastgele ID)
            'title': title,
            'summary': description[:200] + "...", # Özeti biraz kısalttık
            'url': link,
            'created_at': datetime.now().isoformat()
        }

        try:
            table.put_item(Item=news_item)
            print(f"✅ Kaydedildi: {title[:40]}...")
            count += 1
            time.sleep(0.1) # Çok hızlı yüklenip AWS'yi yormayalım
        except Exception as e:
            print(f"⚠️ Yazma hatası: {e}")

    print(f"\n🎉 İşlem Tamam! Toplam {count} haber veritabanına yüklendi.")

if __name__ == "__main__":
    haberleri_cek_ve_kaydet()