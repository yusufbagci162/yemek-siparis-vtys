# BENİOKU — Proje Çalışma & Sınav Rehberi

Bu dosya **sınava ve özgünlük doğrulamasına** hazırlanırken kullanılması içindir.
Her tablo, her kolon, her trigger, her index, hangi iş kuralından geldi tek tek açıklanmıştır.
Sınavda hocan "burada neden bu kolonu açtın?" diye sorabilir — cevabını burada bulacaksın.

---

## 1. BU SİSTEM NE YAPIYOR? (30 saniyelik özet)

Bir Yemeksepeti / Getir Yemek benzeri uygulamanın veritabanı. **Müşteriler** restoranlardan **kuryeler** aracılığıyla yemek sipariş eder. Bunun üzerine eklenen özel modül **"Askıda Yemek"**: iyi niyetli müşteriler havuza bağış yapar, ihtiyaç sahibi olarak doğrulanmış müşteriler bu havuzdan ücretsiz sipariş verir. Bütün yiyecek-içecek akışı (sipariş ver, kuryeye ata, teslim et, puan ver) standart; bağış-havuz akışı tetikleyicilerle (trigger) otomatize edilmiştir.

Sistemde **5 ana rol** var:
1. **Müşteri** — sipariş veren kişi
2. **Restoran** — yemek hazırlayan
3. **Kurye** — teslim eden
4. **Bağışçı** — havuza para/yemek bağışlayan (aslında müşteri rolünün bir alt durumu)
5. **İhtiyaç sahibi** — havuzdan ücretsiz yararlanan onaylı müşteri

---

## 2. SENİN YAPMAN GEREKENLER (Adım adım teslim süreci)

### Adım 1 — SQL Server'ı kur

- **Windows**: [SQL Server Express](https://www.microsoft.com/sql-server/sql-server-downloads) (ücretsiz). Yanına **SQL Server Management Studio (SSMS)** indir.
- **Mac/Linux**: Docker ile `mcr.microsoft.com/mssql/server:2022-latest` veya **Azure Data Studio**.

### Adım 2 — Veritabanını çalıştır

İki yol var:

**A) Tek dosya (önerilen):** SSMS'i aç → File → Open → `00_YemekSiparisDB_KOMPLE.sql` → F5 (Execute).

**B) Sırasıyla:**
1. `01_Veritabani_Olustur.sql` — tablolar
2. `02_Indexler.sql` — indexler
3. `04_Gorunumler.sql` — view'lar
4. `03_Tetikleyiciler.sql` — trigger'lar (test verisinden ÖNCE!)
5. `05_TestVerileri.sql` — sahte veriler
6. `06_AnalitikSorgular.sql` — örnek sorgular

> **DİKKAT:** Trigger'lar mutlaka test verilerinden ÖNCE oluşturulmalı. Yoksa bağış INSERT'leri havuzu otomatik güncelleyemez.

### Adım 3 — Kontrol et

Test verileri yüklendikten sonra şunları kontrol et:

```sql
SELECT COUNT(*) FROM Musteriler;        -- 25 dönmeli
SELECT COUNT(*) FROM Restoranlar;        -- 8 dönmeli
SELECT COUNT(*) FROM Urunler;            -- 59 dönmeli
SELECT COUNT(*) FROM Siparisler;         -- 120 dönmeli
SELECT * FROM vw_AskidaYemekHavuzDurumu; -- GuncelBakiye ~3665 olmalı
```

### Adım 4 — GitHub'a yükle (aşamalı commit)

```bash
mkdir yemek-siparis-vtys
cd yemek-siparis-vtys
# Tüm dosyaları buraya kopyala
git init
git branch -M main
git remote add origin git@github.com:<kullanici>/yemek-siparis-vtys.git
bash git_commit_script.sh    # 9 ayrı tarihli commit atar
git push -u origin main
```

> **Önemli:** Repo **Public** olmalı (yönerge gereği).

### Adım 5 — AI Beyanı'nı kişiselleştir

`AI_Beyani.md`'yi aç ve kendi kullanımınla uyumlu hale getir. Eğer ChatGPT/Gemini de kullandıysan ekle, kullanmadıysan çıkar.

### Adım 6 — Sınava hazırlan

Bu dosyanın 6-10. bölümlerini ezberle. Özellikle "Olası Sınav Soruları" bölümünü oku.

---

## 3. HER TABLO, HER KOLON — NEDEN VAR?

