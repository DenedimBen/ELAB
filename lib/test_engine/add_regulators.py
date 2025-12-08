import pandas as pd

# Depo Listemiz
ultimate_db = []

# --- YARDIMCI FONKSİYON ---
def add_part(id, cat, pol, pkg, pin, vmax, imax, pmax, scr, desc):
    # Pin isimlerini virgülle birleştir
    p_names = ",".join(list(pin)) if pin and pin != "12345678" else ""
    if pkg.startswith("DIP"): p_names = "1,2,3,4,5,6,7,8" # IC'ler için standart
    
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
        "description": desc,
        "datasheet_url": "", # İstersen doldurulabilir
        "pin_names": p_names
    })

print("🚀 E-LAB ULTIMATE VERİTABANI OLUŞTURULUYOR...")

# ==============================================================================
# BÖLÜM 1: VOLTAJ REGÜLATÖRLERİ (DOĞRU PINOUT GARANTİLİ)
# ==============================================================================
print("...Regülatörler işleniyor")

# 1.1 L78xx ve LM78xx Serisi (Pozitif) -> Pinout: INPUT-GND-OUTPUT (IGO)
voltages = [5, 6, 8, 9, 10, 12, 15, 18, 24]
for v in voltages:
    v_str = f"{v:02d}" # 05, 06 gibi yapar
    desc = f"Positive Linear Regulator +{v}V 1.5A"
    # L78 serisi
    add_part(f"L78{v_str}CV", "IC", "Positive", "TO-220", "IGO", 35, 1.5, 15, "TEST_REGULATOR_FIXED", desc)
    add_part(f"LM78{v_str}", "IC", "Positive", "TO-220", "IGO", 35, 1.5, 15, "TEST_REGULATOR_FIXED", desc)
    add_part(f"MC78{v_str}", "IC", "Positive", "TO-220", "IGO", 35, 1.5, 15, "TEST_REGULATOR_FIXED", desc)

# 1.2 L79xx ve LM79xx Serisi (Negatif) -> Pinout: GND-INPUT-OUTPUT (GIO) !!! KRİTİK FARK !!!
for v in voltages:
    v_str = f"{v:02d}"
    desc = f"Negative Linear Regulator -{v}V 1.5A"
    add_part(f"L79{v_str}CV", "IC", "Negative", "TO-220", "GIO", -35, -1.5, 15, "TEST_REGULATOR_FIXED", desc)
    add_part(f"LM79{v_str}", "IC", "Negative", "TO-220", "GIO", -35, -1.5, 15, "TEST_REGULATOR_FIXED", desc)

# 1.3 LDO ve Ayarlanabilirler
add_part("LM317T", "IC", "Adjustable", "TO-220", "AOI", 40, 1.5, 20, "TEST_REGULATOR_ADJ", "Adj. Pos. Regulator 1.2V-37V")
add_part("LM337T", "IC", "Adjustable", "TO-220", "AIO", -40, -1.5, 20, "TEST_REGULATOR_ADJ", "Adj. Neg. Regulator -1.2V to -37V")
add_part("LM1117-3.3", "IC", "LDO", "SOT-223", "GOC", 15, 0.8, 1, "TEST_REGULATOR_FIXED", "3.3V LDO Regulator")
add_part("AMS1117-3.3", "IC", "LDO", "SOT-223", "GOC", 15, 1.0, 1, "TEST_REGULATOR_FIXED", "3.3V LDO Regulator")
add_part("AMS1117-5.0", "IC", "LDO", "SOT-223", "GOC", 15, 1.0, 1, "TEST_REGULATOR_FIXED", "5.0V LDO Regulator")
add_part("TL431", "IC", "Shunt Reg", "TO-92", "RKA", 36, 0.1, 0.5, "TEST_REF_VOLT", "Programmable Precision Reference")

# ==============================================================================
# BÖLÜM 2: MOSFETLER (POPÜLER SERİLER)
# ==============================================================================
print("...MOSFET'ler işleniyor")

# 2.1 IRF Serisi N-Kanal (TO-220 -> GDS)
irf_n = [
    ("IRFZ44N", 55, 49), ("IRF3205", 55, 110), ("IRF510", 100, 5.6), ("IRF520", 100, 9.2),
    ("IRF530", 100, 14), ("IRF540N", 100, 33), ("IRF630", 200, 9), ("IRF640", 200, 18),
    ("IRF730", 400, 5.5), ("IRF740", 400, 10), ("IRF830", 500, 4.5), ("IRF840", 500, 8),
    ("IRF1010E", 60, 84), ("IRF1404", 40, 202), ("IRF2807", 75, 82), ("IRF3710", 100, 57),
    ("IRLB3034", 40, 195), ("IRL540", 100, 28) # Logic Level
]
for p in irf_n:
    add_part(p[0], "MOSFET", "N-Channel", "TO-220", "GDS", p[1], p[2], 100, "TEST_MOS_N", f"Power MOSFET N-Ch {p[1]}V {p[2]}A")

