/* ============================================================================
   Dosya: 02_Indexler.sql
   Açıklama: Performans için index tanımları
   - Primary Key'ler zaten otomatik clustered index yaratır.
   - Sık sorgulanan/filtrelenen kolonlara non-clustered index açılır.
   ============================================================================ */

USE YemekSiparisDB;
GO

/* 1) Siparişler tarih filtresi çok sık kullanılır (örn: "son 1 ayda")
      -> tarihe göre indeksle */
CREATE NONCLUSTERED INDEX IX_Siparisler_SiparisTarihi
    ON Siparisler (SiparisTarihi DESC)
    INCLUDE (MusteriID, RestoranID, ToplamTutar, Durum);
GO

/* 2) Ürün arama büyük ihtimalle restorana göre yapılır
      (restoran menüsü açılması) */
CREATE NONCLUSTERED INDEX IX_Urunler_RestoranID_Aktif
    ON Urunler (RestoranID, IsActive)
    INCLUDE (UrunAd, Fiyat, KategoriID);
GO

/* 3) Müşteri girişlerinde email ile sorgu yapılır */
CREATE NONCLUSTERED INDEX IX_Musteriler_Email
    ON Musteriler (Email)
    WHERE IsActive = 1;
GO

/* 4) Bağış raporlarında müşteri bazlı sorgu sıklıkla yapılır */
CREATE NONCLUSTERED INDEX IX_AskidaBagislari_MusteriID_Tarih
    ON AskidaBagislari (MusteriID, BagisTarihi DESC)
    INCLUDE (BagisTutari, AnonimMi);
GO

PRINT '02_Indexler.sql calistirildi -> Indexler olusturuldu.';
GO
