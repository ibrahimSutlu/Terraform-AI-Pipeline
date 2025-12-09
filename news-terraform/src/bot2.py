# bot.py (GÜNCELLENMİŞ HALİ)
import urllib.request
import xml.etree.ElementTree as ET
import boto3
import uuid
import time
import json # EKLENDİ
from datetime import datetime

REGION = 'us-east-1' 
TABLE_NAME = 'DailyDigests'
RSS_URL = "http://feeds.bbci.co.uk/turkce/rss.xml"
MODEL_ID = "anthropic.claude-3-haiku-20240307-v1:0" # EKLENDİ

# --- AI FONKSİYONU ---
def ozet_cikar(bedrock_client, uzun_metin):
    prompt = f"""
    Aşağıdaki haberi Türkçe olarak, profesyonel bir dille, en fazla 2 cümlede özetle:
    
    {uzun_metin}
    """
    
    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 300,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5
    })

    try:
        response = bedrock_client.invoke_model(
            body=body, modelId=MODEL_ID, accept='application/json', contentType='application/json'
        )
        response_body = json.loads(response.get('body').read())
        return response_body['content'][0]['text']
    except Exception as e:
        print(f"AI Hatası: {e}")
        return uzun_metin # Hata olursa orijinal metni döndür

# --- ANA FONKSİYON ---
def haberleri_cek_ve_kaydet():
    print(f"📡 RSS Bağlanıyor...")
    with urllib.request.urlopen(RSS_URL) as response:
        xml_data = response.read()
    root = ET.fromstring(xml_data)
    
    dynamodb = boto3.resource('dynamodb', region_name=REGION)
    table = dynamodb.Table(TABLE_NAME)
    
    # Bedrock istemcisini burada bir kere oluşturuyoruz
    bedrock = boto3.client(service_name='bedrock-runtime', region_name=REGION)
    
    items = root.findall('./channel/item')
    print(f"🔎 {len(items)} haber işleniyor...")

    for item in items:
        title = item.find('title').text
        link = item.find('link').text
        description = item.find('description').text # RSS'den gelen açıklama
        
        print(f"🤖 AI Özetliyor: {title[:30]}...")
        
        # BURADA AI DEVREYE GİRİYOR
        ai_summary = ozet_cikar(bedrock, description)

        # Kategori mantığı (Basitleştirilmiş)
        category = "Gündem"
        if "ekonomi" in title.lower() or "dolar" in title.lower(): category = "Finans"
        elif "teknoloji" in title.lower() or "yapay" in title.lower(): category = "Teknoloji"
        elif "spor" in title.lower() or "maç" in title.lower(): category = "Spor"

        news_item = {
            'category': category,
            'news_id': str(uuid.uuid4()),
            'title': title,
            'summary': ai_summary, # ARTIK AI ÖZETİ KAYDEDİLİYOR
            'url': link,
            'created_at': datetime.now().isoformat()
        }

        table.put_item(Item=news_item)
        print(f"✅ Kaydedildi.")
        time.sleep(1) # AI'ı boğmamak için biraz bekleme

if __name__ == "__main__":
    haberleri_cek_ve_kaydet()