# 2.2 IRF Serisi P-Kanal (TO-220 -> GDS)
irf_p = [
    ("IRF9530", -100, -12), ("IRF9540", -100, -23), ("IRF9640", -200, -11), 
    ("IRF4905", -55, -74), ("IRF5210", -100, -40)
]
for p in irf_p:
    add_part(p[0], "MOSFET", "P-Channel", "TO-220", "GDS", p[1], p[2], 100, "TEST_MOS_P", f"Power MOSFET P-Ch {p[1]}V {p[2]}A")

# 2.3 Küçük Sinyal (TO-92 -> DİKKAT: Pinoutlar Karışık!)
add_part("2N7000", "MOSFET", "N-Channel", "TO-92", "SGD", 60, 0.2, 0.4, "TEST_MOS_N", "Small Signal FET (Pinout: SGD)")
add_part("BS170", "MOSFET", "N-Channel", "TO-92", "DGS", 60, 0.5, 0.8, "TEST_MOS_N", "Small Signal FET (Pinout: DGS)")
add_part("BS250", "MOSFET", "P-Channel", "TO-92", "DGS", -45, -0.2, 0.8, "TEST_MOS_P", "Small Signal P-Ch FET")

# ==============================================================================
# BÖLÜM 3: TRANSİSTÖRLER (BJT) - PINOUT GRUPLANDIRMASI
# ==============================================================================
print("...Transistörler işleniyor")

# 3.1 BC Serisi (Avrupa) -> Genelde CBE
bc_npn = ["BC546", "BC547", "BC548", "BC549", "BC550", "BC337", "BC237"]
bc_pnp = ["BC556", "BC557", "BC558", "BC559", "BC560", "BC327", "BC307"]

for t in bc_npn:
    add_part(t, "BJT", "NPN", "TO-92", "CBE", 45, 0.1, 0.5, "TEST_BJT_NPN", "General Purpose NPN (CBE)")
for t in bc_pnp:
    add_part(t, "BJT", "PNP", "TO-92", "CBE", -45, -0.1, 0.5, "TEST_BJT_PNP", "General Purpose PNP (CBE)")

# 3.2 2N Serisi (ABD) -> Genelde EBC (BC serisinin tam tersi!)
tn_npn = ["2N2222", "2N3904", "2N4401", "2N5551", "PN2222"]
tn_pnp = ["2N2907", "2N3906", "2N4403", "2N5401"]

for t in tn_npn:
    add_part(t, "BJT", "NPN", "TO-92", "EBC", 40, 0.6, 0.6, "TEST_BJT_NPN", "Switching NPN (EBC)")
for t in tn_pnp:
    add_part(t, "BJT", "PNP", "TO-92", "EBC", -40, -0.6, 0.6, "TEST_BJT_PNP", "Switching PNP (EBC)")

# 3.3 Güç Transistörleri (TIP -> BCE, BD -> ECB)
tips = [
    ("TIP31C", "NPN", "BCE"), ("TIP32C", "PNP", "BCE"),
    ("TIP41C", "NPN", "BCE"), ("TIP42C", "PNP", "BCE"),
    ("TIP120", "NPN", "BCE"), ("TIP122", "NPN", "BCE"), # Darlington
    ("TIP127", "PNP", "BCE"), # Darlington PNP
    ("BD135", "NPN", "ECB"), ("BD136", "PNP", "ECB"),
    ("BD139", "NPN", "ECB"), ("BD140", "PNP", "ECB")
]
for t in tips:
    scr = "TEST_BJT_NPN" if t[1] == "NPN" else "TEST_BJT_PNP"
    pkg = "TO-220" if "TIP" in t[0] else "TO-126"
    desc = f"Power Transistor {t[1]} ({t[2]})"
    if "120" in t[0] or "122" in t[0]: desc = "Darlington Power NPN"
    add_part(t[0], "BJT", t[1], pkg, t[2], 100, 3, 40, scr, desc)

# Metal Kılıf (TO-3)
add_part("2N3055", "BJT", "NPN", "TO-3", "BCE", 60, 15, 115, "TEST_BJT_NPN", "Vintage Power NPN")
add_part("MJ2955", "BJT", "PNP", "TO-3", "BCE", -60, -15, 115, "TEST_BJT_PNP", "Vintage Power PNP")

# ==============================================================================
# BÖLÜM 4: DİYOTLAR (ZENERLER DAHİL)
# ==============================================================================
print("...Diyotlar işleniyor")

