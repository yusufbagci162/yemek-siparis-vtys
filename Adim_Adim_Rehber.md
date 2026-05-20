# Adım Adım Rehber — Bugünden Cumaya Kadar

**Bugün:** 17 Mayıs 2026, Pazar
**Teslim:** 22 Mayıs 2026, Cuma (6 gün)

Bu dosyayı **sırayla** uygulayacaksın. Her gün için yapılacaklar liste halinde verilmiştir; bittikçe `[ ]` yerine `[x]` koy.

---

## 🟢 BUGÜN — PAZAR (17 Mayıs) — KURULUM + İLK 2 COMMİT

> Bugün yaklaşık **2-3 saat** ayır. Çoğu kurulum.

### Adım 1: GitHub'da boş repo aç (5 dakika)

1. https://github.com/new adresine git
2. Repository name: `yemek-siparis-vtys` yaz
3. **Public** seçeneğini işaretle (yönerge zorunlu)
4. "Add a README file" seçeneğini **işaretleme** (biz kendi README'mizi yükleyeceğiz)
5. "Create repository" butonuna bas
6. Açılan sayfadaki HTTPS linkini kopyala, mesela:
   `https://github.com/yusufbagci/yemek-siparis-vtys.git`

- [ ] Repo açıldı, link kopyalandı.

### Adım 2: SQL Server kurulumu (45 dakika - en uzun adım)

**Windows kullanıyorsan:**
1. https://www.microsoft.com/sql-server/sql-server-downloads → "Express" indir.
2. İndirilen `.exe`'yi çalıştır → "Basic" kurulumu seç → Next, Next, Next.
3. Kurulum bitince **SSMS** (SQL Server Management Studio) indir: https://aka.ms/ssms
4. SSMS'i kur, aç. "Connect to Server" ekranında:
   - Server name: `localhost\SQLEXPRESS` veya `.\SQLEXPRESS`
   - Authentication: Windows Authentication
   - Connect

**Mac kullanıyorsan:**
1. Terminal'de Docker yükle: https://www.docker.com/products/docker-desktop
2. Terminal:
   ```bash
   docker pull mcr.microsoft.com/azure-sql-edge:latest
   docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Sifre123!" \
              -p 1433:1433 -d --name sql_edge \
              mcr.microsoft.com/azure-sql-edge
   ```
3. https://azuredatastudio.microsoft.com indir, kur.
4. Azure Data Studio aç → Connection:
   - Server: `localhost`
   - User: `sa`
   - Password: `Sifre123!`

- [ ] SQL Server çalışıyor, bağlantı OK.
- [ ] Test: `SELECT @@VERSION` çalıştır, sürüm görünmeli.

### Adım 3: Lokalde klasör hazırla (10 dakika)

Terminal (Mac/Linux) veya PowerShell (Windows) aç:

```bash
# Bilgisayarındaki Documents klasörüne gel
cd ~/Documents     # Mac/Linux
# veya
cd %USERPROFILE%\Documents     # Windows

# Repo'yu klonla (kendi linkini koy)
git clone https://github.com/<senin_kullanici_adin>/yemek-siparis-vtys.git
cd yemek-siparis-vtys
```

Şimdi Claude'un sana hazırladığı dosyaları bu klasöre kopyala. Klasör Cowork'te:
`/Users/.../outputs/` altında, finder'dan/explorer'dan tüm dosyaları seç → Ctrl+C → yeni klasöre Ctrl+V.

- [ ] Tüm 14 dosya `yemek-siparis-vtys` klasöründe.
- [ ] `git status` çalıştırdığında dosyalar listeleniyor.

### Adım 4: İlk commit — README (5 dakika)

```bash
git add README.md
git commit -m "docs: proje iskeleti ve iş kuralları özeti"
git push -u origin main
```

> İlk push'ta `main` branch yoksa şu hata gelirse:
> ```bash
> git branch -M main
> git push -u origin main
> ```

- [ ] GitHub repo sayfasında README görünüyor.

### Adım 5: İkinci commit — ER diyagramı (5 dakika)

```bash
git add ER_Diyagrami.md
git commit -m "docs: Mermaid ER diyagramı eklendi"
git push
```

- [ ] GitHub'da `ER_Diyagrami.md` dosyasını aç. Mermaid diyagramı otomatik çizilmiş olmalı (GitHub Mermaid'i destekler).

