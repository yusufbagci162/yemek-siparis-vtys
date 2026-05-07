# Çevrimiçi Yemek Sipariş Platformu Veritabanı

**Ders:** VTYS-1 Dönem Projesi
**DBMS:** Microsoft SQL Server (T-SQL)
**Veritabanı Adı:** `YemekSiparisDB`
**Öğrenci:** Yusuf Bağcı

---

## 1. Projenin Amacı

Gerçek dünya senaryosuna uygun, en az 3. Normal Form'a (3NF) uygun, klasik bir yemek sipariş platformunun ilişkisel veritabanını tasarlamak ve buna ek olarak **"Askıda Yemek"** modülünü mühendislik yapısı içinde kurmak.

Sistem; müşteri, restoran, kurye, kategori, ürün, sipariş, sipariş detayı, puanlama gibi standart varlıkların yanında üç adet özel tabloyla bağış-havuz-kullanım akışını yönetir.

---

## 2. İş Kuralları

### 2.1 Genel Sipariş İş Kuralları

1. Bir müşteri birden fazla teslimat adresine sahip olabilir (`Musteriler` → `Adresler`, 1:N).
2. Bir sipariş tek bir restorana, tek bir teslimat adresine ve en fazla bir kuryeye atanır. Kurye, sipariş "Yolda" durumuna geçince atanabilir (NULL olabilir).
3. Bir sipariş içinde birden fazla ürün olabilir (`Siparisler` ↔ `Urunler`, M:N → `SiparisDetaylari` ile çözümlenmiştir).
4. Ürün fiyatı zamanla değişebilir; bu nedenle sipariş anındaki birim fiyat `SiparisDetaylari.BirimFiyat` kolonunda saklanır (tarihsel doğruluk).
5. Sipariş durumları: `Yeni → Hazirlaniyor → Yolda → TeslimEdildi` veya `IptalEdildi`. Geçişler `CHECK` kısıtıyla denetlenir.
6. Bir sipariş "TeslimEdildi" durumuna geçince:
   - `Siparisler.TeslimTarihi` otomatik olarak doldurulur.
   - İlgili restoranın `ToplamCiro` hanesine sipariş tutarı eklenir.
   - Bu iş kuralı `trg_SiparisTeslim_CiroGuncelle` trigger'ı ile otomatize edilmiştir.
7. Bir müşteri her siparişe en fazla bir kez puan verebilir (`UNIQUE(SiparisID)`).
8. Puanlama yapıldığında restoranın `Puan` ortalaması `trg_Puanlama_Sonrasi` trigger'ı ile otomatik güncellenir.
9. **Soft Delete**: Restoran, ürün, müşteri, kurye, adres için fiziksel silme yerine `IsActive = 0` güncellemesi kullanılır. Tüm raporlama ve görünümler `IsActive = 1` filtresiyle çalışır.

### 2.2 "Askıda Yemek" Modülü İş Kuralları

1. **Bağış**: Bir müşteri `AskidaBagislari` tablosuna kayıt atarak havuza bağış yapar. Bağış parasal (`BagisTuru = 'Bakiye'`) veya somut (`'Yemek'`) olabilir.
2. **Anonimlik**: Bağışçı isterse `AnonimMi = 1` işaretler; bu durumda raporlarda kimliği gizlenir.
3. **Havuz**: `AskidaYemekHavuzu` tablosu **tek satırlık (singleton)** bir özet tablodur (`CHECK (HavuzID = 1)`). `GuncelBakiye`, `ToplamBagisTutari`, `ToplamKullanimTutari` saklanır.
4. **Otomatik Artış**: Yeni bir bağış INSERT edildiğinde `trg_AskidaBagis_Sonrasi` trigger'ı havuz bakiyesini otomatik artırır.
5. **Yararlanma Hakkı**: Yalnızca `Musteriler.IhtiyacSahibiOnayli = 1` olan müşteriler havuzdan ücretsiz sipariş verebilir.
6. **Kullanım**: İhtiyaç sahibi müşteri sipariş verdiğinde sipariş `AskidaMi = 1` ve `OdemeYontemi = 'Askida'` olarak işaretlenir. Aynı zamanda `AskidaKullanimlari` tablosuna bir kayıt atılır.
7. **Otomatik Düşüş + Bakiye Kontrolü**: `trg_AskidaKullanim_Sonrasi` trigger'ı:
   - Havuz bakiyesi yetersizse `RAISERROR + ROLLBACK` ile işlemi iptal eder.
   - Yeterliyse havuzdan ilgili tutarı düşer ve `ToplamKullanimTutari`'nı artırır.
8. **Tekil Kullanım**: Bir sipariş havuzdan sadece bir kez yararlanabilir (`UNIQUE(SiparisID)` kısıtı `AskidaKullanimlari` üzerinde).

---