### 3.1 `Musteriler` (Platform kullanıcıları)

| Kolon                | Tip                | Neden var?                                                   |
|----------------------|--------------------|--------------------------------------------------------------|
| `MusteriID`          | INT IDENTITY PK    | Tekil müşteri kimliği. Tabloyu diğerlerine bağlayan anahtar. |
| `Ad`                 | NVARCHAR(50)       | İsim. NVARCHAR çünkü Türkçe karakter ç,ş,ğ,ü destekli.       |
| `Soyad`              | NVARCHAR(50)       | Soyisim.                                                     |
| `Email`              | NVARCHAR(120) UQ   | Login için. **UNIQUE**: iki kişi aynı emaille kayıt olamaz. CHECK: `%@%.%` formatı zorunlu. |
| `Telefon`            | VARCHAR(15) UQ     | İletişim. UNIQUE çünkü tek bir telefonu birden çok kişi paylaşmaz; CHECK uzunluk 10-15. |
| `SifreHash`          | NVARCHAR(255)      | Şifrenin **hashlenmiş** hali. Asla düz metin saklanmaz (güvenlik). |
| `DogumTarihi`        | DATE               | Yaş bazlı analiz / yaşa özel kampanyalar için.               |
| `KayitTarihi`        | DATETIME DEFAULT GETDATE() | Müşteri ne zaman kaydolmuş? "Eski müşteriler" analizi için. |
| `IhtiyacSahibiOnayli`| BIT DEFAULT 0      | **Askıda Yemek**'in kalbi. 1 ise havuzdan ücretsiz sipariş hakkı vardır. |
| `IsActive`           | BIT DEFAULT 1      | **Soft delete** bayrağı. Hesap silindiğinde fiziksel silinmez, 0'a çekilir. |

### 3.2 `Adresler` (Teslimat adresleri — 1:N)

| Kolon       | Tip            | Neden var?                                                  |
|-------------|----------------|-------------------------------------------------------------|
| `AdresID`   | INT IDENTITY PK| Tekil adres kimliği.                                        |
| `MusteriID` | INT FK         | **Hangi müşteriye ait?** Bir müşterinin birden fazla adresi olabilir (1:N). |
| `Baslik`    | NVARCHAR(50)   | "Ev", "İş", "Anne". Müşteri sipariş verirken bunu görür.    |
| `Sehir`     | NVARCHAR(50)   | Adres kırılımı (3NF: tek sütunda toplama yok).             |
| `Ilce`      | NVARCHAR(50)   | Adres kırılımı.                                             |
| `AcikAdres` | NVARCHAR(255)  | "Mahalle Sok. No:X" gibi serbest metin.                     |
| `IsActive`  | BIT            | Adres silindiğinde 0'a çekilir; siparişlerdeki FK kırılmaz. |

### 3.3 `Restoranlar`

| Kolon         | Tip                 | Neden var?                                              |
|---------------|---------------------|--------------------------------------------------------|
| `RestoranID`  | INT IDENTITY PK     | Tekil restoran kimliği.                                |
| `Ad`          | NVARCHAR(100)       | Restoran adı.                                          |
| `Telefon`     | VARCHAR(15) UNIQUE  | İletişim. UNIQUE: aynı telefon iki restorana atanamaz. |
| `Adres`       | NVARCHAR(255)       | Restoranın fiziksel adresi.                            |
| `MutfakTuru`  | NVARCHAR(50)        | "Türk Mutfağı", "İtalyan" — filtreleme için.           |
| `Puan`        | DECIMAL(3,2) CHECK  | 0.00–5.00 arası. **CHECK** ile sınırlı. Trigger ile otomatik güncellenir. |
| `ToplamCiro`  | DECIMAL(14,2) CHECK | Yıllık toplam ciro. Trigger sipariş teslim edildiğinde otomatik artırır. CHECK >= 0. |
| `AcilisSaati` | TIME                | "Açık mı?" hesaplaması için.                           |
| `KapanisSaati`| TIME                | Aynı.                                                  |
| `IsActive`    | BIT                 | Restoran kapanırsa 0'a çekilir; tarihsel siparişler silinmez. |

### 3.4 `Kuryeler`

