/* ============================================================================
   Dosya: 06_AnalitikSorgular.sql
   Açıklama: Yönergenin "İleri Düzey Sorgular (DQL & Analitik)" maddelerini
             karşılayan örnek sorgular. Her sorgu ne yaptığını açıklayan
             yorum satırlarıyla başlar.

   Kapsam:
     1) En az 3 tablolu JOIN (INNER/LEFT) -> detaylı sipariş fişi
     2) GROUP BY + HAVING + SUM/COUNT/AVG -> son 1 ayda 5'ten fazla siparişi
        olan restoranların ortalama sepet tutarları
     3) Alt sorgu (Subquery) -> hiç bağış yapmamış ama aktif sipariş veren
        müşteriler (NOT EXISTS)
     4) EXISTS ile pozitif alt sorgu -> "Askıda Yemek"ten hiç yararlanmamış
        ihtiyaç sahibi onaylı müşteriler
     5) IN ile alt sorgu -> en çok bağış yapan ilk 5 müşterinin profili
     6) Pencere fonksiyonu (BONUS) -> restoran bazında günlük ciro sıralaması
     7) Havuz Durum + Bağışçı/Yararlanan listesi
     8) Soft-delete farkındalığı: pasif restoranların ürünleri analizden hariç
   ============================================================================ */

USE YemekSiparisDB;
GO

/* ----------------------------------------------------------------------------
   SORGU 1) Detaylı sipariş fişi
   - 5 tablo: Siparisler + Musteriler + Restoranlar + Kuryeler(LEFT) +
     SiparisDetaylari + Urunler
   - LEFT JOIN: Henüz kurye atanmamış siparişler de listeye dahildir.
   ---------------------------------------------------------------------------- */
SELECT  s.SiparisID,
        CONVERT(VARCHAR(16), s.SiparisTarihi, 120) AS Tarih,
        m.Ad + N' ' + m.Soyad                       AS Musteri,
        r.Ad                                        AS Restoran,
        ISNULL(k.Ad + N' ' + k.Soyad, N'Atanmadi')  AS Kurye,
        u.UrunAd,
        sd.Adet,
        sd.BirimFiyat,
        (sd.Adet * sd.BirimFiyat)                   AS SatirToplam,
        s.Durum,
        CASE WHEN s.AskidaMi = 1 THEN N'EVET' ELSE N'HAYIR' END AS AskidaSiparisMi
FROM    Siparisler s
INNER JOIN Musteriler         m  ON m.MusteriID  = s.MusteriID
INNER JOIN Restoranlar        r  ON r.RestoranID = s.RestoranID
LEFT  JOIN Kuryeler           k  ON k.KuryeID    = s.KuryeID
INNER JOIN SiparisDetaylari   sd ON sd.SiparisID = s.SiparisID
INNER JOIN Urunler            u  ON u.UrunID     = sd.UrunID
WHERE   s.SiparisID <= 10        -- demo için ilk 10 sipariş
ORDER BY s.SiparisID, sd.SiparisDetayID;
GO

/* ----------------------------------------------------------------------------
   SORGU 2) Son 1 ayda toplam 5'ten fazla TeslimEdildi siparişi olan
            restoranların ortalama sepet tutarı (DESC sıralı)
   - SUM/COUNT/AVG + GROUP BY + HAVING
   ---------------------------------------------------------------------------- */
SELECT  r.RestoranID,
        r.Ad                                AS RestoranAd,
        COUNT(s.SiparisID)                  AS TeslimSiparisAdedi,
        SUM(s.ToplamTutar)                  AS ToplamCiro_Son30Gun,
        AVG(s.ToplamTutar)                  AS OrtSepetTutari
FROM    Restoranlar r
INNER JOIN Siparisler s ON s.RestoranID = r.RestoranID
WHERE   s.Durum = N'TeslimEdildi'
  AND   s.SiparisTarihi >= DATEADD(DAY, -30, GETDATE())
  AND   r.IsActive = 1                  -- soft-delete edilenler dahil değil
GROUP BY r.RestoranID, r.Ad
HAVING  COUNT(s.SiparisID) > 5
ORDER BY OrtSepetTutari DESC;
GO

/* ----------------------------------------------------------------------------
   SORGU 3) Hiç "Askıda Yemek" bağışı yapmamış AMA platformu aktif kullanan
            (en az 1 sipariş vermiş) müşteriler -> NOT EXISTS
   ---------------------------------------------------------------------------- */
SELECT  m.MusteriID,
        m.Ad + N' ' + m.Soyad   AS MusteriAdSoyad,
        m.Email,
        (SELECT COUNT(*) FROM Siparisler s WHERE s.MusteriID = m.MusteriID) AS SiparisAdedi
FROM    Musteriler m
WHERE   m.IsActive = 1
  AND   EXISTS (SELECT 1 FROM Siparisler s WHERE s.MusteriID = m.MusteriID)
  AND   NOT EXISTS (
            SELECT 1
              FROM AskidaBagislari b
             WHERE b.MusteriID = m.MusteriID
        )
