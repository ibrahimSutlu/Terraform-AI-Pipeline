import boto3
import os
import json
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

dynamodb = boto3.resource('dynamodb')


TABLE_NAME = "DailyDigests" 
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        # Tablodaki verileri çek
        response = table.scan()
        items = response.get('Items', [])
        
        print(f"Tablo ({TABLE_NAME}) tarandı. Bulunan kayıt sayısı: {len(items)}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*', 
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps(items, cls=DecimalEncoder)
        }
    except Exception as e:
        print(f"API Hatası: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({"error": str(e)})
        }