/* ============================================================================
   Dosya: 04_Gorunumler.sql
   Açıklama: Karmaşık sorguları basitleştiren VIEW (görünüm) tanımları.

   1) vw_AktifRestoranMenuleri    -> Aktif restoranların aktif menüleri
   2) vw_AskidaYemekHavuzDurumu   -> Havuzun anlık durumu (bağış/kullanım özeti)
   3) vw_SiparisFisi              -> Detaylı sipariş fişi (JOIN'li)
   4) vw_RestoranCiroOzet         -> Restoran ciro/sipariş özeti
   ============================================================================ */

USE YemekSiparisDB;
GO

/* ----------------------------------------------------------------------------
   1) AKTİF RESTORANLARIN AKTİF MENÜLERİ
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('vw_AktifRestoranMenuleri','V') IS NOT NULL
    DROP VIEW vw_AktifRestoranMenuleri;
GO

CREATE VIEW vw_AktifRestoranMenuleri AS
SELECT  r.RestoranID,
        r.Ad           AS RestoranAd,
        r.MutfakTuru,
        r.Puan         AS RestoranPuan,
        u.UrunID,
        u.UrunAd,
        k.KategoriAd,
        u.Fiyat,
        u.HazirlamaSuresiDk
FROM    Restoranlar r
INNER JOIN Urunler     u ON u.RestoranID = r.RestoranID
INNER JOIN Kategoriler k ON k.KategoriID = u.KategoriID
WHERE   r.IsActive = 1
  AND   u.IsActive = 1;
GO

/* ----------------------------------------------------------------------------
   2) ASKIDA YEMEK HAVUZU DURUMU
   - Toplam bağış, toplam kullanım, anlık bakiye, kalan bağışçı/yararlanan sayısı
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('vw_AskidaYemekHavuzDurumu','V') IS NOT NULL
    DROP VIEW vw_AskidaYemekHavuzDurumu;
GO

CREATE VIEW vw_AskidaYemekHavuzDurumu AS
SELECT  h.HavuzID,
        h.GuncelBakiye,
        h.ToplamBagisTutari,
        h.ToplamKullanimTutari,
        (SELECT COUNT(DISTINCT MusteriID) FROM AskidaBagislari)    AS ToplamBagisciSayisi,
        (SELECT COUNT(DISTINCT MusteriID) FROM AskidaKullanimlari) AS ToplamYararlananSayisi,
        (SELECT COUNT(*) FROM AskidaBagislari)                     AS ToplamBagisAdedi,
        (SELECT COUNT(*) FROM AskidaKullanimlari)                  AS ToplamKullanimAdedi,
        h.SonGuncelleme
FROM    AskidaYemekHavuzu h
WHERE   h.HavuzID = 1;
GO

/* ----------------------------------------------------------------------------
   3) DETAYLI SİPARİŞ FİŞİ (JOIN'li)
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('vw_SiparisFisi','V') IS NOT NULL
    DROP VIEW vw_SiparisFisi;
GO

CREATE VIEW vw_SiparisFisi AS
SELECT  s.SiparisID,
        s.SiparisTarihi,
        s.Durum,
        s.AskidaMi,
        s.OdemeYontemi,
        m.MusteriID,
        (m.Ad + N' ' + m.Soyad)        AS MusteriAdSoyad,
        m.Telefon                       AS MusteriTelefon,
        r.RestoranID,
        r.Ad                            AS RestoranAd,
        ISNULL(k.Ad + N' ' + k.Soyad, N'Atanmadi') AS KuryeAdSoyad,
        a.Sehir, a.Ilce, a.AcikAdres,
        sd.SiparisDetayID,
        u.UrunAd,
        sd.Adet,
        sd.BirimFiyat,
        (sd.Adet * sd.BirimFiyat)       AS SatirToplam,
        s.ToplamTutar                    AS SiparisToplam
FROM    Siparisler s
INNER JOIN Musteriler         m  ON m.MusteriID  = s.MusteriID
INNER JOIN Restoranlar        r  ON r.RestoranID = s.RestoranID
LEFT  JOIN Kuryeler           k  ON k.KuryeID    = s.KuryeID
INNER JOIN Adresler           a  ON a.AdresID    = s.AdresID
INNER JOIN SiparisDetaylari   sd ON sd.SiparisID = s.SiparisID
INNER JOIN Urunler            u  ON u.UrunID     = sd.UrunID;
GO

/* ----------------------------------------------------------------------------
   4) RESTORAN CİRO ÖZET GÖRÜNÜMÜ
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('vw_RestoranCiroOzet','V') IS NOT NULL
    DROP VIEW vw_RestoranCiroOzet;
GO

CREATE VIEW vw_RestoranCiroOzet AS
SELECT  r.RestoranID,
        r.Ad AS RestoranAd,
        r.MutfakTuru,
        r.Puan,
        r.ToplamCiro,
        COUNT(s.SiparisID)                                 AS ToplamSiparisAdedi,
        SUM(CASE WHEN s.Durum = N'TeslimEdildi' THEN 1 ELSE 0 END) AS BasariliSiparisAdedi,
        SUM(CASE WHEN s.Durum = N'IptalEdildi'  THEN 1 ELSE 0 END) AS IptalSiparisAdedi,
        AVG(CASE WHEN s.Durum = N'TeslimEdildi' THEN s.ToplamTutar END) AS OrtSepetTutari
FROM    Restoranlar r
LEFT JOIN Siparisler s ON s.RestoranID = r.RestoranID
WHERE   r.IsActive = 1
GROUP BY r.RestoranID, r.Ad, r.MutfakTuru, r.Puan, r.ToplamCiro;
GO

PRINT '04_Gorunumler.sql calistirildi -> 4 view olusturuldu.';
GO
