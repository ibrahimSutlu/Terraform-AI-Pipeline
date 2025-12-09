import urllib.request
import xml.etree.ElementTree as ET
import boto3
import uuid
import time
import json
import os
from datetime import datetime
import re
from boto3.dynamodb.conditions import Key


# =============================
# CONFIG
# =============================
REGION = os.environ.get('AWS_REGION', 'us-east-1')
TABLE_NAME = os.environ.get('TABLE_NAME', 'DailyDigests')
RSS_URL = os.environ.get('RSS_URL', 'http://feeds.bbci.co.uk/turkce/rss.xml')
BUCKET_NAME = os.environ.get('AUDIO_BUCKET_NAME', 'haber-sesleri-20251207091706170700000001')
HABER_LIMITI = int(os.environ.get('HABER_LIMITI', '5'))
MODEL_ID = "anthropic.claude-3-haiku-20240307-v1:0"

# AWS Clients
polly = boto3.client('polly')
s3 = boto3.client('s3')
dynamo = boto3.resource('dynamodb', region_name=REGION)
bedrock = boto3.client(service_name='bedrock-runtime', region_name=REGION)

table = dynamo.Table(TABLE_NAME)

def haber_var_mi(title):
    resp = table.scan(
        FilterExpression="title = :t",
        ExpressionAttributeValues={":t": title}
    )
    return resp.get("Items", [])

def ai_ozet_cikar(metin):
    prompt = f"""
    Aşağıdaki haberi Türkçe olarak profesyonel bir dille  özetle:

    {metin}
    """

    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 300,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5
    })

    try:
        response = bedrock.invoke_model(
            body=body,
            modelId=MODEL_ID,
            accept='application/json',
            contentType='application/json'
        )
        data = json.loads(response.get('body').read())
        return data['content'][0]['text']
    except Exception as e:
        print(f"AI Özetleme Hatası: {e}")
        return metin

# =============================
# 2. Seslendirme + S3 Upload
# =============================
def ai_kategori_belirle(title, description):
    prompt = f"""
    Sen bir haber sınıflandırma modelisin.
    Görevin sadece bu haber için kategorilerden birini vermek:
    - Siyaset
    - Finans
    - Teknoloji
    - Spor

    Haber Başlığı: {title}
    Haber İçeriği: {description}

    Sadece kategori adını tek kelime olarak döndür.
    """

    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 300,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.5
    })

    try:
        response = bedrock.invoke_model(
            body=body,
            modelId=MODEL_ID,
            accept='application/json',
            contentType='application/json'
        )
        data = json.loads(response.get('body').read())
        print("kategori belirleme",data['content'][0]['text'].strip())
        return data['content'][0]['text'].strip()

    except Exception as e:
        print(f"AI Özetleme Hatası: {e}")

def seslendir_ve_yukle(metin):
    try:
        kisa = metin[:250]
        response = polly.synthesize_speech(
            Text=kisa,
            OutputFormat='mp3',
            VoiceId='Filiz',  # veya Arda
            Engine='standard'
        )


        if "AudioStream" not in response:
            return None

        audio = response['AudioStream'].read()
        if len(audio) == 0:
            return None

        key = f"{uuid.uuid4()}.mp3"

        s3.put_object(
            Bucket=BUCKET_NAME,
            Key=key,
            Body=audio,
            ContentType='audio/mpeg',
        )

        url = f"https://{BUCKET_NAME}.s3.amazonaws.com/{key}"
        return url

    except Exception as e:
        print(f"Seslendirme hatası: {e}")
        return None

# =============================
# 3. BBC RSS ÇEKİMİ
# =============================
def haberleri_getir():
    try:
        with urllib.request.urlopen(RSS_URL) as response:
            xml_data = response.read()
        root = ET.fromstring(xml_data)
        items = root.findall('./channel/item')

        haberler = []
        for i, item in enumerate(items):
            if i >= HABER_LIMITI:
                break

            title = item.find('title').text
            link = item.find('link').text
            description = item.find('description').text

            category = ai_kategori_belirle(title, description)


            haberler.append({
                "title": title,
                "description": description,
                "link": link,
                "category": category
            })

        return haberler
    except Exception as e:
        print(f"RSS Hata: {e}")
        return []

# =============================
# 4. Lambda Handler
# =============================
def lambda_handler(event, context):
    haberler = haberleri_getir()
    kayit_sayisi = 0

    for h in haberler:
        print(f"İşleniyor → {h['title'][:40]}")
        if haber_var_mi(h['title']):
            print("➡️ Bu başlık zaten kayıtlı, geçiliyor.")
            continue
        ai_ozet = ai_ozet_cikar(h['description'])
        ses_url = seslendir_ve_yukle(ai_ozet) or "SES_YOK"
        print("aaaaa",h['category'], h['title'])
        item = {
            'category': h['category'],
            'news_id': str(uuid.uuid4()),
            'title': h['title'],
            'summary': ai_ozet,
            'url': h['link'],
            'created_at': datetime.now().isoformat(),
            'ses_url': ses_url
        }

        try:
            table.put_item(Item=item)
            kayit_sayisi += 1
        except Exception as e:
            print(f"DynamoDB Hata: {e}")

        time.sleep(1)

    return {
        'statusCode': 200,
        'body': json.dumps(f"{kayit_sayisi} haber işlendi ve kaydedildi.")
    }


if __name__ == "__main__":
    lambda_handler(None, None)