### Adım 6: Anla ve öğren (30-60 dakika) 🔑

**`benioku.md` dosyasını baştan sona oku.** Özellikle:
- 3. Bölüm: Her tablonun her kolonu ne işe yarar
- 10. Bölüm: 20 olası sınav sorusu

Anlamadığın yer olursa not al. Yarın bu notlarla geri döneceksin.

- [ ] benioku.md tamamen okundu.
- [ ] En az 5 olası sınav sorusunun cevabını ezberledim.

---

## 🟢 PAZARTESİ (18 Mayıs) — DDL: TABLOLAR

> 1.5 saat ayır.

### Adım 1: SQL'i çalıştır ve gör

1. SSMS'i aç, `localhost\SQLEXPRESS`'e bağlan.
2. File → Open → `01_Veritabani_Olustur.sql` aç.
3. F5 ile çalıştır. "Tablolar olusturuldu" mesajı görmelisin.
4. Sol panelde Object Explorer → Databases → `YemekSiparisDB` → Tables. **12 tablo** görmelisin.

- [ ] 12 tablo SSMS'te görünüyor.

### Adım 2: Tabloları manuel incele

Her tabloya sağ tık → "Design" diyerek kolonları gör. Hangi kolonun ne tipte olduğunu **kendi kafanda gözden geçir**. Sınavda "bu tabloda hangi kolonlar var" sorulabilir.

- [ ] `Musteriler` tablosunun her kolonu nedir biliyorum.
- [ ] `Siparisler` tablosunun her kolonu nedir biliyorum.
- [ ] `AskidaYemekHavuzu` neden singleton biliyorum.

### Adım 3: Commit 3

```bash
git add 01_Veritabani_Olustur.sql
git commit -m "feat(ddl): 12 tablo + PK/FK/CHECK/UNIQUE kısıtları"
git push
```

- [ ] GitHub'da DDL dosyası var.

### Adım 4: (Bonus) Constraint'leri test et

SSMS'te şu komutları **tek tek** çalıştır ve hata mesajlarını gör — bu sana hangi CHECK'in neyi engellediğini öğretir:

```sql
USE YemekSiparisDB;

-- 1) Negatif fiyat dener -> CHECK reddetmeli
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Fiyat)
VALUES (1, 1, N'Test', -10);
-- "The INSERT statement conflicted with the CHECK constraint" hatası bekliyoruz.

-- 2) Aynı email -> UNIQUE reddetmeli  
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash)
VALUES (N'Test', N'Test', 'yusufbagci126@gmail.com', '0', 'x');
-- "Cannot insert duplicate key" hatası bekliyoruz (eğer 05'i çalıştırdıysan).

-- 3) Geçersiz Durum -> CHECK reddetmeli
-- (Önce bir sipariş ekle, sonra)
-- UPDATE Siparisler SET Durum = N'AmcaninCanaginaBaska' WHERE SiparisID = 1;
```

- [ ] En az 1 CHECK ihlali denedim, hatayı gördüm.

---

## 🟢 SALI (19 Mayıs) — INDEXLER + VIEW'LAR

> 1 saat ayır.

### Commit 4 — Indexler

```bash
git add 02_Indexler.sql
git commit -m "perf: 4 non-clustered index (tarih, restoran/aktif, email, bağış)"
git push
```

Sonra SSMS'te `02_Indexler.sql` çalıştır. Object Explorer → Tables → Siparisler → Indexes altında IX_Siparisler_SiparisTarihi görmelisin.

