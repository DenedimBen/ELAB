import pandas as pd
import os

# --- EKLEMEK İSTEDİĞİMİZ YENİ PARÇALAR ---
new_components = [
    # --- OP-AMP & COMPARATORS (DIP-8 / DIP-14) ---
    {"id": "LM358", "category": "IC", "polarity": "OpAmp Dual", "package_id": "DIP-8", "pinout_code": "12345678", "v_max": 32, "i_max": 0.02, "power_max": 0.5, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Düşük güç tüketimli, çift kanallı genel amaçlı Op-Amp.", "manufacturer": "TI / ON Semi", "datasheet_url": "https://www.ti.com/lit/ds/symlink/lm358.pdf"},
    {"id": "LM741", "category": "IC", "polarity": "OpAmp Single", "package_id": "DIP-8", "pinout_code": "12345678", "v_max": 22, "i_max": 0.002, "power_max": 0.5, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Tarihi tek kanallı Op-Amp. Eğitim ve basit uygulamalar için.", "manufacturer": "TI", "datasheet_url": "https://www.ti.com/lit/ds/symlink/lm741.pdf"},
    {"id": "LM324", "category": "IC", "polarity": "OpAmp Quad", "package_id": "DIP-14", "pinout_code": "123456714", "v_max": 32, "i_max": 0.02, "power_max": 1.0, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Dört kanallı (Quad) versiyon LM358.", "manufacturer": "TI", "datasheet_url": "https://www.ti.com/lit/ds/symlink/lm324.pdf"},
    {"id": "NE555", "category": "IC", "polarity": "Timer", "package_id": "DIP-8", "pinout_code": "12345678", "v_max": 16, "i_max": 0.2, "power_max": 0.6, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Efsanevi zamanlayıcı entegresi. Osilatör ve PWM devrelerinde kullanılır.", "manufacturer": "TI", "datasheet_url": "https://www.ti.com/lit/ds/symlink/ne555.pdf"},
    {"id": "TL072", "category": "IC", "polarity": "JFET OpAmp", "package_id": "DIP-8", "pinout_code": "12345678", "v_max": 36, "i_max": 0.01, "power_max": 0.6, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Düşük gürültülü JFET girişli Op-Amp. Ses devreleri için ideal.", "manufacturer": "ST", "datasheet_url": "https://www.st.com/resource/en/datasheet/tl072.pdf"},

    # --- SÜRÜCÜLER & İZOLATÖRLER ---
    {"id": "PC817", "category": "IC", "polarity": "Optocoupler", "package_id": "DIP-4", "pinout_code": "AKEC", "v_max": 35, "i_max": 0.05, "power_max": 0.15, "param_aux": 0, "test_script_id": "TEST_DIODE", "description": "Genel amaçlı optokuplör. Sinyal izolasyonu sağlar.", "manufacturer": "Sharp/LiteOn", "datasheet_url": "https://www.farnell.com/datasheets/73758.pdf"},
    {"id": "ULN2003", "category": "IC", "polarity": "Darlington Array", "package_id": "DIP-16", "pinout_code": "1-16", "v_max": 50, "i_max": 0.5, "power_max": 1.0, "param_aux": 0, "test_script_id": "TEST_IC", "description": "7 kanallı Darlington dizisi. Röle ve Step motor sürmek için kullanılır.", "manufacturer": "TI", "datasheet_url": "https://www.ti.com/lit/ds/symlink/uln2003a.pdf"},
    {"id": "L293D", "category": "IC", "polarity": "Motor Driver", "package_id": "DIP-16", "pinout_code": "1-16", "v_max": 36, "i_max": 0.6, "power_max": 1.5, "param_aux": 0, "test_script_id": "TEST_IC", "description": "Çift H-Köprüsü motor sürücü. DC motorları ileri-geri sürebilir.", "manufacturer": "ST", "datasheet_url": "https://www.st.com/resource/en/datasheet/l293d.pdf"},

    # --- VOLTAJ REGÜLATÖRLERİ ---
    {"id": "L7805", "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 5.0, "test_script_id": "TEST_REGULATOR", "description": "Pozitif 5V Sabit Regülatör.", "manufacturer": "ST", "datasheet_url": "https://www.st.com/resource/en/datasheet/l78.pdf"},
    {"id": "L7809", "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 9.0, "test_script_id": "TEST_REGULATOR", "description": "Pozitif 9V Sabit Regülatör.", "manufacturer": "ST", "datasheet_url": ""},
    {"id": "L7812", "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 12.0, "test_script_id": "TEST_REGULATOR", "description": "Pozitif 12V Sabit Regülatör.", "manufacturer": "ST", "datasheet_url": ""},
    {"id": "L7905", "category": "REGULATOR", "polarity": "Negative", "package_id": "TO-220", "pinout_code": "GIO", "v_max": -35, "i_max": 1.5, "power_max": 15, "v_trig": -5.0, "test_script_id": "TEST_REGULATOR", "description": "Negatif -5V Sabit Regülatör. Dikkat: Pin yapısı farklıdır (GND-Input-Output).", "manufacturer": "ST", "datasheet_url": ""},
    {"id": "LM317", "category": "REGULATOR", "polarity": "Adjust", "package_id": "TO-220", "pinout_code": "AIO", "v_max": 40, "i_max": 1.5, "power_max": 20, "v_trig": 1.25, "test_script_id": "TEST_REGULATOR", "description": "Ayarlanabilir Pozitif Regülatör (1.2V - 37V).", "manufacturer": "TI", "datasheet_url": "https://www.ti.com/lit/ds/symlink/lm317.pdf"},
    {"id": "AMS1117-3.3", "category": "REGULATOR", "polarity": "LDO", "package_id": "SOT-223", "pinout_code": "GOI", "v_max": 15, "i_max": 0.8, "power_max": 1.0, "v_trig": 3.3, "test_script_id": "TEST_REGULATOR", "description": "SMD 3.3V LDO Regülatör. ESP8266/ESP32 projelerinde sık kullanılır.", "manufacturer": "Advanced Monolithic", "datasheet_url": "http://www.advanced-monolithic.com/pdf/ds1117.pdf"},

    # --- GÜÇ TRANSİSTÖRLERİ & MOSFETLER ---
    {"id": "TIP120", "category": "BJT", "polarity": "NPN Darlington", "package_id": "TO-220", "pinout_code": "BCE", "v_max": 60, "i_max": 5.0, "power_max": 65, "hfe": 1000, "test_script_id": "TEST_BJT_NPN", "description": "Darlington NPN. Çok düşük akımla yüksek akımları sürebilir (Arduino dostu).", "manufacturer": "ST", "datasheet_url": "https://www.st.com/resource/en/datasheet/tip120.pdf"},
    {"id": "TIP122", "category": "BJT", "polarity": "NPN Darlington", "package_id": "TO-220", "pinout_code": "BCE", "v_max": 100, "i_max": 5.0, "power_max": 65, "hfe": 1000, "test_script_id": "TEST_BJT_NPN", "description": "TIP120'nin 100V versiyonu.", "manufacturer": "ST", "datasheet_url": ""},
    {"id": "2N3055", "category": "BJT", "polarity": "NPN Power", "package_id": "TO-3", "pinout_code": "BCE", "v_max": 60, "i_max": 15.0, "power_max": 115, "hfe": 20, "test_script_id": "TEST_BJT_NPN", "description": "Efsanevi metal kılıf güç transistörü. Güç kaynaklarında sıkça görülür.", "manufacturer": "OnSemi", "datasheet_url": ""},
    {"id": "IRF540N", "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 100, "i_max": 33, "power_max": 130, "r_ds": 0.044, "test_script_id": "TEST_MOSFET_N", "description": "100V Güç MOSFET'i. Orta voltajlı anahtarlama için ideal.", "manufacturer": "Infineon", "datasheet_url": ""},
    {"id": "IRF9540", "category": "MOSFET", "polarity": "P-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": -100, "i_max": -23, "power_max": 140, "r_ds": 0.117, "test_script_id": "TEST_MOSFET_P", "description": "P-Kanal Güç MOSFET'i. High-side anahtarlama için kullanılır.", "manufacturer": "Vishay", "datasheet_url": ""},
]

# Yeni Paketler
new_packages = [
    {"package_id": "DIP-14", "image_asset": "assets/packages/dip-14.png"},
    {"package_id": "DIP-16", "image_asset": "assets/packages/dip-16.png"},
    {"package_id": "DIP-4",  "image_asset": "assets/packages/dip-4.png"},
    {"package_id": "SOT-223", "image_asset": "assets/packages/sot-223.png"},
    {"package_id": "TO-3",   "image_asset": "assets/packages/to-3.png"}
]

# Dosya Yolu
file_path = r"C:\MobileUygulama\uygulama\flutter_application_1\assets\db\electronic_components_db.xlsx"

def expand_database():
    if not os.path.exists(file_path):
        print("HATA: Veritabani bulunamadi!")
        return

    try:
        print("Veritabani genisletiliyor...")
        
        # Mevcut verileri oku
        xls = pd.ExcelFile(file_path, engine='openpyxl')
        df_comp = pd.read_excel(xls, 'Components')
        df_pack = pd.read_excel(xls, 'Packages')
        
        # Diğer sayfaları da korumak için oku
        df_smd = pd.read_excel(xls, 'SMDCodes')
        df_script = pd.read_excel(xls, 'TestScripts')

        # 1. Yeni Komponentleri Ekle (Tekrarı önleyerek)
        new_comp_df = pd.DataFrame(new_components)
        # Mevcut ID'leri al
        existing_ids = df_comp['id'].tolist()
        # Sadece yeni olanları filtrele
        new_comp_df = new_comp_df[~new_comp_df['id'].isin(existing_ids)]
        
        if not new_comp_df.empty:
            df_comp = pd.concat([df_comp, new_comp_df], ignore_index=True)
            print(f"+ {len(new_comp_df)} yeni komponent eklendi.")
        else:
            print("Komponentler zaten guncel.")

        # 2. Yeni Paketleri Ekle
        new_pack_df = pd.DataFrame(new_packages)
        existing_packs = df_pack['package_id'].tolist()
        new_pack_df = new_pack_df[~new_pack_df['package_id'].isin(existing_packs)]

        if not new_pack_df.empty:
            df_pack = pd.concat([df_pack, new_pack_df], ignore_index=True)
            print(f"+ {len(new_pack_df)} yeni paket eklendi.")

        # 3. Kaydet
        with pd.ExcelWriter(file_path, engine='openpyxl') as writer:
            df_comp.to_excel(writer, sheet_name='Components', index=False)
            df_smd.to_excel(writer, sheet_name='SMDCodes', index=False)
            df_pack.to_excel(writer, sheet_name='Packages', index=False)
            df_script.to_excel(writer, sheet_name='TestScripts', index=False)
            
        print("BASARILI! Veritabani guncellendi.")c
        print("Simdi Flutter uygulamasini 'flutter clean' yapip yeniden baslat.")

    except Exception as e:
        print(f"HATA: {e}")

if __name__ == "__main__":
    expand_database()