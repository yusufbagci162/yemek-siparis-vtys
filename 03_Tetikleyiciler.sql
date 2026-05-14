/* ============================================================================
   Dosya: 03_Tetikleyiciler.sql
   Açıklama: İş kurallarını otomatize eden TRIGGER (tetikleyici) tanımları.

   Aşağıda 4 adet tetikleyici tanımlıdır:
     1) trg_AskidaBagis_Sonrasi       (INSERT)
     2) trg_AskidaKullanim_Sonrasi    (INSERT)
     3) trg_SiparisTeslim_CiroGuncelle (UPDATE)
     4) trg_Puanlama_Sonrasi          (INSERT)  -> restoran ortalama puanı

   Zorunlu istek "en az 2 trigger" olsa da senaryoyu tam karşılamak için 4 adet
   yazılmıştır. Hepsi de farklı iş kurallarını kapsar.
   ============================================================================ */

USE YemekSiparisDB;
GO

/* ----------------------------------------------------------------------------
   1) ASKIDA BAĞIŞI SONRASI HAVUZ BAKİYESİNİ ARTIRMA
   - Her INSERT'te (toplu bağış da olabilir) tüm bağış tutarları toplanıp
     havuza eklenir.
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('trg_AskidaBagis_Sonrasi','TR') IS NOT NULL
    DROP TRIGGER trg_AskidaBagis_Sonrasi;
GO

CREATE TRIGGER trg_AskidaBagis_Sonrasi
ON AskidaBagislari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ToplamYeniBagis DECIMAL(14,2);
    SELECT @ToplamYeniBagis = ISNULL(SUM(BagisTutari), 0) FROM inserted;

    UPDATE AskidaYemekHavuzu
       SET GuncelBakiye      = GuncelBakiye      + @ToplamYeniBagis,
           ToplamBagisTutari = ToplamBagisTutari + @ToplamYeniBagis,
           SonGuncelleme     = GETDATE()
     WHERE HavuzID = 1;
END;
GO

/* ----------------------------------------------------------------------------
   2) ASKIDA KULLANIMI SONRASI HAVUZ BAKİYESİNİ DÜŞÜRME
   - Önce yeterli bakiye var mı kontrol edilir (yoksa rollback)
   - Sonra havuz tablosu güncellenir
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('trg_AskidaKullanim_Sonrasi','TR') IS NOT NULL
    DROP TRIGGER trg_AskidaKullanim_Sonrasi;
GO

CREATE TRIGGER trg_AskidaKullanim_Sonrasi
ON AskidaKullanimlari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ToplamKullanim DECIMAL(14,2);
    SELECT @ToplamKullanim = ISNULL(SUM(KullanilanTutar), 0) FROM inserted;

    DECLARE @MevcutBakiye DECIMAL(14,2);
    SELECT @MevcutBakiye = GuncelBakiye FROM AskidaYemekHavuzu WHERE HavuzID = 1;

    IF @MevcutBakiye < @ToplamKullanim
    BEGIN
        RAISERROR (N'Askida havuzunda yeterli bakiye yok. Islem iptal edildi.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE AskidaYemekHavuzu
       SET GuncelBakiye         = GuncelBakiye         - @ToplamKullanim,
           ToplamKullanimTutari = ToplamKullanimTutari + @ToplamKullanim,
           SonGuncelleme        = GETDATE()
     WHERE HavuzID = 1;
END;
GO

/* ----------------------------------------------------------------------------
   3) SİPARİŞ TESLİM EDİLDİĞİNDE RESTORAN CİROSUNU GÜNCELLEME
   - Durum 'TeslimEdildi' olduğunda restoran ToplamCiro hanesine sipariş tutarı
     eklenir.
   - Daha önce zaten teslim edilmiş bir siparişin tekrar güncellenmemesi için
     "deleted" ile karşılaştırılır.
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('trg_SiparisTeslim_CiroGuncelle','TR') IS NOT NULL
    DROP TRIGGER trg_SiparisTeslim_CiroGuncelle;
GO

CREATE TRIGGER trg_SiparisTeslim_CiroGuncelle
ON Siparisler
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(Durum) RETURN;

    -- Sadece yeni teslim edilenleri al (daha önce teslim edilmemiş, şimdi edilen)
    ;WITH YeniTeslimler AS (
        SELECT i.RestoranID, i.ToplamTutar
          FROM inserted i
          JOIN deleted  d ON d.SiparisID = i.SiparisID
         WHERE i.Durum = N'TeslimEdildi'
           AND d.Durum <> N'TeslimEdildi'
    )
    UPDATE r
       SET r.ToplamCiro = r.ToplamCiro + ISNULL(yt.Tutar, 0)
      FROM Restoranlar r
      JOIN (
            SELECT RestoranID, SUM(ToplamTutar) AS Tutar
              FROM YeniTeslimler
             GROUP BY RestoranID
           ) yt ON yt.RestoranID = r.RestoranID;

    -- Teslim tarihini de doldur
    UPDATE s
       SET s.TeslimTarihi = GETDATE()
      FROM Siparisler s
      JOIN inserted i ON i.SiparisID = s.SiparisID
      JOIN deleted  d ON d.SiparisID = s.SiparisID
     WHERE i.Durum = N'TeslimEdildi'
       AND d.Durum <> N'TeslimEdildi'
       AND s.TeslimTarihi IS NULL;
END;
GO

/* ----------------------------------------------------------------------------
   4) YENİ PUANLAMA SONRASI RESTORAN ORTALAMA PUANINI GÜNCELLEME
   ---------------------------------------------------------------------------- */
IF OBJECT_ID('trg_Puanlama_Sonrasi','TR') IS NOT NULL
    DROP TRIGGER trg_Puanlama_Sonrasi;
GO

CREATE TRIGGER trg_Puanlama_Sonrasi
ON RestoranPuanlamalari
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Etkilenen restoranların ID listesini topla
    DECLARE @Etkilenenler TABLE (RestoranID INT);

    INSERT INTO @Etkilenenler (RestoranID)
    SELECT DISTINCT RestoranID FROM inserted
    UNION
    SELECT DISTINCT RestoranID FROM deleted;

    UPDATE r
       SET r.Puan = ISNULL((
            SELECT CAST(AVG(CAST(p.Puan AS DECIMAL(5,2))) AS DECIMAL(3,2))
              FROM RestoranPuanlamalari p
             WHERE p.RestoranID = r.RestoranID
       ), 0)
      FROM Restoranlar r
      JOIN @Etkilenenler e ON e.RestoranID = r.RestoranID;
END;
GO

PRINT '03_Tetikleyiciler.sql calistirildi -> 4 trigger olusturuldu.';
GO