# 4.1 Zener Serisi (1N47xx) -> 3.3V'dan 30V'a otomatik üretim
zener_map = {
    "28": 3.3, "29": 3.6, "30": 3.9, "31": 4.3, "32": 4.7, "33": 5.1, "34": 5.6, 
    "35": 6.2, "36": 6.8, "37": 7.5, "38": 8.2, "39": 9.1, "40": 10, "41": 11,
    "42": 12, "43": 13, "44": 15, "45": 16, "46": 18, "47": 20, "48": 22, 
    "49": 24, "50": 27, "51": 30
}
for code, volt in zener_map.items():
    add_part(f"1N47{code}A", "DIODE", "Zener", "DO-41", "AK", volt, 0, 1.0, "TEST_ZENER", f"Zener Diode {volt}V 1W")
    # 0.5W Serisi (BZX55C)
    add_part(f"BZX55C{int(volt)}V{int((volt%1)*10)}", "DIODE", "Zener", "DO-35", "AK", volt, 0, 0.5, "TEST_ZENER", f"Zener Diode {volt}V 0.5W")

# 4.2 Standart ve Schottky
rectifiers = [
    ("1N4001", 50, 1), ("1N4004", 400, 1), ("1N4007", 1000, 1),
    ("1N5400", 50, 3), ("1N5408", 1000, 3), ("6A10", 1000, 6),
    ("1N4148", 100, 0.2), ("1N914", 100, 0.2), # Signal
    ("1N5817", 20, 1), ("1N5819", 40, 1), ("1N5822", 40, 3), ("SR560", 60, 5), # Schottky
    ("FR107", 1000, 1), ("UF4007", 1000, 1) # Fast Recovery
]
for r in rectifiers:
    desc = "Rectifier Diode" if "400" in r[0] else ("Schottky" if "58" in r[0] else "Fast Diode")
    add_part(r[0], "DIODE", "Standard", "DO-41", "AK", r[1], r[2], 0, "TEST_DIODE", f"{desc} {r[1]}V {r[2]}A")

# ==============================================================================
# BÖLÜM 5: ENTEGRELER (IC)
# ==============================================================================
print("...Entegreler işleniyor")

ics = [
    ("NE555", "DIP-8", "Timer IC"), ("LM555", "DIP-8", "Timer IC"),
    ("LM358", "DIP-8", "Dual Op-Amp"), ("LM324", "DIP-14", "Quad Op-Amp"),
    ("LM741", "DIP-8", "Single Op-Amp"), ("TL071", "DIP-8", "Low Noise JFET Op-Amp"),
    ("TL072", "DIP-8", "Dual JFET Op-Amp"), ("TL074", "DIP-14", "Quad JFET Op-Amp"),
    ("LM386", "DIP-8", "Audio Amplifier"), ("LM393", "DIP-8", "Dual Comparator"),
    ("UC3842", "DIP-8", "PWM Controller"), ("UC3843", "DIP-8", "PWM Controller"),
    ("PC817", "DIP-4", "Optocoupler"), ("4N35", "DIP-6", "Optocoupler"),
    ("MOC3021", "DIP-6", "Triac Driver Opto"),
    ("ULN2003", "DIP-16", "Darlington Array (Driver)"),
    ("L293D", "DIP-16", "H-Bridge Motor Driver")
]
for ic in ics:
    pinout = "12345678" 
    if "DIP-4" in ic[1]: pinout = "1234"
    elif "DIP-6" in ic[1]: pinout = "123456"
    elif "DIP-14" in ic[1]: pinout = "1234567-891011121314" # Temsili
    elif "DIP-16" in ic[1]: pinout = "12345678-910111213141516"
    
    add_part(ic[0], "IC", "Generic", ic[1], pinout, 30, 0, 0.5, "TEST_IC_GEN", ic[2])

# Logic Gates (74HCxx)
logic = [
    ("74HC00", "NAND"), ("74HC02", "NOR"), ("74HC04", "NOT"), ("74HC08", "AND"),
    ("74HC32", "OR"), ("74HC86", "XOR"), ("74HC595", "Shift Register"), ("CD4017", "Counter")
]
for l in logic:
    add_part(l[0], "IC", "Logic", "DIP-14", "STD_LOGIC", 5, 0, 0, "TEST_LOGIC", f"Logic IC: {l[1]}")


# --- EXCEL OLUŞTURMA ---
cols = ["id", "category", "polarity", "package_id", "pinout_code", "v_max", "i_max", "power_max", "test_script_id", "description", "datasheet_url", "pin_names"]
df = pd.DataFrame(ultimate_db, columns=cols)

file_name = "electronic_components_db.xlsx"

# SHEET NAME 'Components' OLARAK AYARLANDI ✅
df.to_excel(file_name, index=False, sheet_name='Components')

print(f"\n✅ İŞLEM TAMAMLANDI!")
print(f"📦 {len(ultimate_db)} adet yüksek kaliteli bileşen oluşturuldu.")
print(f"📂 Dosya: {file_name}")
print("⚠️ UNUTMA: 'flutter clean' yapmadan yeni veriler gelmez!")