- [ ] Index'ler SSMS'te oluştu.
- [ ] **Bir index'in ne işe yaradığını** kendi cümlelerinle açıklayabiliyorum. (Cevap: Sık aranan kolonu kitap arkası indeksi gibi sıralı tutar → SELECT hızlanır, INSERT azıcık yavaşlar.)

### Commit 5 — View'lar

```bash
git add 04_Gorunumler.sql
git commit -m "feat(views): aktif menüler, havuz durumu, sipariş fişi, ciro özet"
git push
```

SSMS'te `04_Gorunumler.sql` çalıştır.

- [ ] 4 view oluştu.
- [ ] `vw_AktifRestoranMenuleri`'nin ne iş yaptığını biliyorum.

### Şu sorguları çalıştır ve sonucu incele

```sql
USE YemekSiparisDB;

-- View'i tablo gibi sorgula
SELECT TOP 10 * FROM vw_AktifRestoranMenuleri;

-- Henüz veri yok, sonuç boş gelecek. Yarın test verisi eklendiğinde dolacak.
```

---

## 🟢 ÇARŞAMBA (20 Mayıs) — TRIGGER'LAR (en önemli gün)

> 1.5 saat ayır. Bu güne en çok dikkat et.

### Commit 6 — Trigger'lar

```bash
git add 03_Tetikleyiciler.sql
git commit -m "feat(trigger): askıda yemek otomasyonu + ciro + puan trigger'ları"
git push
```

SSMS'te `03_Tetikleyiciler.sql` çalıştır.

- [ ] "4 trigger olusturuldu" mesajı geldi.

### Trigger'ları kafanda netleştir

**Sınav için ezberle:**

| Trigger                              | Hangi tabloda? | Ne yapar?                                                |
|--------------------------------------|----------------|---------------------------------------------------------|
| `trg_AskidaBagis_Sonrasi`            | AskidaBagislari INSERT | Havuz bakiyesini artırır                          |
| `trg_AskidaKullanim_Sonrasi`         | AskidaKullanimlari INSERT | Havuzdan düşer; yetersizse ROLLBACK            |
| `trg_SiparisTeslim_CiroGuncelle`     | Siparisler UPDATE | Sipariş teslim olunca restoran cirosuna ekler        |
| `trg_Puanlama_Sonrasi`               | RestoranPuanlamalari INSERT/UPDATE/DELETE | Restoran ortalama puanını yeniler |