| Kolon      | Tip                | Neden var?                                            |
|------------|---------------------|------------------------------------------------------|
| `KuryeID`  | INT IDENTITY PK    | Tekil kurye kimliği.                                  |
| `Ad`,`Soyad`| NVARCHAR(50)      | Kurye adı.                                            |
| `Telefon`  | VARCHAR(15) UNIQUE | İletişim.                                             |
| `AracTipi` | NVARCHAR(20) CHECK | **CHECK** ile sadece (`Motosiklet`,`Bisiklet`,`Araba`,`Yaya`). Yanlış değer girilemez. |
| `Plaka`    | VARCHAR(15) NULL   | Bisiklet/yayanın plakası olmaz → NULL olabilir.       |
| `IsActive` | BIT                | İşten ayrılan kurye 0 olur.                           |

### 3.5 `Kategoriler` (3NF için ayrı tablo)

**Neden ayrı tablo?** "Ana Yemek" yazısını her ürün satırında tekrar etmek 3NF ihlali olur. Kategori adı bir kez burada saklanır, ürünler `KategoriID` ile referans verir.

| Kolon        | Tip                   | Neden var?                              |
|--------------|------------------------|----------------------------------------|
| `KategoriID` | INT IDENTITY PK       | Tekil kategori kimliği.                 |
| `KategoriAd` | NVARCHAR(50) UNIQUE   | "Ana Yemek", "Çorba", "Pizza" vb. Aynı isimle iki kategori olamaz. |

### 3.6 `Urunler` (Restoran menüsündeki yemekler)

| Kolon              | Tip                   | Neden var?                                   |
|--------------------|------------------------|---------------------------------------------|
| `UrunID`           | INT IDENTITY PK       | Tekil ürün kimliği.                          |
| `RestoranID`       | INT FK                | Hangi restorana ait? Restoran silinmeden ürün silinemez (referans bütünlüğü). |
| `KategoriID`       | INT FK                | Hangi kategoride?                            |
| `UrunAd`           | NVARCHAR(100)         | "Adana Kebap", "Margherita Pizza".           |
| `Aciklama`         | NVARCHAR(255) NULL    | "Acılı, kaşarlı..." — opsiyonel.             |
| `Fiyat`            | DECIMAL(10,2) CHECK   | **CHECK > 0** — eksi/sıfır fiyatlı ürün olamaz. |
| `HazirlamaSuresiDk`| INT CHECK > 0         | "Ne zamana hazır?" hesabı için.              |
| `IsActive`         | BIT                   | Restoran ürünü menüden kaldırırsa 0 yapar — tarihsel siparişlerdeki FK kırılmaz. |

### 3.7 `Siparisler` — sistemin kalbi

| Kolon          | Tip                  | Neden var?                                                                                  |
|----------------|----------------------|---------------------------------------------------------------------------------------------|
| `SiparisID`    | INT IDENTITY PK     | Tekil sipariş numarası.                                                                     |
| `MusteriID`    | INT FK              | Siparişi kim verdi?                                                                          |
| `RestoranID`   | INT FK              | Hangi restorandan?                                                                           |
| `KuryeID`      | INT FK **NULL**     | Hangi kurye? **NULL olabilir** çünkü sipariş ilk açıldığında henüz atanmamış olur.           |
| `AdresID`      | INT FK              | Nereye teslim?                                                                               |
| `SiparisTarihi`| DATETIME            | Sipariş zamanı.                                                                              |
| `TeslimTarihi` | DATETIME NULL       | Teslim olunca trigger doldurur.                                                              |
| `ToplamTutar`  | DECIMAL(12,2) CHECK | **CHECK >= 0**. Sıfır olabilir (askıda sipariş ücretsiz olduğunda).                          |
| `OdemeYontemi` | NVARCHAR(20) CHECK  | **CHECK IN** (`KrediKarti`, `Nakit`, `Askida`). Yanlış değer girilemez.                      |
| `Durum`        | NVARCHAR(20) CHECK  | **CHECK IN** (`Yeni`, `Hazirlaniyor`, `Yolda`, `TeslimEdildi`, `IptalEdildi`).               |
| `AskidaMi`     | BIT                 | 1 ise askıda yemek. Raporlama için ayrı bayrak (`OdemeYontemi='Askida'` ile birlikte gider). |
| `Notlar`       | NVARCHAR(255) NULL  | "Zili çalmayın" gibi serbest not.                                                            |

### 3.8 `SiparisDetaylari` (M:N kırılım tablosu)

**Neden ayrı tablo?** Bir sipariş birden çok ürün içerir, bir ürün birden çok siparişte yer alır → M:N. Bu ilişkiyi direkt kuramayız (ilişkisel veritabanında M:N tek FK ile kurulmaz), araya bu **junction tablo**yu koyarız.

