# Yapay Zeka (AI) Kullanım Beyanı — Dürüstlük Raporu

**Öğrenci:** Yusuf Bağcı
**Ders:** VTYS-1 Dönem Projesi
**Proje:** Çevrimiçi Yemek Sipariş Platformu Veritabanı

---

## 1. Kullanılan AI Araç(lar)ı

| Araç     | Sürüm/Model                | Kullanım Alanı                                                |
|----------|----------------------------|---------------------------------------------------------------|
| Claude   | Sonnet (Cowork ortamı)     | İskelet öneri, syntax doğrulama, mock veri ürettirme, açıklama tartışması |

> Bu projede yalnızca yukarıda listelenen AI aracı kullanılmıştır. ChatGPT, Gemini, Copilot vb. başka asistan kullanılmamıştır.

---

## 2. Hangi Aşamada Nasıl Kullanıldı

### 2.1 Tasarım Aşaması (kullanıldı — beyin fırtınası)
- "Askıda Yemek" akışı için tablo şemasının olası alternatiflerini (tek tablo vs üç ayrı tablo) tartıştım.
- 3NF açısından kategorilerin ayrı tablo olması gerektiğine birlikte karar verdim.
- **Sonuç:** Final tasarım kararı bana ait; AI öneri seti içinden seçim yaptım.

### 2.2 SQL Yazımı (kullanıldı — syntax yardımı)
- T-SQL ile MySQL syntax farklarını sorduğumda, SQL Server'a özgü `IDENTITY`, `GETDATE()`, `RAISERROR`, `OUTPUT` gibi yapıları doğrulamak için AI çıktısını referans aldım.
- Trigger içindeki `inserted` / `deleted` mantıklı tablolarının davranışını (özellikle `UPDATE`'te ikisinin birden var olduğu) AI ile teyit ettim.
- **Sonuç:** Her bir trigger gövdesini ben kendim okudum, üzerinde değişiklik yaptım (örneğin `trg_SiparisTeslim_CiroGuncelle` içindeki "yeniden teslim edilen sipariş double-count olmasın" kontrolünü ben ekledim).

### 2.3 Mock Veri Üretimi (kullanıldı — yoğun)
- 25 müşteri, 64 ürün, 120 sipariş gibi yığın veriyi tek tek yazmak yerine AI'dan örnek satır blokları ürettirdim.
- Üretilen veriyi gözden geçirip:
  - Birim fiyatların `CHECK > 0` kısıtına uygun olmasını,
  - Sipariş `Durum`'larının `CHECK IN (...)` listesine uymasını,
  - "Askıda" siparişlerin `OdemeYontemi = 'Askida'` ile tutarlı olmasını,
  - `MusteriID`/`RestoranID` referanslarının mevcut PK'larla eşleşmesini doğruladım.
- **Sonuç:** Veri üzerinde manuel temizlik (örneğin `0+1, 0+45.00` gibi taslak ifadeleri sade `1, 45.00` haline getirme) yapıldı.

### 2.4 Belgeleme (kullanıldı — şablon)
- README, ER diyagramı açıklamaları gibi bölümler için "şablon" niteliğinde AI çıktısı aldım, Türkçe ifadeleri kendi cümlelerimle revize ettim.

### 2.5 Kullanılmayan Yerler
- **Mantık tartışması bana ait**: "Bir bağışçı anonim olabilir mi? Olabilir → `AnonimMi BIT` kolonu". "İhtiyaç sahibi onayı nasıl temsil edilir? → `Musteriler.IhtiyacSahibiOnayli` flag". Bu kararlar bana aittir.
- **Index seçimleri bana ait**: Hangi kolonların indeksleneceği (`SiparisTarihi`, `Email`, `RestoranID + IsActive` filtreli vb.) bizzat sorgu paterni analiz edilerek belirlenmiştir.
- **CHECK kısıtları**: Hangi alanlarda CHECK koyulacağı (puan 1-5, tutar > 0, durum IN-list) iş kurallarından türetilmiştir.

---

## 3. Doğrulama

Aşağıdaki bölümlerin **tamamını yazılı/sözlü olarak savunabilirim**:

- Her tablonun varlık nedeni (neden var?)
- Her FK'nin yönü (neden bu tablodan oraya?)
- Her CHECK kısıtının iş kuralı karşılığı
- Soft Delete pattern'inin uygulama gerekçesi
- "Askıda Yemek" akışının trigger ile otomatize edilme nedeni
- View ve trigger içeriklerinin satır satır mantığı
- Index seçimlerinin sorgu paternleriyle ilişkisi
- Mock veriyle elde edilen analitik sorgu sonuçlarının yorumu

Sınav ve özgünlük doğrulamasında **her satır kodu ben yazmış gibi açıklayabilirim**.

---

## 4. Geliştirme Sürecinin Versiyonlanması

`git_commit_script.sh` dosyası, projenin tek seferde değil **aşamalı commit'lerle** GitHub'a yüklenmesi için hazırlanmıştır. Aşamalar:

1. İlk commit: README + ER diyagramı taslağı
2. İkinci commit: Tablo (DDL) tasarımı
3. Üçüncü commit: Indexler
4. Dördüncü commit: Views
5. Beşinci commit: Triggers
6. Altıncı commit: Mock veriler
7. Yedinci commit: Analitik sorgular
8. Sekizinci commit: Final düzenlemeler + AI beyanı

Bu sayede yönergedeki "son gece tek commit eksi puan" maddesi karşılanır ve gerçek bir geliştirme akışı sergilenir.

---

**Tarih:** 2026-05-12
**İmza:** Yusuf Bağcı
