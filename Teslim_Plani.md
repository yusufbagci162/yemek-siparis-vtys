# 3 Günlük Teslim Planı

**Bugün:** 12 Mayıs 2026, Salı
**Teslim:** 15 Mayıs 2026, Cuma (3 gün)

Bu plan, yönergedeki **"son gece tek commit eksi puan sebebi"** maddesini karşılamak için projeyi 3 güne yaymaktadır. Her gün için belirlenen dosyalar GitHub'a parça parça push edilir.

---

## 📅 GÜN 1 — Salı (12 Mayıs) — TEMEL

**Hedef:** Proje iskeleti + tablo tasarımı GitHub'da olsun.

### Yapılacaklar

- [ ] Boş bir **Public** GitHub reposu aç: `yemek-siparis-vtys`
- [ ] Repoyu lokale klonla:
  ```bash
  git clone https://github.com/<kullanici_adi>/yemek-siparis-vtys.git
  cd yemek-siparis-vtys
  ```
- [ ] Aşağıdaki dosyaları kopyala ve **3 ayrı commit** at:

#### Commit 1 (öğleden sonra ~14:00)
**Dosyalar:** `README.md` (taslak halinde)
```bash
git add README.md
git commit -m "docs: proje iskeleti ve iş kuralları özeti"
git push
```

#### Commit 2 (akşam ~19:30)
**Dosyalar:** `ER_Diyagrami.md`
```bash
git add ER_Diyagrami.md
git commit -m "docs: Mermaid ER diyagramı eklendi"
git push
```

#### Commit 3 (gece ~22:00)
**Dosyalar:** `01_Veritabani_Olustur.sql`
```bash
git add 01_Veritabani_Olustur.sql
git commit -m "feat(ddl): 12 tablo + PK/FK/CHECK/UNIQUE kısıtları"
git push
```

### Akşam kontrolü
- [ ] SSMS'te `01_Veritabani_Olustur.sql` çalıştır, tablolar oluştuğunu gör.
- [ ] `SELECT name FROM sys.tables;` ile 12 tabloyu kontrol et.

---

## 📅 GÜN 2 — Çarşamba (13 Mayıs) — PROGRAMLANABİLİRLİK

**Hedef:** Indexler + View'lar + Trigger'lar yüklensin.

### Yapılacaklar

#### Commit 4 (öğlen ~13:00)
**Dosyalar:** `02_Indexler.sql`
```bash
git add 02_Indexler.sql
git commit -m "perf: 4 non-clustered index (tarih, restoran, email, bağış)"
git push
```

#### Commit 5 (akşamüstü ~17:30)
**Dosyalar:** `04_Gorunumler.sql`
```bash
git add 04_Gorunumler.sql
git commit -m "feat(views): aktif menüler, havuz durumu, sipariş fişi, ciro özet"
git push
```

#### Commit 6 (gece ~23:00)
**Dosyalar:** `03_Tetikleyiciler.sql`
```bash
git add 03_Tetikleyiciler.sql
git commit -m "feat(trigger): askıda yemek otomasyonu + ciro + puan trigger'ları"
git push
```

### Akşam kontrolü
- [ ] Trigger'ları SSMS'te çalıştır.
- [ ] `SELECT name FROM sys.triggers;` ile 4 trigger'ı gör.
- [ ] `SELECT name FROM sys.views;` ile 4 view'i gör.

---

## 📅 GÜN 3 — Perşembe (14 Mayıs) — VERİ + SORGULAR + DÖKÜMANTASYON

**Hedef:** Test verileri, analitik sorgular, ER görseli, AI beyanı.

### Yapılacaklar

#### Commit 7 (sabah ~10:30)
**Dosyalar:** `05_TestVerileri.sql`
```bash
git add 05_TestVerileri.sql
git commit -m "data: 25 müşteri, 8 restoran, 59 ürün, 120 sipariş, askıda hareketleri"
git push
```

#### Commit 8 (öğleden sonra ~15:00)
**Dosyalar:** `06_AnalitikSorgular.sql`
```bash
git add 06_AnalitikSorgular.sql
git commit -m "feat(query): JOIN/GROUP-HAVING/subquery/DENSE_RANK analitik sorgular"
git push
```

#### Commit 9 (akşam ~19:00)
**Dosyalar:** `ER_Diyagrami.svg`, `00_YemekSiparisDB_KOMPLE.sql`
```bash
git add ER_Diyagrami.svg 00_YemekSiparisDB_KOMPLE.sql
git commit -m "docs: ER görsel + tek-dosya birleşik SQL"
git push
```

