import pandas as pd
import os

# ==============================================================================
# ULTIMATE KOMPONENT VERİTABANI
# ==============================================================================
# pin_names formatı: "Pin1,Pin2,Pin3..." (Virgülle ayrılmış)
# v_trig: Tetikleme/Kontrol voltajı
# r_ds: İç direnç (MOSFET)
# speed: Hız (ns) - Diyot

components_data = [
    # --- 1. MOSFETLER (GÜÇ) ---
    {"id": "IRFZ44N",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 55,  "i_max": 49,  "power_max": 94,  "v_trig": 4.0, "r_ds": 0.017, "test_script_id": "TEST_MOSFET_N", "description": "Standart N-Kanal Güç MOSFET'i. Motor sürücü ve güç kaynaklarında yaygın.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF3205",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 55,  "i_max": 110, "power_max": 200, "v_trig": 4.0, "r_ds": 0.008, "test_script_id": "TEST_MOSFET_N", "description": "Çok düşük iç dirençli, yüksek akım MOSFET'i. İnverterler için ideal.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF540N",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 100, "i_max": 33,  "power_max": 130, "v_trig": 4.0, "r_ds": 0.044, "test_script_id": "TEST_MOSFET_N", "description": "100V Dayanımlı genel amaçlı güç MOSFET'i.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF640",   "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 200, "i_max": 18,  "power_max": 150, "v_trig": 4.0, "r_ds": 0.150, "test_script_id": "TEST_MOSFET_N", "description": "200V Yüksek voltaj anahtarlama elemanı.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF740",   "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 400, "i_max": 10,  "power_max": 125, "v_trig": 4.0, "r_ds": 0.550, "test_script_id": "TEST_MOSFET_N", "description": "400V SMPS ve sürücü devreleri için.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF840",   "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 500, "i_max": 8,   "power_max": 125, "v_trig": 4.0, "r_ds": 0.850, "test_script_id": "TEST_MOSFET_N", "description": "500V Yüksek voltaj uygulamaları.", "pin_names": "GATE,DRAIN,SOURCE"},
    {"id": "IRF9540",  "category": "MOSFET", "polarity": "P-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": -100,"i_max": -23, "power_max": 140, "v_trig": -4.0,"r_ds": 0.117, "test_script_id": "TEST_MOSFET_P", "description": "P-Kanal Güç MOSFET'i (High-Side Anahtarlama).", "pin_names": "GATE,DRAIN,SOURCE"},
    
    # --- 2. KÜÇÜK SİNYAL MOSFETLER ---
    {"id": "2N7000",   "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-92",  "pinout_code": "SGD", "v_max": 60,  "i_max": 0.2, "power_max": 0.4, "v_trig": 2.1, "r_ds": 5.0,   "test_script_id": "TEST_MOSFET_N", "description": "Küçük sinyal, lojik seviye MOSFET. Arduino ile sürülebilir.", "pin_names": "SOURCE,GATE,DRAIN"},
    {"id": "BS170",    "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-92",  "pinout_code": "DGS", "v_max": 60,  "i_max": 0.5, "power_max": 0.8, "v_trig": 2.1, "r_ds": 5.0,   "test_script_id": "TEST_MOSFET_N", "description": "2N7000 benzeri ama bacak dizilimi farklı (DGS).", "pin_names": "DRAIN,GATE,SOURCE"},

    # --- 3. BJT TRANSISTÖRLER ---
    {"id": "BC547",    "category": "BJT", "polarity": "NPN", "package_id": "TO-92",  "pinout_code": "CBE", "v_max": 45,  "i_max": 0.1, "power_max": 0.5, "hfe": 110, "test_script_id": "TEST_BJT_NPN", "description": "Genel amaçlı, düşük gürültülü NPN.", "pin_names": "COLL,BASE,EMIT"},
    {"id": "BC557",    "category": "BJT", "polarity": "PNP", "package_id": "TO-92",  "pinout_code": "CBE", "v_max": -45, "i_max": -0.1,"power_max": 0.5, "hfe": 110, "test_script_id": "TEST_BJT_PNP", "description": "Genel amaçlı PNP transistör.", "pin_names": "COLL,BASE,EMIT"},
    {"id": "2N2222",   "category": "BJT", "polarity": "NPN", "package_id": "TO-92",  "pinout_code": "EBC", "v_max": 40,  "i_max": 0.8, "power_max": 0.5, "hfe": 100, "test_script_id": "TEST_BJT_NPN", "description": "Yüksek hızlı anahtarlama ve yükseltme.", "pin_names": "EMIT,BASE,COLL"},
    {"id": "2N3904",   "category": "BJT", "polarity": "NPN", "package_id": "TO-92",  "pinout_code": "EBC", "v_max": 40,  "i_max": 0.2, "power_max": 0.6, "hfe": 100, "test_script_id": "TEST_BJT_NPN", "description": "Genel amaçlı NPN.", "pin_names": "EMIT,BASE,COLL"},
    {"id": "BD139",    "category": "BJT", "polarity": "NPN", "package_id": "TO-126", "pinout_code": "ECB", "v_max": 80,  "i_max": 1.5, "power_max": 12,  "hfe": 63,  "test_script_id": "TEST_BJT_NPN", "description": "Orta güç NPN. Ses sürücü devrelerinde sıkça kullanılır.", "pin_names": "EMIT,COLL,BASE"},
    {"id": "BD140",    "category": "BJT", "polarity": "PNP", "package_id": "TO-126", "pinout_code": "ECB", "v_max": -80, "i_max": -1.5,"power_max": 12,  "hfe": 63,  "test_script_id": "TEST_BJT_PNP", "description": "BD139'un PNP eşleniği.", "pin_names": "EMIT,COLL,BASE"},
    {"id": "TIP31C",   "category": "BJT", "polarity": "NPN", "package_id": "TO-220", "pinout_code": "BCE", "v_max": 100, "i_max": 3.0, "power_max": 40,  "hfe": 25,  "test_script_id": "TEST_BJT_NPN", "description": "Güç NPN Transistörü.", "pin_names": "BASE,COLL,EMIT"},
    {"id": "TIP32C",   "category": "BJT", "polarity": "PNP", "package_id": "TO-220", "pinout_code": "BCE", "v_max": -100,"i_max": -3.0,"power_max": 40,  "hfe": 25,  "test_script_id": "TEST_BJT_PNP", "description": "Güç PNP Transistörü.", "pin_names": "BASE,COLL,EMIT"},
    {"id": "TIP120",   "category": "BJT", "polarity": "NPN Darlington", "package_id": "TO-220", "pinout_code": "BCE", "v_max": 60, "i_max": 5.0, "power_max": 65, "hfe": 1000,"test_script_id": "TEST_BJT_NPN", "description": "Darlington NPN. Çok yüksek kazançlı.", "pin_names": "BASE,COLL,EMIT"},
    {"id": "2N3055",   "category": "BJT", "polarity": "NPN Power", "package_id": "TO-3", "pinout_code": "BCE", "v_max": 60, "i_max": 15.0, "power_max": 115,"hfe": 20,  "test_script_id": "TEST_BJT_NPN", "description": "Efsanevi metal kılıf güç transistörü.", "pin_names": "BASE,COLL,EMIT"},

    # --- 4. ENTEGRELER (IC) ---
    {
        "id": "NE555", "category": "IC", "polarity": "Timer", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 16, "i_max": 0.2, "power_max": 0.6, "test_script_id": "TEST_IC",
        "description": "Hassas zamanlayıcı. Osilatör, PWM ve Timer devrelerinin kalbi.", "pin_names": "GND,TRIG,OUT,RST,CTRL,THR,DIS,VCC"
    },
    {
        "id": "LM358", "category": "IC", "polarity": "OpAmp Dual", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 32, "i_max": 0.02, "power_max": 0.5, "test_script_id": "TEST_IC",
        "description": "Çift kanallı, tek beslemeyle çalışabilen genel amaçlı Op-Amp.", "pin_names": "OUT A,IN- A,IN+ A,GND,IN+ B,IN- B,OUT B,VCC"
    },
    {
        "id": "LM741", "category": "IC", "polarity": "OpAmp Single", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 22, "i_max": 0.002,"power_max": 0.5, "test_script_id": "TEST_IC",
        "description": "Klasik tekli Op-Amp. Eğitim ve temel uygulamalar için.", "pin_names": "OFF,IN-,IN+,V-,OFF,OUT,V+,NC"
    },
    {
        "id": "TL072", "category": "IC", "polarity": "JFET OpAmp", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 36, "i_max": 0.01, "power_max": 0.6, "test_script_id": "TEST_IC",
        "description": "Düşük gürültülü JFET girişli Op-Amp. Ses devreleri için ideal.", "pin_names": "OUT A,IN- A,IN+ A,V-,IN+ B,IN- B,OUT B,V+"
    },
    {
        "id": "ULN2003", "category": "IC", "polarity": "Darlington", "package_id": "DIP-16", "pinout_code": "1-16", "v_max": 50, "i_max": 0.5, "power_max": 1.0, "test_script_id": "TEST_IC",
        "description": "7 Kanal Darlington dizisi. Röle ve step motor sürmek için kullanılır.", "pin_names": "IN1,IN2,IN3,IN4,IN5,IN6,IN7,GND,COM,OUT7,OUT6,OUT5,OUT4,OUT3,OUT2,OUT1"
    },
    {
        "id": "L293D", "category": "IC", "polarity": "Motor Driver", "package_id": "DIP-16", "pinout_code": "1-16", "v_max": 36, "i_max": 0.6, "power_max": 1.5, "test_script_id": "TEST_IC",
        "description": "Çift H-Köprüsü Motor Sürücü. DC motorları ileri-geri sürebilir.", "pin_names": "EN1,IN1,OUT1,GND,GND,OUT2,IN2,VCC2,EN2,IN3,OUT3,GND,GND,OUT4,IN4,VCC1"
    },
    {
        "id": "CD4017", "category": "IC", "polarity": "Counter", "package_id": "DIP-16", "pinout_code": "1-16", "v_max": 15, "i_max": 0.01, "power_max": 0.5, "test_script_id": "TEST_IC",
        "description": "Onlu sayıcı (Decade Counter). Yürüyen ışık devrelerinde popülerdir.", "pin_names": "5,1,0,2,6,7,3,GND,8,4,9,CARRY,EN,CLK,RST,VCC"
    },
    {
        "id": "PC817", "category": "IC", "polarity": "Optocoupler", "package_id": "DIP-4", "pinout_code": "AKEC", "v_max": 35, "i_max": 0.05, "power_max": 0.15, "test_script_id": "TEST_DIODE",
        "description": "4 Pinli Optokuplör. Sinyal izolasyonu sağlar.", "pin_names": "ANODE,CATHODE,EMITTER,COLLECTOR"
    },

    # --- 5. VOLTAJ REGÜLATÖRLERİ ---
    {"id": "L7805",    "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 5.0, "test_script_id": "TEST_REGULATOR", "description": "Pozitif 5V Sabit Regülatör.", "pin_names": "INPUT,GND,OUTPUT"},
    {"id": "L7809",    "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 9.0, "test_script_id": "TEST_REGULATOR", "description": "Pozitif 9V Sabit Regülatör.", "pin_names": "INPUT,GND,OUTPUT"},
    {"id": "L7812",    "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "power_max": 15, "v_trig": 12.0,"test_script_id": "TEST_REGULATOR", "description": "Pozitif 12V Sabit Regülatör.", "pin_names": "INPUT,GND,OUTPUT"},
    {"id": "L7905",    "category": "REGULATOR", "polarity": "Negative", "package_id": "TO-220", "pinout_code": "GIO", "v_max": -35, "i_max": 1.5, "power_max": 15, "v_trig": -5.0, "test_script_id": "TEST_REGULATOR", "description": "Negatif -5V Sabit Regülatör. (GND-Input-Out).", "pin_names": "GND,INPUT,OUTPUT"},
    {"id": "LM317",    "category": "REGULATOR", "polarity": "Adjust", "package_id": "TO-220", "pinout_code": "AOI", "v_max": 40, "i_max": 1.5, "power_max": 20, "v_trig": 1.25,"test_script_id": "TEST_REGULATOR", "description": "Ayarlanabilir Pozitif Regülatör (1.2V - 37V).", "pin_names": "ADJ,OUTPUT,INPUT"},
    {"id": "AMS1117-3.3", "category": "REGULATOR", "polarity": "LDO", "package_id": "SOT-223", "pinout_code": "GOI", "v_max": 15, "i_max": 0.8, "power_max": 1.0, "v_trig": 3.3, "test_script_id": "TEST_REGULATOR", "description": "3.3V LDO Regülatör (SMD).", "pin_names": "GND,OUTPUT,INPUT"},

    # --- 6. DİYOTLAR ---
    {"id": "1N4007",   "category": "DIODE", "polarity": "Standard", "package_id": "DO-41", "pinout_code": "AK", "v_max": 1000, "i_max": 1.0, "power_max": 0, "test_script_id": "TEST_DIODE", "description": "Genel amaçlı doğrultucu diyot.", "pin_names": "ANODE,CATHODE"},
    {"id": "1N4148",   "category": "DIODE", "polarity": "Switching","package_id": "DO-35", "pinout_code": "AK", "v_max": 100,  "i_max": 0.2, "power_max": 0, "speed": 4, "test_script_id": "TEST_DIODE", "description": "Yüksek hızlı sinyal diyodu.", "pin_names": "ANODE,CATHODE"},
    {"id": "UF4007",   "category": "DIODE", "polarity": "Fast Rec", "package_id": "DO-41", "pinout_code": "AK", "v_max": 1000, "i_max": 1.0, "power_max": 0, "speed": 75, "test_script_id": "TEST_DIODE", "description": "Ultra Hızlı (Fast Recovery) diyot.", "pin_names": "ANODE,CATHODE"},
    {"id": "1N5819",   "category": "DIODE", "polarity": "Schottky", "package_id": "DO-41", "pinout_code": "AK", "v_max": 40,   "i_max": 1.0, "power_max": 0, "test_script_id": "TEST_DIODE", "description": "Düşük voltaj düşümlü Schottky diyot.", "pin_names": "ANODE,CATHODE"},

    # --- 7. SMD (DEDEKTİF) ---
    {"id": "BC846",    "category": "BJT", "polarity": "NPN", "package_id": "SOT-23", "pinout_code": "CBE", "v_max": 65, "i_max": 0.1, "power_max": 0.25, "hfe": 110, "test_script_id": "TEST_BJT_NPN", "description": "SMD NPN Transistör.", "pin_names": "BASE,EMIT,COLL"}, # SOT-23 Pin sırası fiziksel olarak farklı olabilir, datasheet'e göre 1=Base, 2=Emitter, 3=Collector
    {"id": "MMBT3904", "category": "BJT", "polarity": "NPN", "package_id": "SOT-23", "pinout_code": "EBC", "v_max": 40, "i_max": 0.2, "power_max": 0.35, "hfe": 100, "test_script_id": "TEST_BJT_NPN", "description": "2N3904'ün SMD versiyonu.", "pin_names": "BASE,EMIT,COLL"},
    {"id": "M7",       "category": "DIODE", "polarity": "Standard", "package_id": "SMA",  "pinout_code": "AK",  "v_max": 1000,"i_max": 1.0, "power_max": 0, "test_script_id": "TEST_DIODE", "description": "1N4007'nin SMD versiyonu.", "pin_names": "ANODE,CATHODE"},
    {"id": "SS14",     "category": "DIODE", "polarity": "Schottky", "package_id": "SMA",  "pinout_code": "AK",  "v_max": 40,  "i_max": 1.0, "power_max": 0, "test_script_id": "TEST_DIODE", "description": "1N5819'un SMD versiyonu.", "pin_names": "ANODE,CATHODE"},
]

smd_codes_data = [
    {"code": "1A",  "component_id": "BC846",    "package_type": "SOT-23"},
    {"code": "1B",  "component_id": "BC847",    "package_type": "SOT-23"},
    {"code": "1AM", "component_id": "MMBT3904", "package_type": "SOT-23"},
    {"code": "2A",  "component_id": "MMBT3906", "package_type": "SOT-23"},
    {"code": "M7",  "component_id": "M7",       "package_type": "SMA"},
    {"code": "SS14","component_id": "SS14",     "package_type": "SMA"},
    {"code": "J3Y", "component_id": "S8050",    "package_type": "SOT-23"},
]

packages_data = [
    {"package_id": "TO-220", "image_asset": "assets/packages/to-220.png"},
    {"package_id": "TO-92",  "image_asset": "assets/packages/to-92.png"},
    {"package_id": "TO-126", "image_asset": "assets/packages/to-220.png"},
    {"package_id": "TO-3",   "image_asset": "assets/packages/to-3.png"},
    {"package_id": "DO-41",  "image_asset": "assets/packages/do-41.png"},
    {"package_id": "DO-35",  "image_asset": "assets/packages/do-41.png"},
    {"package_id": "DO-201", "image_asset": "assets/packages/do-41.png"},
    {"package_id": "SOT-23", "image_asset": "assets/packages/sot-23.png"},
    {"package_id": "SOT-223","image_asset": "assets/packages/sot-223.png"},
    {"package_id": "SMA",    "image_asset": "assets/packages/sma.png"},
    {"package_id": "DIP-4",  "image_asset": "assets/packages/dip-4.png"},
    {"package_id": "DIP-8",  "image_asset": "assets/packages/dip-8.png"},
    {"package_id": "DIP-14", "image_asset": "assets/packages/dip-14.png"},
    {"package_id": "DIP-16", "image_asset": "assets/packages/dip-16.png"},
]

test_scripts_data = [
    {"script_id": "TEST_MOSFET_N", "steps_json": "{}"},
    {"script_id": "TEST_MOSFET_P", "steps_json": "{}"},
    {"script_id": "TEST_BJT_NPN", "steps_json": "{}"},
    {"script_id": "TEST_BJT_PNP", "steps_json": "{}"},
    {"script_id": "TEST_DIODE",    "steps_json": "{}"},
    {"script_id": "TEST_REGULATOR","steps_json": "{}"},
    {"script_id": "TEST_IC",       "steps_json": "{}"}
]

output_path = r"C:\MobileUygulama\uygulama\flutter_application_1\assets\db\electronic_components_db.xlsx"
os.makedirs(os.path.dirname(output_path), exist_ok=True)

try:
    print(f"Veritabani olusturuluyor: {output_path}")
    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        pd.DataFrame(components_data).to_excel(writer, sheet_name='Components', index=False)
        pd.DataFrame(smd_codes_data).to_excel(writer, sheet_name='SMDCodes', index=False)
        pd.DataFrame(packages_data).to_excel(writer, sheet_name='Packages', index=False)
        pd.DataFrame(test_scripts_data).to_excel(writer, sheet_name='TestScripts', index=False)
    print("BASARILI! Tum veriler kaydedildi.")
except Exception as e:
    print(f"HATA: {e}")