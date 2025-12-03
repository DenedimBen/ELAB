import pandas as pd
import os

# ==============================================================================
# MASTER DATA (DOĞRULANMIŞ PINOUT İLE)
# ==============================================================================
# DİKKAT: pinout_code fiziksel sıraya göre (Soldan Sağa 1-2-3) yazılmıştır.
# G=Gate, D=Drain, S=Source
# C=Collector, B=Base, E=Emitter
# I=Input, G=Ground, O=Output, A=Adjust (Regülatör)
# A=Anode, K=Cathode (Diyot)
# 1-8 (Entegre)

components_data = [
    # --- MOSFETLER ---
    {"id": "IRFZ44N",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 55,  "i_max": 49,  "v_trig": 4.0, "r_ds": 0.017, "test_script_id": "TEST_MOSFET_N", "description": "N-Kanal Güç MOSFET."},
    {"id": "IRF3205",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 55,  "i_max": 110, "v_trig": 4.0, "r_ds": 0.008, "test_script_id": "TEST_MOSFET_N", "description": "Yüksek akım MOSFET."},
    {"id": "IRF540N",  "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": 100, "i_max": 33,  "v_trig": 4.0, "r_ds": 0.044, "test_script_id": "TEST_MOSFET_N", "description": "100V Güç MOSFET."},
    {"id": "2N7000",   "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-92",  "pinout_code": "SGD", "v_max": 60,  "i_max": 0.2, "v_trig": 2.1, "r_ds": 5.0,   "test_script_id": "TEST_MOSFET_N", "description": "Küçük sinyal MOSFET (Dikkat: Pinout SGD)."},
    {"id": "BS170",    "category": "MOSFET", "polarity": "N-Channel", "package_id": "TO-92",  "pinout_code": "DGS", "v_max": 60,  "i_max": 0.5, "v_trig": 2.1, "r_ds": 5.0,   "test_script_id": "TEST_MOSFET_N", "description": "Küçük sinyal MOSFET (Dikkat: Pinout DGS)."},
    {"id": "IRF9540",  "category": "MOSFET", "polarity": "P-Channel", "package_id": "TO-220", "pinout_code": "GDS", "v_max": -100,"i_max": -23, "v_trig": -4.0,"r_ds": 0.117, "test_script_id": "TEST_MOSFET_P", "description": "P-Kanal Güç MOSFET."},

    # --- BJT TRANSISTÖRLER ---
    {"id": "BC547",    "category": "BJT", "polarity": "NPN", "package_id": "TO-92",  "pinout_code": "CBE", "v_max": 45,  "i_max": 0.1, "hfe": 110, "test_script_id": "TEST_BJT_NPN", "description": "Genel amaçlı NPN."},
    {"id": "BC557",    "category": "BJT", "polarity": "PNP", "package_id": "TO-92",  "pinout_code": "CBE", "v_max": -45, "i_max": -0.1,"hfe": 110, "test_script_id": "TEST_BJT_PNP", "description": "Genel amaçlı PNP."},
    {"id": "2N2222",   "category": "BJT", "polarity": "NPN", "package_id": "TO-92",  "pinout_code": "EBC", "v_max": 40,  "i_max": 0.8, "hfe": 100, "test_script_id": "TEST_BJT_NPN", "description": "Amerikan standardı NPN (Pinout EBC)."},
    {"id": "BD139",    "category": "BJT", "polarity": "NPN", "package_id": "TO-126", "pinout_code": "ECB", "v_max": 80,  "i_max": 1.5, "hfe": 63,  "test_script_id": "TEST_BJT_NPN", "description": "Orta güç NPN (Pinout ECB)."},
    {"id": "TIP31C",   "category": "BJT", "polarity": "NPN", "package_id": "TO-220", "pinout_code": "BCE", "v_max": 100, "i_max": 3.0, "hfe": 25,  "test_script_id": "TEST_BJT_NPN", "description": "Güç NPN."},
    
    # --- REGÜLATÖRLER ---
    # L7805: 1=Input, 2=Ground, 3=Output -> IGO
    {"id": "L7805",    "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "v_trig": 5.0, "test_script_id": "TEST_REGULATOR", "description": "5V Regülatör (Input-GND-Output)."},
    {"id": "L7812",    "category": "REGULATOR", "polarity": "Linear", "package_id": "TO-220", "pinout_code": "IGO", "v_max": 35, "i_max": 1.5, "v_trig": 12.0,"test_script_id": "TEST_REGULATOR", "description": "12V Regülatör."},
    # LM317: 1=Adjust, 2=Output, 3=Input -> AOI (Yanlış yazılmamalı, datasheet AOI veya AIO değişebilir, ST datasheetine göre A-O-I)
    # Düzeltme: LM317 TO-220: 1=Adj, 2=Vout, 3=Vin -> AOI
    {"id": "LM317",    "category": "REGULATOR", "polarity": "Adjust", "package_id": "TO-220", "pinout_code": "AOI", "v_max": 40, "i_max": 1.5, "v_trig": 1.25,"test_script_id": "TEST_REGULATOR", "description": "Ayarlı Regülatör (Adj-Out-In)."},
    {"id": "AMS1117-3.3", "category": "REGULATOR", "polarity": "LDO", "package_id": "SOT-223", "pinout_code": "GOI", "v_max": 15, "i_max": 0.8, "v_trig": 3.3, "test_script_id": "TEST_REGULATOR", "description": "3.3V LDO (GND-Out-In)."},

    # --- DİYOTLAR (Çizgi Sağda = K) ---
    # AK -> 1=Anot(Sol), 2=Katot(Sağ)
    {"id": "1N4007",   "category": "DIODE", "polarity": "Standard", "package_id": "DO-41", "pinout_code": "AK", "v_max": 1000, "i_max": 1.0, "test_script_id": "TEST_DIODE", "description": "Doğrultucu Diyot."},
    {"id": "UF4007",   "category": "DIODE", "polarity": "Fast Rec", "package_id": "DO-41", "pinout_code": "AK", "v_max": 1000, "i_max": 1.0, "test_script_id": "TEST_DIODE", "description": "Hızlı Diyot."},

    # --- ENTEGRELER ---
    {"id": "NE555",    "category": "IC", "polarity": "Timer", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 16, "test_script_id": "TEST_IC", "description": "Timer Entegresi."},
    {"id": "LM358",    "category": "IC", "polarity": "OpAmp", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 32, "test_script_id": "TEST_IC", "description": "Dual Op-Amp."},
    {"id": "LM741",    "category": "IC", "polarity": "OpAmp", "package_id": "DIP-8", "pinout_code": "1-8", "v_max": 22, "test_script_id": "TEST_IC", "description": "Single Op-Amp."}
]

# (Diğer tablolar aynı, buraya yapıştırmıyorum)
# ... (smd_codes_data, packages_data vb. önceki koddan alabilirsin veya ihtiyacın varsa tamamını tekrar atarım) ...
# Önemli olan components_data listesindeki pinout_code değerleridir.

# --- KAYDETME KODU ---
# (Önceki kodun aynısı)
# ...