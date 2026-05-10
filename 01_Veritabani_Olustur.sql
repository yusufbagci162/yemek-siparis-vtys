/* ============================================================================
   VTYS-1 DÖNEM PROJESİ
   Çevrimiçi Yemek Sipariş Platformu - "Askıda Yemek" Modülü Dahil
   DBMS: Microsoft SQL Server (T-SQL)
   Dosya: 01_Veritabani_Olustur.sql
   Açıklama: Veritabanı ve tüm tabloların oluşturulması (DDL)
   ============================================================================ */

-- Veritabanı varsa kaldır (geliştirme amaçlı)
IF DB_ID('YemekSiparisDB') IS NOT NULL
BEGIN
    ALTER DATABASE YemekSiparisDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE YemekSiparisDB;
END
GO

CREATE DATABASE YemekSiparisDB;
GO

USE YemekSiparisDB;
GO

/* ----------------------------------------------------------------------------
   1) MUSTERILER
   - Email ve Telefon UNIQUE (aynı kullanıcı tekrar kayıt olamaz)
   - IhtiyacSahibiOnayli: "Askıda Yemek" havuzundan ücretsiz sipariş verebilmek
     için sosyal hizmetler tarafından onaylanmış kullanıcıları işaretler.
   - IsActive: Soft delete için (silinmez, pasife alınır)
   ---------------------------------------------------------------------------- */
CREATE TABLE Musteriler (
    MusteriID         INT IDENTITY(1,1) NOT NULL,
    Ad                NVARCHAR(50)  NOT NULL,
    Soyad             NVARCHAR(50)  NOT NULL,
    Email             NVARCHAR(120) NOT NULL,
    Telefon           VARCHAR(15)   NOT NULL,
    SifreHash         NVARCHAR(255) NOT NULL,
    DogumTarihi       DATE          NULL,
    KayitTarihi       DATETIME      NOT NULL CONSTRAINT DF_Musteriler_KayitTarihi DEFAULT (GETDATE()),
    IhtiyacSahibiOnayli BIT         NOT NULL CONSTRAINT DF_Musteriler_IhtiyacSahibi DEFAULT (0),
    IsActive          BIT           NOT NULL CONSTRAINT DF_Musteriler_IsActive DEFAULT (1),

    CONSTRAINT PK_Musteriler PRIMARY KEY (MusteriID),
    CONSTRAINT UQ_Musteriler_Email   UNIQUE (Email),
    CONSTRAINT UQ_Musteriler_Telefon UNIQUE (Telefon),
    CONSTRAINT CK_Musteriler_Email   CHECK (Email LIKE '%@%.%'),
    CONSTRAINT CK_Musteriler_Telefon CHECK (LEN(Telefon) BETWEEN 10 AND 15)
);
GO

/* ----------------------------------------------------------------------------
   2) ADRESLER
   - Bir müşterinin birden fazla teslimat adresi olabilir (1:N)
   ---------------------------------------------------------------------------- */
CREATE TABLE Adresler (
    AdresID    INT IDENTITY(1,1) NOT NULL,
    MusteriID  INT           NOT NULL,
    Baslik     NVARCHAR(50)  NOT NULL,   -- "Ev", "İş" vb.
    Sehir      NVARCHAR(50)  NOT NULL,
    Ilce       NVARCHAR(50)  NOT NULL,
    AcikAdres  NVARCHAR(255) NOT NULL,
    IsActive   BIT           NOT NULL CONSTRAINT DF_Adresler_IsActive DEFAULT (1),

    CONSTRAINT PK_Adresler PRIMARY KEY (AdresID),
    CONSTRAINT FK_Adresler_Musteriler FOREIGN KEY (MusteriID)
        REFERENCES Musteriler(MusteriID)
);
GO

/* ----------------------------------------------------------------------------
   3) RESTORANLAR
   - Puan CHECK constraint ile 0-5 arası tutulur (henüz puanlanmamış ise 0)
   ---------------------------------------------------------------------------- */
CREATE TABLE Restoranlar (
    RestoranID    INT IDENTITY(1,1) NOT NULL,
    Ad            NVARCHAR(100) NOT NULL,
    Telefon       VARCHAR(15)   NOT NULL,
    Adres         NVARCHAR(255) NOT NULL,
    MutfakTuru    NVARCHAR(50)  NOT NULL,
    Puan          DECIMAL(3,2)  NOT NULL CONSTRAINT DF_Restoranlar_Puan DEFAULT (0),
    ToplamCiro    DECIMAL(14,2) NOT NULL CONSTRAINT DF_Restoranlar_Ciro DEFAULT (0),
    AcilisSaati   TIME          NOT NULL CONSTRAINT DF_Restoranlar_Acilis DEFAULT ('09:00'),
    KapanisSaati  TIME          NOT NULL CONSTRAINT DF_Restoranlar_Kapanis DEFAULT ('23:00'),
    IsActive      BIT           NOT NULL CONSTRAINT DF_Restoranlar_IsActive DEFAULT (1),

    CONSTRAINT PK_Restoranlar PRIMARY KEY (RestoranID),
    CONSTRAINT UQ_Restoranlar_Telefon UNIQUE (Telefon),
    CONSTRAINT CK_Restoranlar_Puan CHECK (Puan BETWEEN 0 AND 5),
    CONSTRAINT CK_Restoranlar_Ciro CHECK (ToplamCiro >= 0)
);
GO

