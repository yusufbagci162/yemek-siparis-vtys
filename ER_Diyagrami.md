# Varlık-İlişki (ER) Diyagramı

Aşağıdaki Mermaid diyagramı **YemekSiparisDB** veritabanının tüm tablolarını ve aralarındaki ilişkileri (PK/FK, kardinalite) gösterir. GitHub bu dosyayı otomatik olarak render eder.

## Mermaid Kaynağı

```mermaid
erDiagram
    MUSTERILER ||--o{ ADRESLER             : "1:N teslimat adresi"
    MUSTERILER ||--o{ SIPARISLER           : "1:N sipariş verir"
    MUSTERILER ||--o{ ASKIDABAGISLARI      : "1:N bağış yapar"
    MUSTERILER ||--o{ ASKIDAKULLANIMLARI   : "1:N havuzdan yararlanır"
    MUSTERILER ||--o{ RESTORANPUANLAMALARI : "1:N puan verir"

    RESTORANLAR ||--o{ URUNLER             : "1:N menü"
    RESTORANLAR ||--o{ SIPARISLER          : "1:N sipariş alır"
    RESTORANLAR ||--o{ RESTORANPUANLAMALARI: "1:N puan alır"

    KATEGORILER ||--o{ URUNLER             : "1:N"
    KURYELER    ||--o{ SIPARISLER          : "0..1:N (NULL olabilir)"

    SIPARISLER  ||--|{ SIPARISDETAYLARI    : "1:N (CASCADE)"
    SIPARISLER  ||--o| RESTORANPUANLAMALARI: "1:0..1 (UNIQUE)"
    SIPARISLER  ||--o| ASKIDAKULLANIMLARI  : "1:0..1 (UNIQUE)"
    URUNLER     ||--o{ SIPARISDETAYLARI    : "1:N"
    ADRESLER    ||--o{ SIPARISLER          : "1:N teslim edilir"

    ASKIDABAGISLARI    }o--|| ASKIDAYEMEKHAVUZU : "trigger artırır"
    ASKIDAKULLANIMLARI }o--|| ASKIDAYEMEKHAVUZU : "trigger düşürür"

    MUSTERILER {
        int      MusteriID PK
        nvarchar Ad
        nvarchar Soyad
        nvarchar Email "UK"
        varchar  Telefon "UK"
        nvarchar SifreHash
        date     DogumTarihi
        datetime KayitTarihi
        bit      IhtiyacSahibiOnayli
        bit      IsActive
    }

    ADRESLER {
        int      AdresID PK
        int      MusteriID FK
        nvarchar Baslik
        nvarchar Sehir
        nvarchar Ilce
        nvarchar AcikAdres
        bit      IsActive
    }

    RESTORANLAR {
        int      RestoranID PK
        nvarchar Ad
        varchar  Telefon "UK"
        nvarchar Adres
        nvarchar MutfakTuru
        decimal  Puan
        decimal  ToplamCiro
        time     AcilisSaati
        time     KapanisSaati
        bit      IsActive
    }

    KURYELER {
        int      KuryeID PK
        nvarchar Ad
        nvarchar Soyad
        varchar  Telefon "UK"
        nvarchar AracTipi
        varchar  Plaka
        bit      IsActive
    }

    KATEGORILER {
        int      KategoriID PK
        nvarchar KategoriAd "UK"
    }

    URUNLER {
        int      UrunID PK
        int      RestoranID FK
        int      KategoriID FK
        nvarchar UrunAd
        nvarchar Aciklama
        decimal  Fiyat
        int      HazirlamaSuresiDk
        bit      IsActive
    }

    SIPARISLER {
        int      SiparisID PK
        int      MusteriID FK
        int      RestoranID FK
        int      KuryeID FK
        int      AdresID FK
        datetime SiparisTarihi
        datetime TeslimTarihi
        decimal  ToplamTutar
        nvarchar OdemeYontemi
        nvarchar Durum
        bit      AskidaMi
        nvarchar Notlar
    }

    SIPARISDETAYLARI {
        int      SiparisDetayID PK
        int      SiparisID FK
        int      UrunID FK
        int      Adet
        decimal  BirimFiyat
    }

    RESTORANPUANLAMALARI {
        int      PuanID PK
        int      SiparisID FK "UK"
        int      MusteriID FK
        int      RestoranID FK
        tinyint  Puan
        nvarchar Yorum
        datetime PuanTarihi
    }

    ASKIDAYEMEKHAVUZU {
        int      HavuzID PK
        decimal  GuncelBakiye
        decimal  ToplamBagisTutari
        decimal  ToplamKullanimTutari
        datetime SonGuncelleme
    }

    ASKIDABAGISLARI {
        int      BagisID PK
        int      MusteriID FK
        decimal  BagisTutari
        nvarchar BagisTuru
        bit      AnonimMi
        datetime BagisTarihi
        nvarchar Aciklama
    }

    ASKIDAKULLANIMLARI {
        int      KullanimID PK
        int      MusteriID FK
        int      SiparisID FK "UK"
        decimal  KullanilanTutar
        datetime KullanimTarihi
    }
```

## Kardinalite Açıklamaları

| İlişki                                            | Tip       | Notlar                                                     |
|---------------------------------------------------|-----------|------------------------------------------------------------|
| Musteriler → Adresler                             | 1 : N     | Müşterinin birden fazla adresi olabilir                    |
| Musteriler → Siparisler                           | 1 : N     | Müşteri sipariş verebilir                                  |
| Musteriler → AskidaBagislari                      | 1 : N     | Bir müşteri birden çok bağış yapabilir                     |
| Musteriler → AskidaKullanimlari                   | 1 : N     | Onaylı müşteri birden çok kez yararlanabilir               |
| Restoranlar → Urunler                             | 1 : N     | Bir restoranın bir menüsü vardır                           |
| Restoranlar → Siparisler                          | 1 : N     | Bir restoran çok sipariş alır                              |
| Kategoriler → Urunler                             | 1 : N     | 3NF gereği kategori ayrı tabloda                           |
| Kuryeler → Siparisler                             | 0..1 : N  | KuryeID NULL olabilir (henüz atanmamış)                    |
| Siparisler ↔ Urunler                              | M : N     | `SiparisDetaylari` ile çözümlenmiştir                      |
| Siparisler → SiparisDetaylari                     | 1 : N     | `ON DELETE CASCADE`                                        |
| Siparisler → RestoranPuanlamalari                 | 1 : 0..1  | `UNIQUE(SiparisID)`                                        |
| Siparisler → AskidaKullanimlari                   | 1 : 0..1  | `UNIQUE(SiparisID)`                                        |
| AskidaBagislari → AskidaYemekHavuzu               | trigger   | INSERT sonrası havuz artar                                 |
| AskidaKullanimlari → AskidaYemekHavuzu            | trigger   | INSERT sonrası havuz düşer (bakiye kontrolü)               |