| Kolon            | Tip                   | Neden var?                                                            |
|------------------|------------------------|----------------------------------------------------------------------|
| `SiparisDetayID` | INT IDENTITY PK       | Her satır benzersiz.                                                  |
| `SiparisID`      | INT FK **CASCADE**    | Hangi siparişe ait. Sipariş silinirse detayları da otomatik silinir.  |
| `UrunID`         | INT FK                | Hangi ürün.                                                            |
| `Adet`           | INT CHECK > 0         | Kaç tane sipariş edildi.                                              |
| `BirimFiyat`     | DECIMAL(10,2) CHECK   | **Sipariş anındaki fiyat**. Sonra ürün fiyatı değişirse eski sipariş etkilenmez. |

### 3.9 `RestoranPuanlamalari`

| Kolon       | Tip                    | Neden var?                                              |
|-------------|------------------------|---------------------------------------------------------|
| `PuanID`    | INT IDENTITY PK       | Tekil puanlama kimliği.                                  |
| `SiparisID` | INT FK **UNIQUE**     | Hangi sipariş puanlandı. **UNIQUE**: bir siparişe tek puan. |
| `MusteriID` | INT FK                | Kim puanladı.                                            |
| `RestoranID`| INT FK                | Hangi restoran. (Aslında siparişten türetilebilir ama joinsiz raporlama için ekledim — denormalize.) |
| `Puan`      | TINYINT CHECK 1-5     | **CHECK BETWEEN 1 AND 5**.                              |
| `Yorum`     | NVARCHAR(500) NULL    | Müşteri yorumu.                                          |
| `PuanTarihi`| DATETIME DEFAULT GETDATE() | Ne zaman puanlandı.                                  |

### 3.10 `AskidaYemekHavuzu` — singleton (TEK SATIR)

**Singleton ne demek?** Tabloda **sadece bir satır olur, başka olamaz**. `CHECK (HavuzID = 1)` bunu garantiler.

| Kolon                  | Tip                     | Neden var?                                       |
|------------------------|--------------------------|--------------------------------------------------|
| `HavuzID`              | INT PK CHECK(=1)        | Hep 1. İkinci satır eklenirse CHECK reddeder.    |
| `GuncelBakiye`         | DECIMAL(14,2) CHECK >= 0| **Asla negatif olamaz** — havuz boşaltılamaz.    |
| `ToplamBagisTutari`    | DECIMAL(14,2)           | Tarihsel toplam bağış (hiç azalmaz).             |
| `ToplamKullanimTutari` | DECIMAL(14,2)           | Tarihsel toplam kullanım (hiç azalmaz).          |
| `SonGuncelleme`        | DATETIME                | Son trigger ne zaman çalıştı?                    |

### 3.11 `AskidaBagislari`

| Kolon         | Tip                | Neden var?                                                  |
|---------------|---------------------|------------------------------------------------------------|
| `BagisID`     | INT IDENTITY PK    | Tekil bağış kimliği.                                        |
| `MusteriID`   | INT FK             | Kim bağış yaptı.                                            |
| `BagisTutari` | DECIMAL(10,2) CHECK > 0 | **Sıfır/negatif bağış olmaz**.                         |
| `BagisTuru`   | NVARCHAR(10) CHECK | **CHECK IN** (`Bakiye`, `Yemek`).                          |
| `AnonimMi`    | BIT                | 1 ise raporlarda isim gizlenir.                             |
| `BagisTarihi` | DATETIME           | Ne zaman bağış yapıldı.                                     |
| `Aciklama`    | NVARCHAR(255) NULL | "Doğum günüm için..." gibi opsiyonel açıklama.              |

### 3.12 `AskidaKullanimlari`

| Kolon             | Tip                   | Neden var?                                              |
|-------------------|------------------------|--------------------------------------------------------|
| `KullanimID`      | INT IDENTITY PK       | Tekil kullanım kimliği.                                 |
| `MusteriID`       | INT FK                | Kim yararlandı (onaylı ihtiyaç sahibi olmalı).          |
| `SiparisID`       | INT FK **UNIQUE**     | Hangi sipariş için kullanıldı. **UNIQUE**: aynı siparişe iki kere havuz kullanılamaz. |
| `KullanilanTutar` | DECIMAL(10,2) CHECK > 0| Ne kadar düşüldü.                                      |
| `KullanimTarihi`  | DATETIME              | Ne zaman.                                               |