ORDER BY SiparisAdedi DESC;
GO

/* ----------------------------------------------------------------------------
   SORGU 4) "İhtiyaç Sahibi Onaylı" olduğu halde HAVUZDAN HİÇ YARARLANMAMIŞ
            müşteriler -> EXISTS + NOT EXISTS
   ---------------------------------------------------------------------------- */
SELECT  m.MusteriID,
        m.Ad + N' ' + m.Soyad AS MusteriAdSoyad,
        m.Email,
        m.KayitTarihi
FROM    Musteriler m
WHERE   m.IhtiyacSahibiOnayli = 1
  AND   m.IsActive = 1
  AND   NOT EXISTS (
            SELECT 1
              FROM AskidaKullanimlari k
             WHERE k.MusteriID = m.MusteriID
        );
GO

/* ----------------------------------------------------------------------------
   SORGU 5) En çok bağış yapan ilk 5 müşterinin profili -> IN ile alt sorgu
   ---------------------------------------------------------------------------- */
SELECT  m.MusteriID,
        m.Ad + N' ' + m.Soyad      AS MusteriAdSoyad,
        SUM(b.BagisTutari)         AS ToplamBagis,
        COUNT(b.BagisID)           AS BagisAdedi
FROM    Musteriler m
INNER JOIN AskidaBagislari b ON b.MusteriID = m.MusteriID
WHERE   m.MusteriID IN (
            SELECT TOP 5 MusteriID
              FROM AskidaBagislari
             GROUP BY MusteriID
             ORDER BY SUM(BagisTutari) DESC
        )
GROUP BY m.MusteriID, m.Ad, m.Soyad
ORDER BY ToplamBagis DESC;
GO

/* ----------------------------------------------------------------------------
   SORGU 6) (BONUS) Pencere fonksiyonu - restoran bazında günlük cironun
            sıralaması (DENSE_RANK)
   ---------------------------------------------------------------------------- */
SELECT  r.Ad                               AS Restoran,
        CAST(s.SiparisTarihi AS DATE)      AS SiparisGunu,
        SUM(s.ToplamTutar)                 AS GunlukCiro,
        DENSE_RANK() OVER (
            PARTITION BY r.RestoranID
            ORDER BY SUM(s.ToplamTutar) DESC
        ) AS GunSiralamasi
FROM    Restoranlar r
INNER JOIN Siparisler s ON s.RestoranID = r.RestoranID AND s.Durum = N'TeslimEdildi'
GROUP BY r.RestoranID, r.Ad, CAST(s.SiparisTarihi AS DATE)
ORDER BY r.Ad, GunSiralamasi;
GO

/* ----------------------------------------------------------------------------
   SORGU 7) Havuz durumu + son 1 haftada havuzdan yararlanan kullanıcılar
   ---------------------------------------------------------------------------- */
SELECT * FROM vw_AskidaYemekHavuzDurumu;

SELECT  m.Ad + N' ' + m.Soyad AS Yararlanan,
        k.SiparisID,
        k.KullanilanTutar,
        k.KullanimTarihi
FROM    AskidaKullanimlari k
INNER JOIN Musteriler m ON m.MusteriID = k.MusteriID
WHERE   k.KullanimTarihi >= DATEADD(DAY, -7, GETDATE())
ORDER BY k.KullanimTarihi DESC;
GO

/* ----------------------------------------------------------------------------
   SORGU 8) Soft-delete farkındalığı:
   - Pasif (IsActive=0) restoranların ürünleri otomatik olarak analiz dışı kalır
   - vw_AktifRestoranMenuleri kullanılarak kategori bazlı ürün sayıları
   ---------------------------------------------------------------------------- */
SELECT  KategoriAd,
        COUNT(*)        AS UrunSayisi,
        AVG(Fiyat)      AS OrtFiyat,
        MIN(Fiyat)      AS MinFiyat,
        MAX(Fiyat)      AS MaxFiyat
FROM    vw_AktifRestoranMenuleri
GROUP BY KategoriAd
ORDER BY UrunSayisi DESC;
GO

/* ----------------------------------------------------------------------------
   SORGU 9) (BONUS) En sadık müşteriler -> her birinin en çok sipariş verdiği
            restoran (CROSS APPLY)
   ---------------------------------------------------------------------------- */
SELECT  m.MusteriID,
        m.Ad + N' ' + m.Soyad AS Musteri,
        top1.RestoranAd,
        top1.SiparisAdedi
FROM    Musteriler m
CROSS APPLY (
    SELECT TOP 1 r.Ad AS RestoranAd, COUNT(s.SiparisID) AS SiparisAdedi
      FROM Siparisler s
      JOIN Restoranlar r ON r.RestoranID = s.RestoranID
     WHERE s.MusteriID = m.MusteriID
     GROUP BY r.Ad
     ORDER BY COUNT(s.SiparisID) DESC
) top1
WHERE   m.IsActive = 1
ORDER BY top1.SiparisAdedi DESC;
GO

PRINT '06_AnalitikSorgular.sql calistirildi.';
GO
