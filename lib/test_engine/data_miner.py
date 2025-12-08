import pandas as pd

# Depo Listemiz
mega_db = []

# --- DÜZELTİLMİŞ EKLEME FONKSİYONU ---
# Flutter ComponentModel sırasına tam uyumlu:
# 0:id, 1:cat, 2:pol, 3:pkg, 4:pin, 5:v, 6:i, 7:p, 8:scr, 9:desc, 10:url, 11:pin_names
def add_part(id, cat, pol, pkg, pin, vmax, imax, pmax, scr, desc):
    # Pin İsimlerini Tahmin Et (GDS, CBE vb.)
    p_names = ",".join(list(pin)) if pin else ""
    
    mega_db.append({
        "id": id,                  # 0
        "category": cat,           # 1
        "polarity": pol,           # 2 (Bunu eksik yapmıştık!)
        "package_id": pkg,         # 3
        "pinout_code": pin,        # 4
        "v_max": vmax,             # 5
        "i_max": imax,             # 6
        "power_max": pmax,         # 7
        "test_script_id": scr,     # 8
        "description": desc,       # 9
        "datasheet_url": "",       # 10 (Boş bırakıyoruz)
        "pin_names": p_names       # 11
    })

print("🚀 Düzeltilmiş Veri Üretimi Başlıyor...")

# ==========================================
# 1. MOSFETLER
# ==========================================
irf_n = [
    ("IRFZ44N", 55, 49, 94), ("IRF3205", 55, 110, 200), ("IRF540N", 100, 33, 130), 
    ("IRF640", 200, 18, 150), ("IRF740", 400, 10, 125), ("IRF840", 500, 8, 125),
    ("2N7000", 60, 0.2, 0.4), ("BS170", 60, 0.5, 0.8)
]
for p in irf_n:
    pkg = "TO-92" if p[0] in ["2N7000", "BS170"] else "TO-220"
    pin = "SGD" if p[0] == "2N7000" else ("DGS" if p[0] == "BS170" else "GDS")
    add_part(p[0], "MOSFET", "N-Channel", pkg, pin, p[1], p[2], p[3], "TEST_MOS_N", f"N-Ch MOSFET {p[1]}V")

irf_p = [("IRF9540", -100, -23, 140), ("IRF4905", -55, -74, 200)]
for p in irf_p:
    add_part(p[0], "MOSFET", "P-Channel", "TO-220", "GDS", p[1], p[2], p[3], "TEST_MOS_P", f"P-Ch MOSFET {p[1]}V")

# ==========================================
# 2. TRANSİSTÖRLER (BJT)
# ==========================================
bjts = [
    ("BC547", "NPN", "TO-92", "CBE", 45, 0.1, 0.5), ("BC557", "PNP", "TO-92", "CBE", -45, -0.1, 0.5),
    ("2N2222", "NPN", "TO-92", "EBC", 40, 0.8, 0.5), ("2N3904", "NPN", "TO-92", "EBC", 40, 0.2, 0.6),
    ("BD139", "NPN", "TO-126", "ECB", 80, 1.5, 12), ("BD140", "PNP", "TO-126", "ECB", -80, -1.5, 12),
    ("TIP31C", "NPN", "TO-220", "BCE", 100, 3, 40), ("TIP32C", "PNP", "TO-220", "BCE", -100, -3, 40)
]
for b in bjts:
    scr = "TEST_BJT_NPN" if b[1] == "NPN" else "TEST_BJT_PNP"
    add_part(b[0], "BJT", b[1], b[2], b[3], b[4], b[5], b[6], scr, f"{b[1]} Transistor")

# ==========================================
# 3. ENTEGRELER & DİĞERLERİ
# ==========================================
add_part("NE555", "IC", "Timer", "DIP-8", "12345678", 16, 0.2, 0.6, "TEST_IC_GEN", "Precision Timer")
add_part("LM358", "IC", "OpAmp", "DIP-8", "12345678", 32, 0.05, 0.5, "TEST_IC_GEN", "Dual Op-Amp")
add_part("L7805CV", "IC", "Regulator", "TO-220", "IGO", 35, 1.5, 15, "TEST_REGULATOR_FIXED", "5V Regulator")
add_part("1N4007", "DIODE", "Rectifier", "DO-41", "AK", 1000, 1.0, 0, "TEST_DIODE", "1000V Rectifier")



# --- EXCEL OLUŞTURMA ---
cols = ["id", "category", "polarity", "package_id", "pinout_code", "v_max", "i_max", "power_max", "test_script_id", "description", "datasheet_url", "pin_names"]
df = pd.DataFrame(mega_db, columns=cols)

file_name = "electronic_components_db.xlsx"

# BURAYI DEĞİŞTİRDİK: sheet_name='Components' ekledik
df.to_excel(file_name, index=False, sheet_name='Components') 

print(f"\n✅ DOSYA HAZIR: {file_name}")