/* ----------------------------------------------------------------------------
   4) KURYELER
   ---------------------------------------------------------------------------- */
CREATE TABLE Kuryeler (
    KuryeID    INT IDENTITY(1,1) NOT NULL,
    Ad         NVARCHAR(50) NOT NULL,
    Soyad      NVARCHAR(50) NOT NULL,
    Telefon    VARCHAR(15)  NOT NULL,
    AracTipi   NVARCHAR(20) NOT NULL,  -- Motosiklet, Bisiklet, Araba
    Plaka      VARCHAR(15)  NULL,
    IsActive   BIT          NOT NULL CONSTRAINT DF_Kuryeler_IsActive DEFAULT (1),

    CONSTRAINT PK_Kuryeler PRIMARY KEY (KuryeID),
    CONSTRAINT UQ_Kuryeler_Telefon UNIQUE (Telefon),
    CONSTRAINT CK_Kuryeler_AracTipi CHECK (AracTipi IN (N'Motosiklet', N'Bisiklet', N'Araba', N'Yaya'))
);
GO

/* ----------------------------------------------------------------------------
   5) KATEGORILER (3NF için ürün kategorileri ayrı tablo)
   ---------------------------------------------------------------------------- */
CREATE TABLE Kategoriler (
    KategoriID INT IDENTITY(1,1) NOT NULL,
    KategoriAd NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Kategoriler PRIMARY KEY (KategoriID),
    CONSTRAINT UQ_Kategoriler_Ad UNIQUE (KategoriAd)
);
GO

/* ----------------------------------------------------------------------------
   6) URUNLER
   - Fiyat sıfırdan büyük olmalı (CHECK)
   - Restorana bağlı (FK)
   - Kategoriye bağlı (FK)
   ---------------------------------------------------------------------------- */
CREATE TABLE Urunler (
    UrunID       INT IDENTITY(1,1) NOT NULL,
    RestoranID   INT           NOT NULL,
    KategoriID   INT           NOT NULL,
    UrunAd       NVARCHAR(100) NOT NULL,
    Aciklama     NVARCHAR(255) NULL,
    Fiyat        DECIMAL(10,2) NOT NULL,
    HazirlamaSuresiDk INT      NOT NULL CONSTRAINT DF_Urunler_HazirlamaSuresi DEFAULT (20),
    IsActive     BIT           NOT NULL CONSTRAINT DF_Urunler_IsActive DEFAULT (1),

    CONSTRAINT PK_Urunler PRIMARY KEY (UrunID),
    CONSTRAINT FK_Urunler_Restoranlar FOREIGN KEY (RestoranID)
        REFERENCES Restoranlar(RestoranID),
    CONSTRAINT FK_Urunler_Kategoriler FOREIGN KEY (KategoriID)
        REFERENCES Kategoriler(KategoriID),
    CONSTRAINT CK_Urunler_Fiyat CHECK (Fiyat > 0),
    CONSTRAINT CK_Urunler_HazirlamaSuresi CHECK (HazirlamaSuresiDk > 0)
);
GO

/* ----------------------------------------------------------------------------
   7) SIPARISLER
   - Durum: Yeni / Hazirlaniyor / Yolda / TeslimEdildi / IptalEdildi
   - AskidaMi: 1 ise bu sipariş "Askıda Yemek" havuzundan karşılanmıştır
   - ToplamTutar CHECK >= 0
   ---------------------------------------------------------------------------- */