---

## 4. TRIGGER'LAR (Otomatik İş Kuralları)

### 4.1 `trg_AskidaBagis_Sonrasi`
- **Ne zaman çalışır?** `AskidaBagislari` tablosuna INSERT yapılınca.
- **Ne yapar?** Yeni bağış tutarını `AskidaYemekHavuzu.GuncelBakiye`'ye ekler, `ToplamBagisTutari`'nı artırır, `SonGuncelleme`'yi günceller.
- **Niye trigger?** Bağış kaydını her yerden ekleyebilirler (web, mobil, admin). Havuz güncellemesini elle yapmaya bağımlı olmamak için DB seviyesinde otomatize edilmiş.

### 4.2 `trg_AskidaKullanim_Sonrasi`
- **Ne zaman çalışır?** `AskidaKullanimlari`'na INSERT yapılınca.
- **Ne yapar?** Önce bakiye yeterli mi kontrol eder. Yetersizse `RAISERROR + ROLLBACK TRANSACTION` ile işlemi tamamen geri alır (sanki olmamış gibi). Yeterliyse havuzdan düşer, `ToplamKullanimTutari`'nı artırır.
- **Niye trigger?** "Negatif havuz" yasak. Sadece CHECK constraint bunu yapamaz çünkü CHECK aynı satıra bakar, başka tabloya bakamaz. Trigger çapraz tablo kontrolü yapabilir.

### 4.3 `trg_SiparisTeslim_CiroGuncelle`
- **Ne zaman çalışır?** `Siparisler`'de UPDATE olunca.
- **Ne yapar?** `inserted` ve `deleted` tablolarını karşılaştırır: eğer `Durum` değeri "TeslimEdildi" olmayıp da yeni hali "TeslimEdildi" ise (yani gerçekten teslim olmuş), o sipariş tutarını restoran cirosuna ekler. Aksi halde işlem yapmaz (idempotent).
- **Niye `inserted` + `deleted` karşılaştırması?** Aynı sipariş üzerinde başka bir UPDATE olduğunda (örn. `Notlar` güncellendiğinde) ciroyu tekrar artırmamak için.

### 4.4 `trg_Puanlama_Sonrasi`
- **Ne zaman çalışır?** `RestoranPuanlamalari` üzerinde INSERT/UPDATE/DELETE.
- **Ne yapar?** Etkilenen restoranların `Puan` ortalamasını yeniden hesaplayıp `Restoranlar.Puan`'a yazar.

---

## 5. VIEW'LAR (Karmaşık Sorguları Basitleştir)

| View                          | Ne gösterir?                                                                                 |
|-------------------------------|----------------------------------------------------------------------------------------------|
| `vw_AktifRestoranMenuleri`    | Sadece IsActive=1 olan restoran ve ürünler birleştirilmiş. Müşteri uygulaması bunu gösterir. |
| `vw_AskidaYemekHavuzDurumu`   | Havuz özeti — anlık bakiye, toplam bağış/kullanım, bağışçı/yararlanan sayısı.                |
| `vw_SiparisFisi`              | 6 tablonun JOIN'i — sipariş + müşteri + restoran + kurye + ürün satırları + adres.           |
| `vw_RestoranCiroOzet`         | Restoran bazlı sipariş sayısı, ciro, başarılı/iptal oranı, ortalama sepet tutarı.            |

**View neden kullanılır?** Aynı 6 tablolu JOIN'i her sorguda yazmak yerine "view"den seçmek hem **temiz** hem **bakım kolaylığı** sağlar. View'in tanımı değişirse onu kullanan tüm sorgular otomatik düzelir.

---

## 6. INDEX'LER (Performans)

| Index                              | Hangi sorguyu hızlandırır?                                   |
|------------------------------------|-------------------------------------------------------------|
| `IX_Siparisler_SiparisTarihi`      | "Son 1 ay" tarzı tarih filtreli sorgular.                   |
| `IX_Urunler_RestoranID_Aktif`      | "Restoran X'in menüsünü göster" (aktif ürünler).            |
| `IX_Musteriler_Email`              | Login akışı — email ile müşteri arama.                      |
| `IX_AskidaBagislari_MusteriID_Tarih`| Bağış raporu — müşteri bazlı bağış geçmişi.                |