## 3. Tablo Listesi ve İlişkiler

| Tablo                      | Açıklama                                                    | Kayıt Sayısı |
|----------------------------|-------------------------------------------------------------|--------------|
| `Musteriler`               | Platform kullanıcıları                                      | 25           |
| `Adresler`                 | Müşterilerin teslimat adresleri                             | 25           |
| `Restoranlar`              | İş ortağı restoranlar                                       | 8 (1 pasif)  |
| `Kuryeler`                 | Teslimat kuryeleri                                          | 10 (1 pasif) |
| `Kategoriler`              | Ürün kategorileri (3NF için ayrı)                          | 8            |
| `Urunler`                  | Restoran menülerindeki ürünler                              | 59 (1 pasif) |
| `Siparisler`               | Müşteri siparişleri                                          | 120          |
| `SiparisDetaylari`         | M:N kırılım tablosu (Sipariş ↔ Ürün)                       | 300+         |
| `RestoranPuanlamalari`     | Sipariş bazlı 1-5 puanlama ve yorum                         | 40           |
| `AskidaYemekHavuzu`        | Singleton havuz özet tablosu                                | 1            |
| `AskidaBagislari`          | Müşteri bağış kayıtları                                      | 18           |
| `AskidaKullanimlari`       | İhtiyaç sahibinin havuzdan yararlanma kayıtları             | 12           |

### Önemli İlişkiler

- `Musteriler` 1—N `Adresler`
- `Musteriler` 1—N `Siparisler`
- `Restoranlar` 1—N `Urunler`
- `Restoranlar` 1—N `Siparisler`
- `Kategoriler` 1—N `Urunler`
- `Kuryeler` 0..1—N `Siparisler`
- `Siparisler` 1—N `SiparisDetaylari` (CASCADE DELETE)
- `Urunler` 1—N `SiparisDetaylari`
- `Siparisler` 1—1 `RestoranPuanlamalari`
- `Musteriler` 1—N `AskidaBagislari`
- `Musteriler` 1—N `AskidaKullanimlari`
- `Siparisler` 1—1 `AskidaKullanimlari` (UNIQUE)

---

## 4. Dosya Yapısı

```
/
├── 00_YemekSiparisDB_KOMPLE.sql   # Tek dosyalık birleştirilmiş SQL (teslim dosyası)
├── 01_Veritabani_Olustur.sql      # CREATE DATABASE + CREATE TABLE + constraints
├── 02_Indexler.sql                # 4 adet non-clustered index
├── 03_Tetikleyiciler.sql          # 4 adet TRIGGER
├── 04_Gorunumler.sql              # 4 adet VIEW
├── 05_TestVerileri.sql            # Mock INSERT + trigger canlı demo
├── 06_AnalitikSorgular.sql        # JOIN, GROUP BY/HAVING, subquery örnekleri
├── ER_Diyagrami.md                # Mermaid ER diyagram kaynağı
├── ER_Diyagrami.svg               # ER diyagramı (görsel)
├── AI_Beyani.md                   # Yapay zeka kullanım beyanı
├── git_commit_script.sh           # GitHub için aşamalı commit script (bash)
└── README.md                      # Bu dosya
```

---

## 5. Yönergeye Uygunluk Kontrol Listesi

### 5.1 DDL & Constraints

- [x] **PK & FK**: Her tabloda PRIMARY KEY; tablolar arası tüm bağlar FOREIGN KEY ile referans bütünlüğü altında.
- [x] **CHECK Kısıtları** (en az 2 isteniyordu, 13+ kullanıldı):
  - `Restoranlar.Puan BETWEEN 0 AND 5`
  - `Restoranlar.ToplamCiro >= 0`
  - `Urunler.Fiyat > 0`
  - `Siparisler.ToplamTutar >= 0`
  - `Siparisler.Durum IN (...)` — geçerli durumlar listesi
  - `SiparisDetaylari.Adet > 0`
  - `SiparisDetaylari.BirimFiyat > 0`
  - `RestoranPuanlamalari.Puan BETWEEN 1 AND 5`
  - `AskidaYemekHavuzu.GuncelBakiye >= 0`
  - `AskidaYemekHavuzu.HavuzID = 1` (singleton)
  - `AskidaBagislari.BagisTutari > 0`
  - `Musteriler.Telefon` uzunluk kontrolü
  - ... ve diğerleri
- [x] **UNIQUE & NOT NULL**:
  - `Musteriler.Email`, `Musteriler.Telefon`, `Restoranlar.Telefon`, `Kuryeler.Telefon`, `Kategoriler.KategoriAd` UNIQUE
  - Tüm zorunlu kolonlarda `NOT NULL`

### 5.2 DML (Mock Data) — Minimumun Üzerinde

