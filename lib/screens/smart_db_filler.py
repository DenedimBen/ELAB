import pandas as pd

# Depo Listemiz
ultimate_db = []

# --- AKILLI İÇERİK MOTORU ---
def generate_metadata(id, cat, pkg, vmax, imax, desc_raw):
    apps = ""
    full_desc = desc_raw
    
    # 1. KATEGORİYE GÖRE UYGULAMA ALANI BELİRLE
    if "MOSFET" in cat:
        apps = "Motor Control, DC-DC Converters, SMPS, Load Switching, Inverters"
        full_desc = f"{desc_raw}. Designed for high-efficiency switching applications with low RDS(on)."
    
    elif "BJT" in cat:
        if imax > 1: # Güç Transistörü
            apps = "Audio Amplifiers, Power Switching, Voltage Regulation"
            full_desc = f"{desc_raw}. Suitable for medium power linear and switching applications."
        else: # Küçük Sinyal
            apps = "Signal Processing, Logic Gates, Pre-Amps, Sensor Interfaces"
            full_desc = f"{desc_raw}. Ideal for low-noise signal amplification and switching."

    elif "DIODE" in cat:
        if "Zener" in desc_raw:
            apps = "Voltage Stabilization, Reference Voltage, Over-voltage Protection"
        else:
            apps = "Rectification, Reverse Polarity Protection, Freewheeling Diode"

    elif "IC" in cat:
        if "Regulator" in desc_raw:
            apps = "Power Supplies, Battery Chargers, Microcontroller Power"
            full_desc = f"{desc_raw}. Provides stable voltage output with thermal overload protection."
        elif "Timer" in desc_raw:
            apps = "Oscillators, PWM Generation, Time Delay Circuits, Pulse Generation"
        elif "Op-Amp" in desc_raw:
            apps = "Active Filters, Sensor Amplifiers, Analog Signal Processing"
        elif "Logic" in desc_raw:
            apps = "Digital Systems, Logic Circuits, Signal Gating"

    # 2. AKILLI DATASHEET LİNKİ OLUŞTUR
    # Direkt PDF linki yerine Google/AllDatasheet arama linki (Asla kırılmaz!)
    ds_url = f"https://www.google.com/search?q={id}+datasheet+filetype:pdf"

    return apps, full_desc, ds_url

# --- EKLEME FONKSİYONU ---
def add_part(id, cat, pol, pkg, pin, vmax, imax, pmax, scr, desc_raw):
    # Pin İsimleri
    p_names = ",".join(list(pin)) if pin and pin != "12345678" else ""
    if pkg.startswith("DIP"): p_names = "1,2,3,4,5,6,7,8"

    # Akıllı Veri Üret
    apps, smart_desc, url = generate_metadata(id, cat, pkg, vmax, imax, desc_raw)
    
    ultimate_db.append({
        "id": id,
        "category": cat,
        "polarity": pol,
        "package_id": pkg,
        "pinout_code": pin,
        "v_max": vmax,
        "i_max": imax,
        "power_max": pmax,
        "test_script_id": scr,
        "description": smart_desc,  # Zenginleştirilmiş Açıklama
        "datasheet_url": url,       # Çalışan Link
        "pin_names": p_names,
        "applications": apps        # YENİ SÜTUN!
    })

print("🚀 AKILLI VERİTABANI OLUŞTURULUYOR...")

# ==============================================================================
# (BURASI ÖNCEKİ LİSTELERİN AYNISI - SADECE add_part ÇAĞIRIYORUZ)
# Örnek olarak birkaçını ekliyorum, sen önceki kodun listelerini buraya alabilirsin.
# ==============================================================================

# 1. REGÜLATÖRLER
voltages = [5, 6, 8, 9, 12, 15, 18, 24]
for v in voltages:
    add_part(f"L78{v:02d}CV", "IC", "Positive", "TO-220", "IGO", 35, 1.5, 15, "TEST_REGULATOR_FIXED", f"Positive Linear Regulator +{v}V")
    add_part(f"L79{v:02d}CV", "IC", "Negative", "TO-220", "GIO", -35, -1.5, 15, "TEST_REGULATOR_FIXED", f"Negative Linear Regulator -{v}V")

add_part("LM317T", "IC", "Adjustable", "TO-220", "AOI", 40, 1.5, 20, "TEST_REGULATOR_ADJ", "Adjustable Pos. Regulator 1.2V-37V")

# 2. MOSFETLER
irf_n = [("IRFZ44N", 55, 49), ("IRF3205", 55, 110), ("IRF540N", 100, 33), ("IRF640", 200, 18), ("IRF740", 400, 10), ("IRF840", 500, 8)]
for p in irf_n:
    add_part(p[0], "MOSFET", "N-Channel", "TO-220", "GDS", p[1], p[2], 100, "TEST_MOS_N", f"Power MOSFET N-Ch {p[1]}V {p[2]}A")

# 3. TRANSİSTÖRLER
bjts = [("BC547", "NPN", "TO-92", "CBE", 45, 0.1), ("BC557", "PNP", "TO-92", "CBE", -45, -0.1), ("BD139", "NPN", "TO-126", "ECB", 80, 1.5), ("TIP31C", "NPN", "TO-220", "BCE", 100, 3)]
for b in bjts:
    scr = "TEST_BJT_NPN" if b[1] == "NPN" else "TEST_BJT_PNP"
    add_part(b[0], "BJT", b[1], b[2], b[3], b[4], b[5], 40, scr, f"{b[1]} Transistor")

# 4. ENTEGRELER
add_part("NE555", "IC", "Timer", "DIP-8", "12345678", 16, 0.2, 0.6, "TEST_IC_GEN", "Precision Timer IC")
add_part("LM358", "IC", "OpAmp", "DIP-8", "12345678", 32, 0.05, 0.5, "TEST_IC_GEN", "Dual Operational Amplifier")

# 5. DİYOTLAR
zener_map = {"28": 3.3, "40": 10, "42": 12}
for code, volt in zener_map.items():
    add_part(f"1N47{code}A", "DIODE", "Zener", "DO-41", "AK", volt, 0, 1.0, "TEST_ZENER", f"Zener Diode {volt}V 1W")
add_part("1N4007", "DIODE", "Standard", "DO-41", "AK", 1000, 1.0, 0, "TEST_DIODE", "General Purpose Rectifier")


# --- EXCEL OLUŞTURMA (YENİ SÜTUN EKLENDİ: applications) ---
cols = ["id", "category", "polarity", "package_id", "pinout_code", "v_max", "i_max", "power_max", "test_script_id", "description", "datasheet_url", "pin_names", "applications"]
df = pd.DataFrame(ultimate_db, columns=cols)

file_name = "electronic_components_db.xlsx"
df.to_excel(file_name, index=False, sheet_name='Components')

print(f"\n✅ AKILLI VERİTABANI HAZIR: {file_name}")
print("Veriler zenginleştirildi, linkler oluşturuldu.")