CREATE TABLE Siparisler (
    SiparisID      INT IDENTITY(1,1) NOT NULL,
    MusteriID      INT           NOT NULL,
    RestoranID     INT           NOT NULL,
    KuryeID        INT           NULL,    -- sipariş atandığında dolar
    AdresID        INT           NOT NULL,
    SiparisTarihi  DATETIME      NOT NULL CONSTRAINT DF_Siparisler_Tarih DEFAULT (GETDATE()),
    TeslimTarihi   DATETIME      NULL,
    ToplamTutar    DECIMAL(12,2) NOT NULL,
    OdemeYontemi   NVARCHAR(20)  NOT NULL,    -- KrediKarti, Nakit, Askida
    Durum          NVARCHAR(20)  NOT NULL CONSTRAINT DF_Siparisler_Durum DEFAULT (N'Yeni'),
    AskidaMi       BIT           NOT NULL CONSTRAINT DF_Siparisler_Askida DEFAULT (0),
    Notlar         NVARCHAR(255) NULL,

    CONSTRAINT PK_Siparisler PRIMARY KEY (SiparisID),
    CONSTRAINT FK_Siparisler_Musteriler  FOREIGN KEY (MusteriID)  REFERENCES Musteriler(MusteriID),
    CONSTRAINT FK_Siparisler_Restoranlar FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID),
    CONSTRAINT FK_Siparisler_Kuryeler    FOREIGN KEY (KuryeID)    REFERENCES Kuryeler(KuryeID),
    CONSTRAINT FK_Siparisler_Adresler    FOREIGN KEY (AdresID)    REFERENCES Adresler(AdresID),
    CONSTRAINT CK_Siparisler_Tutar  CHECK (ToplamTutar >= 0),
    CONSTRAINT CK_Siparisler_Durum  CHECK (Durum IN (N'Yeni', N'Hazirlaniyor', N'Yolda', N'TeslimEdildi', N'IptalEdildi')),
    CONSTRAINT CK_Siparisler_Odeme  CHECK (OdemeYontemi IN (N'KrediKarti', N'Nakit', N'Askida'))
);
GO

/* ----------------------------------------------------------------------------
   8) SIPARIS DETAYLARI (M:N kırılımı: Siparis - Urun)
   - Adet > 0
   - BirimFiyat siparişin verildiği andaki fiyatı saklar (tarihsel doğruluk)
   ---------------------------------------------------------------------------- */
CREATE TABLE SiparisDetaylari (
    SiparisDetayID INT IDENTITY(1,1) NOT NULL,
    SiparisID      INT NOT NULL,
    UrunID         INT NOT NULL,
    Adet           INT NOT NULL,
    BirimFiyat     DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_SiparisDetaylari PRIMARY KEY (SiparisDetayID),
    CONSTRAINT FK_SiparisDetaylari_Siparisler FOREIGN KEY (SiparisID)
        REFERENCES Siparisler(SiparisID) ON DELETE CASCADE,
    CONSTRAINT FK_SiparisDetaylari_Urunler FOREIGN KEY (UrunID)
        REFERENCES Urunler(UrunID),
    CONSTRAINT CK_SiparisDetaylari_Adet  CHECK (Adet > 0),
    CONSTRAINT CK_SiparisDetaylari_Fiyat CHECK (BirimFiyat > 0)
);
GO

/* ----------------------------------------------------------------------------
   9) RESTORAN PUANLAMALARI
   - Bir siparişe en fazla bir puanlama
   - Puan 1-5 arası (CHECK)
   ---------------------------------------------------------------------------- */
CREATE TABLE RestoranPuanlamalari (
    PuanID     INT IDENTITY(1,1) NOT NULL,
    SiparisID  INT NOT NULL,
    MusteriID  INT NOT NULL,
    RestoranID INT NOT NULL,
    Puan       TINYINT NOT NULL,
    Yorum      NVARCHAR(500) NULL,
    PuanTarihi DATETIME NOT NULL CONSTRAINT DF_Puanlama_Tarih DEFAULT (GETDATE()),

    CONSTRAINT PK_RestoranPuanlamalari PRIMARY KEY (PuanID),
    CONSTRAINT UQ_Puanlama_Siparis UNIQUE (SiparisID),
    CONSTRAINT FK_Puanlama_Siparisler  FOREIGN KEY (SiparisID)  REFERENCES Siparisler(SiparisID),
    CONSTRAINT FK_Puanlama_Musteriler  FOREIGN KEY (MusteriID)  REFERENCES Musteriler(MusteriID),
    CONSTRAINT FK_Puanlama_Restoranlar FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID),
    CONSTRAINT CK_Puanlama_Puan CHECK (Puan BETWEEN 1 AND 5)
);
GO

/* ============================================================================
   "ASKIDA YEMEK" MODÜLÜ TABLOLARI
   ============================================================================
   İş kuralı:
   1) Bağışçı müşteri "AskidaBagislari" tablosuna kayıt atar.
   2) Trigger (trg_AskidaBagis_Sonrasi) "AskidaYemekHavuzu" toplam bakiyesini
      otomatik olarak artırır.
   3) İhtiyaç sahibi onaylı müşteri sipariş verirken AskidaMi=1 ile kayıt açar.
   4) "AskidaKullanimlari" tablosuna kayıt düşülür, trigger
      (trg_AskidaKullanim_Sonrasi) havuzdan ilgili tutarı düşer.
   5) Havuzda yeterli bakiye yoksa kullanım kaydı atılamaz (CHECK + trigger).
   ============================================================================ */