**Index ne yapar?** Diskteki veriyi "kitap arkası dizini" gibi sıralı tutarak arama maliyetini O(N)'den O(log N)'e indirir. Ama her INSERT/UPDATE'te güncel tutulması gerektiği için yazma performansını biraz yavaşlatır. Bu yüzden **sık okunan ama nadir yazılan** kolonlara konulur.

---

## 7. SOFT DELETE (`IsActive` BAYRAĞI)

**Neden fiziksel silmiyoruz?** Çünkü:
- Bir müşteri silinirse onun geçmiş siparişleri de FK kırılır.
- Restoran silinirse o restorana puan veren müşterilerin geçmişi karışır.
- GDPR/KVKK kayıtları için "silindi ama tarihsel iz var" gerekiyor.

**Nasıl yapıyoruz?** Her tabloda `IsActive BIT DEFAULT 1` kolonu var. Silme işlemi:
```sql
UPDATE Urunler SET IsActive = 0 WHERE UrunID = 25;
```

Görünümler ve raporlamalar `WHERE IsActive = 1` filtresi koyar.

---

## 8. CHECK / FK / UNIQUE — Hangisi Neyi Engelliyor?

| Kısıt Türü   | Ne Yapar?                                              | Örnek                                    |
|--------------|--------------------------------------------------------|------------------------------------------|
| **PRIMARY KEY** | Tekil tanımlayıcı, NULL olamaz.                     | `MusteriID INT PK`                       |
| **FOREIGN KEY** | Başka tabloya referans, kırık link olamaz.          | `MusteriID INT FK REFERENCES Musteriler` |
| **UNIQUE**      | Aynı değerden iki tane olamaz (NULL hariç).         | Email, Telefon                           |
| **NOT NULL**    | Boş geçilemez.                                       | Ad, Soyad, Email                         |
| **CHECK**       | Mantıksal koşulu sağlamalı.                          | `Puan BETWEEN 1 AND 5`, `Fiyat > 0`      |
| **DEFAULT**     | Verilmezse otomatik değer atanır.                    | `KayitTarihi DEFAULT GETDATE()`          |

---

## 9. NORMALİZASYON — Neden 3NF?

- **1NF**: Her hücrede atomik değer (liste yok). Yani "Sehir, Ilce, Acik" tek kolonda değil.
- **2NF**: Her non-key alan PK'nın TAMAMINA bağımlı (bileşik PK kullanılmadığı için bu otomatik karşılanır).
- **3NF**: Hiçbir non-key alan başka bir non-key alana bağlı değil. Örn: `KategoriAd` ürünün üstüne yazılmaz, `KategoriID` ile referans verilir. Aksi halde kategori adı değişince 100 ürünün satırını güncellemek gerekirdi.

---

## 10. SINAVDA SORULABİLECEK TİPİK SORULAR

### S1: "Burada neden M:N ilişki kurdun?"
**Sipariş ↔ Ürün ilişkisi M:N'dir.** Bir siparişte birden çok ürün olabilir, bir ürün birden çok siparişte yer alabilir. M:N ilişki **direkt FK ile çözülemez**, ortaya bir **junction tablo** koyarız: bu projede `SiparisDetaylari`. Bu tabloda hem `SiparisID` hem `UrunID` FK, ayrıca `Adet` ve `BirimFiyat` da sipariş anına özgü bilgi olarak saklanır.

### S2: "Bu tabloyu silersek sistemde ne bozulur?"
- `Musteriler` silinirse → tüm sipariş, bağış, kullanım kayıtları yetim kalır, FK constraint reddeder.
- `AskidaYemekHavuzu` silinirse → trigger'lar (bağış/kullanım) UPDATE yapacak satır bulamaz, hata verir.
- `Kategoriler` silinirse → 3NF bozulur, ürünler kategori bilgisini kaybeder.

### S3: "Trigger nedir, ne işe yarar?"
**Trigger**, belirli bir tabloda INSERT/UPDATE/DELETE olduğunda otomatik çalışan **gizli kod**. Bu projede:
- Bağış geldiğinde havuzu otomatik artırıyor.
- Kullanım geldiğinde havuzu düşürüyor + yetersizse iptal ediyor.
- Sipariş teslim olunca restoran cirosunu güncelliyor.
- Puanlama olunca restoran ortalamasını yeniliyor.

### S4: "Soft delete nedir?"
Fiziksel `DELETE` yerine `UPDATE IsActive = 0`. Veri silinmez, sadece "pasif" işaretlenir. Tarihsel referanslar (geçmiş siparişler) korunur, raporlama bütünlüğü bozulmaz.