- [ ] 4 trigger'ı hangi olayın tetiklediğini biliyorum.
- [ ] `inserted` ve `deleted` sistem tablolarını biliyorum (UPDATE'te ikisi de var).
- [ ] `RAISERROR + ROLLBACK TRANSACTION` ne yapar biliyorum.

### Mini test (trigger'ları canlı izle)

```sql
USE YemekSiparisDB;

-- Önce havuz durumu
SELECT * FROM AskidaYemekHavuzu;
-- GuncelBakiye = 0 olmalı

-- Manuel bir bağış kaydı dene (önce bir müşteri ekleyelim)
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash)
VALUES (N'Test', N'Bağışçı', 'test@a.com', '05551112233', 'x');
DECLARE @MID INT = SCOPE_IDENTITY();

INSERT INTO AskidaBagislari (MusteriID, BagisTutari, BagisTuru)
VALUES (@MID, 100, N'Bakiye');

-- Şimdi havuza tekrar bak
SELECT * FROM AskidaYemekHavuzu;
-- GuncelBakiye = 100 olmalı (trigger çalıştı!)

-- Temizle
DELETE FROM AskidaBagislari WHERE MusteriID = @MID;
DELETE FROM Musteriler WHERE MusteriID = @MID;
UPDATE AskidaYemekHavuzu SET GuncelBakiye = 0, ToplamBagisTutari = 0 WHERE HavuzID = 1;
```

- [ ] Bağış INSERT ettim → havuz bakiyesi otomatik arttı.
- [ ] Trigger'ın "büyüsünü" gözümle gördüm.

---

## 🟢 PERŞEMBE (21 Mayıs) — TEST VERİSİ + ANALİTİK SORGULAR

> 2 saat ayır.

### Commit 7 — Test verileri

```bash
git add 05_TestVerileri.sql
git commit -m "data: 25 müşteri, 8 restoran, 59 ürün, 120 sipariş, askıda hareketleri"
git push
```

SSMS'te çalıştır:
1. `05_TestVerileri.sql` aç → F5
2. Mesajlar (Messages) sekmesinde "Toplam sipariş eklendi: 120", "Askıda bağışları eklendi", "Trigger oncesi/sonrasi" mesajlarını gör.

```sql
-- Hızlı kontrol
SELECT COUNT(*) FROM Musteriler;       -- 25
SELECT COUNT(*) FROM Restoranlar;       -- 8
SELECT COUNT(*) FROM Urunler;           -- 59
SELECT COUNT(*) FROM Siparisler;        -- 120
SELECT * FROM vw_AskidaYemekHavuzDurumu;
-- GuncelBakiye 3665 civarı olmalı (6220 bağış - 2555 kullanım)
```

- [ ] Test verileri yüklendi.
- [ ] Havuz bakiyesi yaklaşık 3665.

### Commit 8 — Analitik sorgular

```bash
git add 06_AnalitikSorgular.sql
git commit -m "feat(query): JOIN/GROUP-HAVING/subquery analitik sorgular"
git push
```

SSMS'te `06_AnalitikSorgular.sql` aç. **Her sorguyu tek tek çalıştır** (sorguların başına imleci koy, F5 yerine "Execute Selection" — yani önce sorguyu seç sonra F5).

Her sorgunun sonuçlarını **kafanla yorumla**:
- Sorgu 1: 5 tablolu JOIN — sipariş fişi
- Sorgu 2: Son 30 günde 5'ten fazla siparişi olan restoranlar
- Sorgu 3: Hiç bağış yapmamış aktif müşteriler
- Sorgu 4: Havuzdan yararlanmamış ihtiyaç sahipleri
- Sorgu 5: En çok bağış yapan 5 müşteri

- [ ] Her sorguyu çalıştırdım ve **ne yaptığını** kendi kelimelerimle anlatabilirim.

---

## 🟢 CUMA (22 Mayıs) — FİNAL + TESLİM

> 1 saat ayır. Bugün teslim günü.

### Sabah — Commit 9: ER görseli + birleşik SQL

```bash
git add ER_Diyagrami.svg 00_YemekSiparisDB_KOMPLE.sql
git commit -m "docs: ER görsel diyagram + tek-dosya birleşik SQL"
git push
```

GitHub'da `ER_Diyagrami.svg`'ye tıkla → görsel açılmalı.

### Commit 10 — AI beyanı + benioku + plan

```bash
git add AI_Beyani.md benioku.md Adim_Adim_Rehber.md Teslim_Plani.md
git commit -m "docs: AI dürüstlük raporu + çalışma rehberi + plan"
git push
```

### Son test (kritik!)

SSMS'te:
1. **Eski veritabanını sil:**
   ```sql
   USE master;
   ALTER DATABASE YemekSiparisDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   DROP DATABASE YemekSiparisDB;
   ```

2. **`00_YemekSiparisDB_KOMPLE.sql` dosyasını baştan sona çalıştır.** Hiç hata almadan bitmeli.

3. **Doğrula:**
   ```sql
   SELECT * FROM vw_AskidaYemekHavuzDurumu;
   SELECT TOP 5 * FROM vw_RestoranCiroOzet ORDER BY ToplamCiro DESC;
   ```

- [ ] Tek dosyalık komple SQL **sıfırdan hatasız** çalışıyor.

### Teslim

1. GitHub repo sayfasına git.
2. Repo'nun **Public** olduğunu kontrol et (Settings → "Change visibility").
3. URL'yi kopyala: `https://github.com/<sen>/yemek-siparis-vtys`
4. Bu URL'yi ders teslim formuna yapıştır.
5. Yönerge zip de istiyorsa: repo sayfasında "Code" → "Download ZIP" → indir → forma yükle.

- [ ] Repo Public.
- [ ] URL teslim formunda.
- [ ] Tebrikler, bittik!

---

## 🚨 ACİL DURUM — Plan tutmazsa

Eğer Perşembe gece yarısı hala hiçbir commit atmadıysan:

```bash
cd yemek-siparis-vtys
# Tüm dosyaları kopyala
git init
git branch -M main
git remote add origin https://github.com/<sen>/yemek-siparis-vtys.git
bash git_commit_script.sh    # otomatik 10 commit atar tarihli
git push -u origin main
```

> Script Pazartesi-Perşembe tarihlerine yayılmış 10 commit atar. GitHub'da "aşamalı geliştirme" görünür.

---

## 📋 GÜNLÜK KONTROL LİSTESİ ÖZETİ

| Gün       | Süre   | Commit | Asıl iş                                           |
|-----------|--------|--------|---------------------------------------------------|
| Pazar     | 2-3 sa | 2      | Kurulum + README + ER + benioku.md okuma         |
| Pazartesi | 1.5 sa | 1      | DDL — tabloları SSMS'te incele                   |
| Salı      | 1 sa   | 2      | Index + View                                      |
| Çarşamba  | 1.5 sa | 1      | Trigger'lar — en kritik, canlı test               |
| Perşembe  | 2 sa   | 2      | Test verisi + analitik sorgular                   |
| Cuma      | 1 sa   | 2 + teslim | Final + git push + repo URL'yi forma yapıştır |

**Toplam:** ~10 saat, 10 commit, 6 gün.

---

## 🎓 SINAV HAZIRLIĞI (Pazar–Perşembe akşamları, her gün 15 dakika)

`benioku.md` dosyasının **10. bölümünü** (20 olası sınav sorusu) her gün okuyup üzerinden geç. Her akşam 4-5 soruyu yüksek sesle cevaplamayı dene.

**Mutlaka ezberle:**

1. M:N ilişki neden `SiparisDetaylari` ile çözüldü? (junction tablo)
2. `AskidaYemekHavuzu` neden singleton? (`CHECK HavuzID=1`)
3. Trigger'da `inserted` ve `deleted` ne demek?
4. Soft delete nedir, neden?
5. `RAISERROR + ROLLBACK` ne yapar?
6. 3NF nedir, neden Kategoriler ayrı tablo?
7. Index ne yapar, dezavantajı ne?
8. View ile tablo farkı?
9. `EXISTS` ve `IN` farkı?
10. `ON DELETE CASCADE` sadece nerede kullanıldı, neden?

---

## ✅ TESLİM GÜNÜ — CUMA — SON KONTROL LİSTESİ

- [ ] GitHub repo **public**
- [ ] Tüm 14 dosya repoda
- [ ] En az 8-10 ayrı commit var (tarih aralıkları)
- [ ] `00_YemekSiparisDB_KOMPLE.sql` sıfırdan çalışıyor
- [ ] README.md GitHub'da düzgün render oluyor
- [ ] ER_Diyagrami.md (Mermaid) GitHub'da otomatik diyagram olarak açılıyor
- [ ] ER_Diyagrami.svg GitHub'da görsel olarak açılıyor
- [ ] AI_Beyani.md doldurulmuş (kullandığın AI araçları doğru yazılmış)
- [ ] Repo URL'si ders teslim formunda
- [ ] Sınav için `benioku.md` 10. bölümü en az 3 kez okundu

---

**Başarılar! Sorularını şu sırayla halledersen sıkıntı yok:**
1. Bugün Pazar → Kurulum + ilk 2 commit + benioku.md oku
2. Her gün belirlenen 1-2 commit'i at
3. Cuma sabah son kontrol
4. Cuma akşam teslim ✓
