import pandas as pd
import requests
import time
import os

# --- AYARLAR ---
API_KEY = "c4e5e773-24ee-4f8e-9ef1-9de0e223e8d5"  # Senin Anahtarın
FILE_PATH = r"C:\MobileUygulama\uygulama\flutter_application_1\assets\db\electronic_components_db.xlsx"

def get_mouser_data(part_number):
    url = f"https://api.mouser.com/api/v1/search/partnumber?apiKey={API_KEY}"
    
    body = {
        "SearchByPartRequest": {
            "mouserPartNumber": part_number,
            "partSearchOptions": "string"
        }
    }
    
    headers = {'Content-Type': 'application/json'}
    
    try:
        response = requests.post(url, json=body, headers=headers)
        if response.status_code == 200:
            data = response.json()
            # İlk sonucu al
            if data['SearchResults']['NumberOfResult'] > 0:
                part_data = data['SearchResults']['Parts'][0]
                return {
                    'desc': part_data.get('Description', ''),
                    'datasheet': part_data.get('DataSheetUrl', ''),
                    'manufacturer': part_data.get('Manufacturer', ''),
                    'category': part_data.get('Category', '')
                }
    except Exception as e:
        print(f"Hata ({part_number}): {e}")
    
    return None

def main():
    if not os.path.exists(FILE_PATH):
        print("HATA: Excel dosyasi bulunamadi!")
        return

    print(f"Dosya okunuyor: {FILE_PATH}")
    
    # Excel'i yükle (openpyxl motoru ile)
    xls = pd.ExcelFile(FILE_PATH, engine='openpyxl')
    df_components = pd.read_excel(xls, 'Components')
    
    # Diğer sayfaları da hafızada tut (Kaybedilmesin diye)
    df_smd = pd.read_excel(xls, 'SMDCodes')
    df_packages = pd.read_excel(xls, 'Packages')
    df_scripts = pd.read_excel(xls, 'TestScripts')

    # Yeni sütunlar ekle (Eğer yoksa)
    if 'datasheet_url' not in df_components.columns:
        df_components['datasheet_url'] = ""
    if 'manufacturer' not in df_components.columns:
        df_components['manufacturer'] = ""

    print("--- Veri Cekme Islemi Basladi ---")

    # Her satır için döngü
    for index, row in df_components.iterrows():
        part_id = row['id']
        print(f"[{index+1}/{len(df_components)}] Sorgulaniyor: {part_id} ...", end=" ")
        
        result = get_mouser_data(part_id)
        
        if result:
            print("BULUNDU! ✅")
            # Verileri güncelle
            df_components.at[index, 'description'] = result['desc']
            df_components.at[index, 'datasheet_url'] = result['datasheet']
            df_components.at[index, 'manufacturer'] = result['manufacturer']
        else:
            print("Bulunamadi ❌")
        
        # API'yi yormamak için minik bekleme
        time.sleep(0.5)

    # Dosyayı Kaydet
    print("\nDosya kaydediliyor...")
    with pd.ExcelWriter(FILE_PATH, engine='openpyxl') as writer:
        df_components.to_excel(writer, sheet_name='Components', index=False)
        df_smd.to_excel(writer, sheet_name='SMDCodes', index=False)
        df_packages.to_excel(writer, sheet_name='Packages', index=False)
        df_scripts.to_excel(writer, sheet_name='TestScripts', index=False)
    
    print("ISLEM TAMAMLANDI! 🎉")

if __name__ == "__main__":
    main()