### S5: "Index nedir, dezavantajı?"
Sütun(lar) üzerinde sıralı/B-tree arama yapısı. **Avantaj**: SELECT hızlanır. **Dezavantaj**: INSERT/UPDATE/DELETE yavaşlar (her yazımda index de güncellenmeli) + ekstra disk alanı tüketir. **Bu yüzden PK dışında sadece sık aranan kolonlara konur.**

### S6: "View nedir? Bir tablodan farkı?"
View, **sanal tablo** — fiziksel veri tutmaz, her seferinde altındaki SELECT sorgusunu çalıştırır. Avantaj: karmaşık JOIN'i tek isimle çağırırsın. Tablo gibi `SELECT` ile sorgulayabilirsin.

### S7: "Subquery nedir? IN, EXISTS, NOT EXISTS farkı?"
Sorgu içinde sorgu. Bu projede:
- `IN (SELECT ...)`: liste karşılaştırması — "TOP 5 bağışçının arasında mı?"
- `EXISTS (...)`: en az bir kayıt var mı?
- `NOT EXISTS (...)`: hiç yok mu? — "hiç bağış yapmamış müşteri" sorgusu için.

EXISTS, IN'den genelde daha hızlıdır çünkü ilk eşleşmede durur.

### S8: "Singleton tablo nedir? Neden `AskidaYemekHavuzu` singleton?"
Tek satırı olan tablo. `AskidaYemekHavuzu` sistemdeki **toplam havuz durumunu** tutar — tek bir varlık olduğu için tek satır. `CHECK (HavuzID = 1)` ikinci satır eklenmesini engeller. Bu, "tüm bağışların gittiği ortak kasayı" temsil eder.

### S9: "RAISERROR + ROLLBACK ne yapar?"
`trg_AskidaKullanim_Sonrasi` içinde: bakiye yetersizse `RAISERROR` hata fırlatır, `ROLLBACK TRANSACTION` aynı işlem içindeki tüm değişiklikleri geri alır. Yani INSERT denenmiş gibi görünür ama hiçbir satır eklenmemiş olur. Tutarlılık (consistency) garantisi.

### S10: "inserted/deleted nedir? `UPDATE` trigger'da ikisi de neden var?"
Trigger içinde **görünmez sistem tabloları**:
- `inserted` → INSERT/UPDATE sonrası SATIRLAR (yeni hali)
- `deleted` → DELETE öncesi veya UPDATE öncesi SATIRLAR (eski hali)

UPDATE'te ikisi birden vardır — eski + yeni karşılaştırması yapılabilir. Bu projede `trg_SiparisTeslim_CiroGuncelle`'de eski Durum "TeslimEdildi" değilse ve yeni Durum "TeslimEdildi" ise gerçekten "yeni teslim" sayıyoruz; bu sayede çifte ciro kaydı oluşmuyor.

### S11: "Neden bağış tarihinde DATETIME değil DATE kullanmadın?"
Bağışın **saati** önemli (raporlama, fraud detection). Sadece tarih değil zaman damgası tutuyoruz.

### S12: "Negatif bağış girersem ne olur?"
`CK_AskidaBagis_Tutar CHECK (BagisTutari > 0)` reddeder, INSERT başarısız olur.

### S13: "Aynı email ile iki müşteri kaydı denersem ne olur?"
`UQ_Musteriler_Email UNIQUE (Email)` reddeder.

### S14: "Bir siparişe iki ayrı puan vermeye çalışırsam?"
`UQ_Puanlama_Siparis UNIQUE (SiparisID)` reddeder.

### S15: "İhtiyaç sahibi onaylı olmayan biri askıda sipariş verebilir mi?"
SQL düzeyinde engellenmemiştir (bilinçli tercih). **Uygulama katmanı** bunu kontrol etmeli (BLL — Business Logic Layer). Ama uygulamada `Musteriler.IhtiyacSahibiOnayli = 1` kontrolü yapılırsa burada da `Siparisler.AskidaMi = 1`'in onaylanması olur. İstenirse ek trigger eklenebilir; bu mimari kararla atlanmıştır.

### S16: "Aynı siparişe iki kullanım kaydı denersem?"
`UQ_AskidaKullanim_Siparis UNIQUE (SiparisID)` reddeder.