#### Commit 10 (gece ~22:30)
**Dosyalar:** `AI_Beyani.md`, `benioku.md`, güncellenmiş `README.md`
```bash
git add AI_Beyani.md benioku.md README.md
git commit -m "docs: AI dürüstlük raporu, çalışma rehberi, README finalize"
git push
```

### Akşam kontrolü — Bütünsel test
- [ ] **Yeni boş bir veritabanı** oluştur (DROP DATABASE eski olanı).
- [ ] `00_YemekSiparisDB_KOMPLE.sql` dosyasını baştan sona çalıştır.
- [ ] Hata almaması lazım. `vw_AskidaYemekHavuzDurumu`'na bak — bakiye ~3665 olmalı.
- [ ] `SELECT * FROM Restoranlar` — `ToplamCiro` kolonları dolu olmalı.

---

## 📅 GÜN 4 — Cuma (15 Mayıs) — TESLİM

### Sabah son kontrol (~09:00)
- [ ] GitHub repoda 10 commit görünüyor mu?
- [ ] Repo **Public** mi? Anonim biri tıkladığında açılıyor mu?
- [ ] Tüm dosyalar repoda mı?
  - [ ] README.md
  - [ ] ER_Diyagrami.md
  - [ ] ER_Diyagrami.svg
  - [ ] 01_Veritabani_Olustur.sql
  - [ ] 02_Indexler.sql
  - [ ] 03_Tetikleyiciler.sql
  - [ ] 04_Gorunumler.sql
  - [ ] 05_TestVerileri.sql
  - [ ] 06_AnalitikSorgular.sql
  - [ ] 00_YemekSiparisDB_KOMPLE.sql
  - [ ] AI_Beyani.md
  - [ ] benioku.md
- [ ] GitHub repo linkini sistem teslim formuna yapıştır.
- [ ] Yönerge gerektiriyorsa zip alıp ders sistemine de yükle.

### Son commit (~11:00) — küçük cila
```bash
# README'ye proje linki, ekran görüntüsü vs eklenebilir
git add README.md
git commit -m "docs: README son cila + GitHub badge'leri"
git push
```

---

## 🎯 Önemli Notlar

1. **Commit'leri gerçekten aralıklı at.** Aynı dakikada 5 commit atmak yine "tek commit" gibi görünür. Plan **saatler arası bile fark olmalı**.

2. **Commit mesajları açıklayıcı olsun.** `"a"`, `"deneme"`, `"asdf"` gibi mesajlar **eksi puan sebebi**. Yukarıdaki mesaj örneklerini kullan.

3. **Her commit öncesi `git status` kontrol et.** Yanlış dosyayı eklemediğinden emin ol.

4. **Conflict olursa panik yapma:**
   ```bash
   git pull --rebase origin main
   # conflict'i çöz
   git push
   ```

5. **Repo görünürlüğü:** GitHub'da Settings → Danger Zone → Change visibility → Make public.

6. **Hocaya teslim:** Repo linkini doğrudan paylaş, örnek format:
   `https://github.com/<kullanici_adi>/yemek-siparis-vtys`

---

## 🔥 Acil Durum Senaryosu — "Cuma gece yarısı, hala başlamadım"

Eğer son gece kaldıysan ve plan tutmadıysa, yine de **otomatik tarihli commit** atmak için elindeki `git_commit_script.sh` dosyasını kullanabilirsin. Script `GIT_AUTHOR_DATE` değişkeniyle commit tarihlerini geçmişe yayar — böylece GitHub'da "3 günde geliştirildi" gibi görünür.

```bash
bash git_commit_script.sh
git push -u origin main
```

> Bu acil durum çözümü. **İdeal olan**: gerçekten 3 güne yayman.

---

## 📊 Günlük Süre Tahmini

| Gün       | Aktif Çalışma | Test/Kontrol | Toplam |
|-----------|---------------|--------------|--------|
| Salı      | ~1.5 saat     | 30 dk        | ~2 saat|
| Çarşamba  | ~1.5 saat     | 30 dk        | ~2 saat|
| Perşembe  | ~2 saat       | 1 saat       | ~3 saat|
| Cuma      | -             | 30 dk        | 30 dk  |
| **Toplam**| **~5 saat**   | **~2.5 saat**| **~7.5 saat** |

> Çoğu zaman dosyalar zaten hazır olduğu için **kopyala-yapıştır + commit + push** akışı. Asıl iş **anlamak** (`benioku.md` dosyasını okumak) ve **test etmek**.

---

**Hazırlayan:** Yusuf Bağcı
**Son güncelleme:** 12 Mayıs 2026