/* ----------------------------------------------------------------------------
   10) ASKIDA YEMEK HAVUZU (tek satırlık özet tablo)
   - HavuzID = 1 olarak sabit tutulur (singleton)
   - GuncelBakiye negatif olamaz
   ---------------------------------------------------------------------------- */
CREATE TABLE AskidaYemekHavuzu (
    HavuzID          INT NOT NULL,
    GuncelBakiye     DECIMAL(14,2) NOT NULL CONSTRAINT DF_Havuz_Bakiye DEFAULT (0),
    ToplamBagisTutari DECIMAL(14,2) NOT NULL CONSTRAINT DF_Havuz_ToplamBagis DEFAULT (0),
    ToplamKullanimTutari DECIMAL(14,2) NOT NULL CONSTRAINT DF_Havuz_ToplamKullanim DEFAULT (0),
    SonGuncelleme    DATETIME NOT NULL CONSTRAINT DF_Havuz_SonGuncelleme DEFAULT (GETDATE()),

    CONSTRAINT PK_AskidaYemekHavuzu PRIMARY KEY (HavuzID),
    CONSTRAINT CK_Havuz_BakiyePozitif    CHECK (GuncelBakiye >= 0),
    CONSTRAINT CK_Havuz_BagisPozitif     CHECK (ToplamBagisTutari >= 0),
    CONSTRAINT CK_Havuz_KullanimPozitif  CHECK (ToplamKullanimTutari >= 0),
    CONSTRAINT CK_Havuz_TekSatir         CHECK (HavuzID = 1)
);
GO

/* ----------------------------------------------------------------------------
   11) ASKIDA BAĞIŞLARI
   - BagisTuru: 'Bakiye' (parasal) veya 'Yemek' (somut ürün)
   - AnonimMi: 1 ise raporlarda isim gizlenir
   - BagisTutari pozitif olmalı
   ---------------------------------------------------------------------------- */
CREATE TABLE AskidaBagislari (
    BagisID       INT IDENTITY(1,1) NOT NULL,
    MusteriID     INT           NOT NULL,
    BagisTutari   DECIMAL(10,2) NOT NULL,
    BagisTuru     NVARCHAR(10)  NOT NULL,    -- Bakiye / Yemek
    AnonimMi      BIT           NOT NULL CONSTRAINT DF_AskidaBagis_Anonim DEFAULT (0),
    BagisTarihi   DATETIME      NOT NULL CONSTRAINT DF_AskidaBagis_Tarih DEFAULT (GETDATE()),
    Aciklama      NVARCHAR(255) NULL,

    CONSTRAINT PK_AskidaBagislari PRIMARY KEY (BagisID),
    CONSTRAINT FK_AskidaBagis_Musteriler FOREIGN KEY (MusteriID)
        REFERENCES Musteriler(MusteriID),
    CONSTRAINT CK_AskidaBagis_Tutar CHECK (BagisTutari > 0),
    CONSTRAINT CK_AskidaBagis_Turu  CHECK (BagisTuru IN (N'Bakiye', N'Yemek'))
);
GO

/* ----------------------------------------------------------------------------
   12) ASKIDA KULLANIMLARI
   - İhtiyaç sahibi müşterinin havuzdan yararlandığı kayıt
   - SiparisID UNIQUE -> bir sipariş havuzdan sadece bir kez yararlanır
   ---------------------------------------------------------------------------- */
CREATE TABLE AskidaKullanimlari (
    KullanimID      INT IDENTITY(1,1) NOT NULL,
    MusteriID       INT           NOT NULL,
    SiparisID       INT           NOT NULL,
    KullanilanTutar DECIMAL(10,2) NOT NULL,
    KullanimTarihi  DATETIME      NOT NULL CONSTRAINT DF_AskidaKullanim_Tarih DEFAULT (GETDATE()),

    CONSTRAINT PK_AskidaKullanimlari PRIMARY KEY (KullanimID),
    CONSTRAINT UQ_AskidaKullanim_Siparis UNIQUE (SiparisID),
    CONSTRAINT FK_AskidaKullanim_Musteriler FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    CONSTRAINT FK_AskidaKullanim_Siparisler FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID),
    CONSTRAINT CK_AskidaKullanim_Tutar CHECK (KullanilanTutar > 0)
);
GO

/* Havuzun singleton kaydını oluştur */
INSERT INTO AskidaYemekHavuzu (HavuzID, GuncelBakiye, ToplamBagisTutari, ToplamKullanimTutari)
VALUES (1, 0, 0, 0);
GO

PRINT '01_Veritabani_Olustur.sql calistirildi -> Tablolar olusturuldu.';
GO