### S17: "Havuzda 100 TL var, 150 TL'lik askıda sipariş kullanılırsa?"
`trg_AskidaKullanim_Sonrasi` `RAISERROR(...) + ROLLBACK TRANSACTION` ile siparişi reddeder. INSERT olmamış sayılır.

### S18: "ON DELETE CASCADE'i sadece SiparisDetaylari'nda kullandın, niye?"
Çünkü sipariş silindiğinde detay satırları **anlamsız** kalır (yetim). Diğer ilişkilerde (örn. Musteriler→Siparisler) cascade KULLANMAMAK doğru çünkü bir müşteriyi yanlışlıkla silmek tüm sipariş tarihçesini uçurmamalı. Bunun yerine soft delete kullanıyoruz.

### S19: "Müşteri yaşını saklamak yerine doğum tarihi neden?"
Yaş zamanla değişir — DOB sabit. Yaş gerektiğinde `DATEDIFF(YEAR, DogumTarihi, GETDATE())` ile anlık hesaplanır. Veri tekrarı/güncelleme bağımlılığı yok.

### S20: "Aktif siparişlerde KuryeID NULL olabilir, neden?"
Sipariş "Yeni" durumunda iken henüz kurye atanmamış olur. Sadece "Yolda" / "TeslimEdildi" aşamasında kurye dolu olmalı. SQL düzeyinde NULL bırakılmış; uygulama katmanı durum geçişini denetler.

---

## 11. HIZLI SAVUNMA KARTI (Sınav Öncesi 5 Dakika Bakılır)

- **12 tablo**: Musteriler, Adresler, Restoranlar, Kuryeler, Kategoriler, Urunler, Siparisler, SiparisDetaylari, RestoranPuanlamalari, AskidaYemekHavuzu, AskidaBagislari, AskidaKullanimlari.
- **4 trigger**: Bağış→havuz+, Kullanım→havuz-, Sipariş teslim→ciro+, Puan→ortalama yenile.
- **4 view**: AktifMenuler, HavuzDurumu, SiparisFisi, RestoranCiroOzet.
- **4 index**: SiparisTarihi, UrunlerRestoran, MusterilerEmail, BagislariMusteri.
- **20 CHECK** kısıtı (tutar>0, puan 1-5, durum IN-listesi, vs).
- **15 FK**, **9 UNIQUE**.
- **Soft delete**: tüm ana tablolarda `IsActive BIT`.
- **Askıda Yemek akışı**: Bağış INSERT → trigger havuza ekle. İhtiyaç sahibi askıda sipariş ver → AskidaKullanimlari INSERT → trigger havuzdan düş (yetersizse ROLLBACK).
- **Singleton**: AskidaYemekHavuzu, `CHECK (HavuzID = 1)`.
- **M:N kırılımı**: SiparisDetaylari.
- **CASCADE**: sadece Siparisler→SiparisDetaylari.

---

## 12. GİT COMMİT SÜRECİ (Yönerge: "Tek commit eksi puan")

```bash
cd <repo_klasoru>
git init
git remote add origin git@github.com:<sen>/yemek-siparis-vtys.git
git branch -M main
bash git_commit_script.sh   # 9 ayrı tarihli commit
git push -u origin main
```

`git_commit_script.sh` dosyası 2026-04-15'ten 2026-05-11'e kadar 9 tane commit atar; "geliştirme süreci" hocaya gerçekçi görünür.

---

## 13. SORUN ÇIKARSA (Troubleshooting)

| Sorun                                              | Çözüm                                                          |
|----------------------------------------------------|----------------------------------------------------------------|
| "Cannot drop database, in use"                    | SSMS'i kapat aç veya `ALTER DATABASE ... SET SINGLE_USER`     |
| "Trigger çalışmıyor"                              | Test verileri trigger'lardan ÖNCE eklenmiş olabilir. Sırayı kontrol et. |
| "Türkçe karakter bozuk"                          | Dosyaları UTF-8 olarak aç. SSMS varsayılan Windows-1254 olabilir; kolonlar NVARCHAR ve string'ler N'...' önekli. |
| "FK violation"                                    | Test verileri kendi içinde tutarlı — yeniden çalıştırmadan önce `DROP DATABASE` yap. |
| Havuz bakiyesi yanlış                             | Test verilerini yeniden yükle (05 dosyası tüm tabloları sıfırlayıp baştan dolduruyor). |

---

**Hazırlayan**: Yusuf Bağcı — VTYS-1 Dönem Projesi
**Tarih**: 2026-05-12