| İstek                       | Asgari | Bu projede |
|-----------------------------|--------|------------|
| Restoran                    | 5      | 8          |
| Ürün                        | 50     | 59         |
| Müşteri                     | 20     | 25         |
| "Askıda Yemek" hareketi     | -      | 18 bağış + 12 kullanım |
| Sipariş                     | 100    | 120        |

- [x] **Soft Delete** örnekleri: `Eski Lokanta` (RestoranID=8), `Eski Menü Ürünü` (UrunID=64), `Eski Kurye` (KuryeID=10), `Eski Kayıt` (MusteriID=25).

### 5.3 DQL & Analitik (06_AnalitikSorgular.sql)

- [x] **JOIN** (en az 3 tablo): 5 tablolu (`Siparisler` + `Musteriler` + `Restoranlar` + `Kuryeler` LEFT + `SiparisDetaylari` + `Urunler`) sipariş fişi sorgusu.
- [x] **GROUP BY + HAVING + SUM/COUNT/AVG**: Son 30 günde 5'ten fazla teslim edilmiş siparişi olan restoranların ortalama sepet tutarı.
- [x] **Subquery**:
  - `NOT EXISTS` — hiç bağış yapmamış aktif müşteriler
  - `EXISTS + NOT EXISTS` — havuzdan yararlanmamış ihtiyaç sahipleri
  - `IN` — en çok bağış yapan ilk 5 müşterinin profili
- [x] **BONUS**: Pencere fonksiyonu (`DENSE_RANK() OVER`), `CROSS APPLY`.

### 5.4 Programlanabilirlik

- [x] **View (en az 2)** — 4 adet:
  1. `vw_AktifRestoranMenuleri`
  2. `vw_AskidaYemekHavuzDurumu`
  3. `vw_SiparisFisi`
  4. `vw_RestoranCiroOzet`
- [x] **Trigger (en az 2)** — 4 adet:
  1. `trg_AskidaBagis_Sonrasi` — bağış sonrası havuzu artırır
  2. `trg_AskidaKullanim_Sonrasi` — kullanım sonrası havuzu düşürür, bakiye yoksa ROLLBACK
  3. `trg_SiparisTeslim_CiroGuncelle` — sipariş teslim edilince restoran cirosunu artırır
  4. `trg_Puanlama_Sonrasi` — yeni puan girilince restoran ortalama puanını günceller
- [x] **Index (en az 2)** — 4 adet non-clustered:
  1. `IX_Siparisler_SiparisTarihi` (tarih sorguları için)
  2. `IX_Urunler_RestoranID_Aktif` (restoran menüsü için)
  3. `IX_Musteriler_Email` (login için)
  4. `IX_AskidaBagislari_MusteriID_Tarih` (bağış raporları için)

---

## 6. Çalıştırma Talimatı

### Tek Dosyayla (önerilen)

SQL Server Management Studio (SSMS) veya Azure Data Studio:

```sql
-- Sırasıyla çalıştırın (tek dosya):
:r 00_YemekSiparisDB_KOMPLE.sql
```

Veya sırayla:

```sql
:r 01_Veritabani_Olustur.sql
:r 02_Indexler.sql
:r 04_Gorunumler.sql
:r 03_Tetikleyiciler.sql
:r 05_TestVerileri.sql
:r 06_AnalitikSorgular.sql
```

> **Not:** Trigger'lar, test verileri INSERT edilmeden ÖNCE oluşturulmalıdır; aksi takdirde bağış/kullanım hareketleri havuz tablosunu otomatik güncelleyemez.

---

## 7. "Askıda Yemek" Akış Şeması

```
+----------+   1. Bağış yapar      +-------------------+   2. trigger artırır   +------------------+
| Bağışçı  | -------------------->  | AskidaBagislari   | --------------------> | AskidaYemekHavuzu|
| Müşteri  |                        |                   |                       |  (GuncelBakiye)   |
+----------+                        +-------------------+                       +---------+--------+
                                                                                         |
                                                                                         | 4. trigger düşer
                                                                                         v
+----------+   3. Askıda sipariş    +-------------------+                       +-------------------+
| İhtiyaç  | -------------------->  | AskidaKullanim.   |                       |  Bakiye yoksa     |
| Sahibi   |                        |    AskidaMi=1     |                       |  ROLLBACK         |
+----------+                        +-------------------+                       +-------------------+
```

---

## 8. Notlar

- Tablo isimleri ve kolonlar Türkçe; yönergedeki örneklerle uyumludur.
- Tüm sorgular SQL Server 2019+ üzerinde test edilmek üzere yazılmıştır.
- Mock veri tarihleri 2026-01 ile 2026-05 arasındadır; `DATEADD(DAY, -30, GETDATE())` ile "son 1 ay" sorgularını test edebilmek için bu aralık seçilmiştir.

Sorular için: [GitHub Issues] üzerinden iletişime geçilebilir.
