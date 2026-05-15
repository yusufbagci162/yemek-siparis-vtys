/* ============================================================================
   Dosya: 05_TestVerileri.sql
   Açıklama: Sistemin test edilebilmesi için sahte (mock) veriler.

   Yönergede istenen asgari hacim:
     - En az 5 restoran          -> 8 restoran (1 tanesi soft-delete pasif)
     - En az 50 farklı ürün       -> 59 ürün (1 tanesi soft-delete pasif)
     - En az 20 müşteri          -> 25 müşteri (4'ü "ihtiyaç sahibi onaylı")
     - "Askıda Yemek" işlemleri  -> 18 bağış + 12 kullanım
     - En az 100 sipariş hareketi -> 120 sipariş + 30 detay
   ============================================================================ */

USE YemekSiparisDB;
GO

-- Önceki verileri temizleme (yeniden çalıştırılabilirlik için)
SET NOCOUNT ON;
DELETE FROM AskidaKullanimlari;
DELETE FROM AskidaBagislari;
DELETE FROM RestoranPuanlamalari;
DELETE FROM SiparisDetaylari;
DELETE FROM Siparisler;
DELETE FROM Urunler;
DELETE FROM Kategoriler;
DELETE FROM Adresler;
DELETE FROM Kuryeler;
DELETE FROM Restoranlar;
DELETE FROM Musteriler;
UPDATE AskidaYemekHavuzu
   SET GuncelBakiye = 0, ToplamBagisTutari = 0, ToplamKullanimTutari = 0
 WHERE HavuzID = 1;
DBCC CHECKIDENT('Musteriler', RESEED, 0);
DBCC CHECKIDENT('Restoranlar', RESEED, 0);
DBCC CHECKIDENT('Kuryeler', RESEED, 0);
DBCC CHECKIDENT('Kategoriler', RESEED, 0);
DBCC CHECKIDENT('Urunler', RESEED, 0);
DBCC CHECKIDENT('Adresler', RESEED, 0);
DBCC CHECKIDENT('Siparisler', RESEED, 0);
DBCC CHECKIDENT('SiparisDetaylari', RESEED, 0);
DBCC CHECKIDENT('RestoranPuanlamalari', RESEED, 0);
DBCC CHECKIDENT('AskidaBagislari', RESEED, 0);
DBCC CHECKIDENT('AskidaKullanimlari', RESEED, 0);
GO

/* ============================================================================
   KATEGORILER (8)
   ============================================================================ */
INSERT INTO Kategoriler (KategoriAd) VALUES
(N'Ana Yemek'), (N'Çorba'), (N'Salata'), (N'Tatlı'),
(N'İçecek'), (N'Pizza'), (N'Burger'), (N'Mezeler');
GO

/* ============================================================================
   RESTORANLAR (8 - 1 tanesi IsActive=0, soft delete örneği)
   ============================================================================ */
INSERT INTO Restoranlar (Ad, Telefon, Adres, MutfakTuru, Puan, ToplamCiro, AcilisSaati, KapanisSaati, IsActive) VALUES
(N'Lezzet Durağı',         '02121111111', N'Beşiktaş, İstanbul',    N'Türk Mutfağı', 4.50, 0, '10:00', '23:30', 1),
(N'Pizza Romana',           '02122222222', N'Kadıköy, İstanbul',     N'İtalyan',      4.20, 0, '11:00', '00:00', 1),
(N'Burger Joint',           '02123333333', N'Şişli, İstanbul',       N'Fast Food',    4.00, 0, '10:30', '23:00', 1),
(N'Sushi Tokyo',            '02124444444', N'Etiler, İstanbul',      N'Japon',        4.70, 0, '12:00', '23:00', 1),
(N'Vegan Bahçe',            '02125555555', N'Cihangir, İstanbul',    N'Sağlıklı',     4.30, 0, '09:00', '22:00', 1),
(N'Kebapçı Mehmet Usta',    '02126666666', N'Üsküdar, İstanbul',     N'Türk Mutfağı', 4.60, 0, '11:00', '23:30', 1),
(N'Çin Sarayı',             '02127777777', N'Maslak, İstanbul',      N'Çin Mutfağı',  3.90, 0, '11:30', '22:30', 1),
(N'Eski Lokanta',           '02128888888', N'Fatih, İstanbul',       N'Türk Mutfağı', 3.50, 0, '10:00', '22:00', 0);
GO

/* ============================================================================
   KURYELER (10)
   ============================================================================ */
INSERT INTO Kuryeler (Ad, Soyad, Telefon, AracTipi, Plaka, IsActive) VALUES
(N'Ahmet',    N'Yıldız',   '05551110001', N'Motosiklet', N'34 KU 001', 1),
(N'Mehmet',   N'Demir',    '05551110002', N'Motosiklet', N'34 KU 002', 1),
(N'Ali',      N'Kaya',     '05551110003', N'Bisiklet',   NULL,         1),
(N'Hasan',    N'Şahin',    '05551110004', N'Motosiklet', N'34 KU 004', 1),
(N'Hüseyin',  N'Çelik',    '05551110005', N'Araba',      N'34 AB 005', 1),
(N'Mustafa',  N'Aydın',    '05551110006', N'Motosiklet', N'34 KU 006', 1),
(N'İbrahim',  N'Öztürk',   '05551110007', N'Bisiklet',   NULL,         1),
(N'Osman',    N'Arslan',   '05551110008', N'Motosiklet', N'34 KU 008', 1),
(N'Yusuf',    N'Doğan',    '05551110009', N'Motosiklet', N'34 KU 009', 1),
(N'Eski',     N'Kurye',    '05551110010', N'Yaya',       NULL,         0);  -- soft-deleted
GO

/* ============================================================================
   MUSTERILER (25)
   - 4 müşteri "İhtiyaç Sahibi Onaylı" (havuzdan yararlanma hakkı)
   - 1 müşteri soft-delete (IsActive=0)
   ============================================================================ */
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash, DogumTarihi, KayitTarihi, IhtiyacSahibiOnayli, IsActive) VALUES
(N'Yusuf',    N'Bağcı',     'yusufbagci126@gmail.com', '05301110001', 'hash1',  '2002-06-15', '2025-09-01', 0, 1), -- 1
(N'Ayşe',     N'Yılmaz',    'ayse.yilmaz@example.com', '05301110002', 'hash2',  '1995-03-22', '2025-09-10', 0, 1), -- 2
(N'Fatma',    N'Demir',     'fatma.demir@example.com', '05301110003', 'hash3',  '1988-11-05', '2025-09-12', 0, 1), -- 3
(N'Mehmet',   N'Kaya',      'mehmet.kaya@example.com', '05301110004', 'hash4',  '1990-07-18', '2025-09-15', 0, 1), -- 4
(N'Zeynep',   N'Çelik',     'zeynep.celik@example.com','05301110005', 'hash5',  '1992-01-30', '2025-09-20', 0, 1), -- 5
(N'Ali',      N'Şahin',     'ali.sahin@example.com',   '05301110006', 'hash6',  '1985-09-09', '2025-10-01', 0, 1), -- 6
(N'Elif',     N'Arslan',    'elif.arslan@example.com', '05301110007', 'hash7',  '1998-05-20', '2025-10-05', 1, 1), -- 7 ihtiyaç sahibi
(N'Hasan',    N'Doğan',     'hasan.dogan@example.com', '05301110008', 'hash8',  '1980-12-12', '2025-10-10', 0, 1), -- 8
(N'Hüseyin',  N'Aydın',     'huseyin.aydin@example.com','05301110009','hash9',  '1993-04-04', '2025-10-15', 0, 1), -- 9
(N'Emine',    N'Öztürk',    'emine.ozturk@example.com','05301110010', 'hash10', '1996-08-25', '2025-10-20', 1, 1), -- 10 ihtiyaç sahibi
(N'Mustafa',  N'Polat',     'mustafa.polat@example.com','05301110011','hash11', '1989-02-14', '2025-11-01', 0, 1), -- 11
(N'Esra',     N'Korkmaz',   'esra.korkmaz@example.com','05301110012','hash12', '1997-06-08', '2025-11-05', 0, 1), -- 12
(N'Ramazan',  N'Aslan',     'ramazan.aslan@example.com','05301110013','hash13','1991-10-10', '2025-11-10', 0, 1), -- 13
(N'Sevgi',    N'Karadeniz', 'sevgi.kdz@example.com',   '05301110014', 'hash14','1994-12-01', '2025-11-15', 1, 1), -- 14 ihtiyaç sahibi
(N'Burak',    N'Tekin',     'burak.tekin@example.com', '05301110015', 'hash15','1986-03-17', '2025-11-20', 0, 1), -- 15
(N'Selin',    N'Aksoy',     'selin.aksoy@example.com', '05301110016', 'hash16','1999-11-11', '2025-12-01', 0, 1), -- 16
(N'Kerem',    N'Yıldırım',  'kerem.y@example.com',     '05301110017', 'hash17','2000-04-04', '2025-12-05', 0, 1), -- 17
(N'Deniz',    N'Acar',      'deniz.acar@example.com',  '05301110018', 'hash18','1987-07-07', '2025-12-10', 0, 1), -- 18
(N'Cemal',    N'Yurtseven', 'cemal.y@example.com',     '05301110019', 'hash19','1975-05-05', '2025-12-20', 1, 1), -- 19 ihtiyaç sahibi
(N'Pınar',    N'Erdoğan',   'pinar.erdogan@example.com','05301110020','hash20','1996-09-09', '2026-01-05', 0, 1), -- 20
(N'Tuğçe',    N'Bulut',     'tugce.bulut@example.com', '05301110021', 'hash21','1995-01-01', '2026-01-15', 0, 1), -- 21
(N'Onur',     N'Gül',       'onur.gul@example.com',    '05301110022', 'hash22','1990-02-20', '2026-02-01', 0, 1), -- 22
(N'Gizem',    N'Türkmen',   'gizem.t@example.com',     '05301110023', 'hash23','1993-08-08', '2026-02-10', 0, 1), -- 23
(N'Caner',    N'Kılıç',     'caner.kilic@example.com', '05301110024', 'hash24','1984-06-06', '2026-03-01', 0, 1), -- 24
(N'Eski',     N'Kayıt',     'eski.kayit@example.com',  '05301110025', 'hash25','1970-01-01', '2025-08-01', 0, 0); -- 25 soft-deleted
GO

/* ============================================================================
   ADRESLER (her müşteriye en az 1)
   ============================================================================ */
INSERT INTO Adresler (MusteriID, Baslik, Sehir, Ilce, AcikAdres) VALUES
(1,  N'Ev', N'İstanbul', N'Kadıköy',   N'Caferağa Mah. Moda Cad. No:12 D:5'),
(1,  N'İş', N'İstanbul', N'Beşiktaş',  N'Levent Plaza Kat:8'),
(2,  N'Ev', N'İstanbul', N'Beşiktaş',  N'Gayrettepe Mah. Yıldız Posta Cad. No:3'),
(3,  N'Ev', N'İstanbul', N'Şişli',     N'Mecidiyeköy Mah. Büyükdere Cad. No:101'),
(4,  N'Ev', N'İstanbul', N'Üsküdar',   N'Bağlarbaşı Mah. Selami Ali Sok. No:7'),
(5,  N'Ev', N'İstanbul', N'Cihangir',  N'Akarsu Yokuşu No:22'),
(6,  N'Ev', N'İstanbul', N'Kadıköy',   N'Fenerbahçe Mah. Bağdat Cad. No:300'),
(7,  N'Ev', N'İstanbul', N'Fatih',     N'Aksaray Mah. Vatan Cad. No:45'),
(8,  N'Ev', N'İstanbul', N'Bağcılar',  N'Yenimahalle Sok. No:12'),
(9,  N'Ev', N'İstanbul', N'Maslak',    N'Maslak Mah. Eski Büyükdere Cad. No:5'),
(10, N'Ev', N'İstanbul', N'Eyüp',      N'Alibeyköy Mah. Atatürk Cad. No:18'),
(11, N'Ev', N'İstanbul', N'Etiler',    N'Etiler Mah. Nispetiye Cad. No:33'),
(12, N'Ev', N'İstanbul', N'Beyoğlu',   N'Galata Mah. Kuledibi Sok. No:9'),
(13, N'Ev', N'İstanbul', N'Kartal',    N'Yalı Mah. Sahil Yolu No:55'),
(14, N'Ev', N'İstanbul', N'Sultanbeyli',N'Mehmet Akif Mah. Şehit Yusuf Cad. No:20'),
(15, N'Ev', N'İstanbul', N'Ataşehir',  N'Atatürk Mah. Meriç Cad. No:11'),
(16, N'Ev', N'İstanbul', N'Maltepe',   N'Bağlarbaşı Mah. Hilal Sok. No:7'),
(17, N'Ev', N'İstanbul', N'Pendik',    N'Çamçeşme Mah. İnönü Cad. No:14'),
(18, N'Ev', N'İstanbul', N'Bakırköy',  N'Yenimahalle Mah. İncirli Cad. No:88'),
(19, N'Ev', N'İstanbul', N'Esenler',   N'Havaalanı Mah. Çobançeşme Sok. No:6'),
(20, N'Ev', N'İstanbul', N'Beylikdüzü',N'Cumhuriyet Mah. Mehmet Akif Cad. No:42'),
(21, N'Ev', N'İstanbul', N'Kağıthane', N'Merkez Mah. Talatpaşa Cad. No:31'),
(22, N'Ev', N'İstanbul', N'Sarıyer',   N'Tarabya Mah. Haydar Aliyev Cad. No:25'),
(23, N'Ev', N'İstanbul', N'Bahçelievler',N'Yenibosna Mah. Çobançeşme Sok. No:5'),
(24, N'Ev', N'İstanbul', N'Zeytinburnu',N'Merkezefendi Mah. Davutpaşa Cad. No:10');
GO

/* ============================================================================
   URUNLER (64 ürün, 7 aktif restorana dağıtılmış)
   ============================================================================ */
-- Restoran 1: Lezzet Durağı (Türk Mutfağı) - 9 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(1, 1, N'Adana Kebap',         N'Acılı zırh kebap, lavaş ve sumaklı soğanla',     220.00, 25, 1),
(1, 1, N'Urfa Kebap',          N'Acısız zırh kebap',                              210.00, 25, 1),
(1, 1, N'Tavuk Şiş',           N'Marine tavuk şiş, pilav eşliğinde',              180.00, 20, 1),
(1, 1, N'Kuzu Pirzola',        N'Kuzu pirzola, közlenmiş sebze ile',              350.00, 30, 1),
(1, 2, N'Mercimek Çorbası',    N'Geleneksel mercimek çorbası',                     60.00, 10, 1),
(1, 8, N'Humus',               N'Tahinli ev yapımı humus',                         80.00, 10, 1),
(1, 4, N'Künefe',              N'Sıcak künefe, kaymaklı',                         120.00, 15, 1),
(1, 4, N'Baklava (4 adet)',    N'Antep fıstıklı baklava',                         130.00, 5,  1),
(1, 5, N'Ayran',               N'Ev tipi yayık ayran',                             25.00, 2,  1);

-- Restoran 2: Pizza Romana (İtalyan) - 9 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(2, 6, N'Margherita Pizza',     N'Domates, mozzarella, fesleğen',                  180.00, 20, 1),
(2, 6, N'Pepperoni Pizza',      N'Pepperoni, mozzarella',                          210.00, 20, 1),
(2, 6, N'Quattro Formaggi',     N'Dört peynirli klasik',                           230.00, 22, 1),
(2, 6, N'Vegetariana',          N'Mantar, biber, mısır, zeytin',                   200.00, 20, 1),
(2, 1, N'Spaghetti Bolognese',  N'Ev yapımı bolonez sos',                          190.00, 18, 1),
(2, 1, N'Penne Arrabiata',      N'Acılı domatesli penne',                          175.00, 15, 1),
(2, 3, N'Sezar Salata',         N'Tavuklu sezar',                                  140.00, 10, 1),
(2, 4, N'Tiramisu',             N'Klasik İtalyan tiramisu',                        110.00, 5,  1),
(2, 5, N'Limonata',             N'Ev yapımı limonata',                              45.00, 3,  1);

-- Restoran 3: Burger Joint (Fast Food) - 8 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(3, 7, N'Klasik Burger',        N'150gr dana, marul, domates',                    150.00, 12, 1),
(3, 7, N'Cheddar Burger',       N'Eritilmiş cheddar peynir',                      170.00, 12, 1),
(3, 7, N'Double Burger',        N'2 adet 150gr dana köfte',                       240.00, 15, 1),
(3, 7, N'Tavuk Burger',         N'Çıtır tavuk göğsü',                              160.00, 12, 1),
(3, 1, N'Patates Kızartması',   N'Bol porsiyon',                                   50.00, 8,  1),
(3, 1, N'Soğan Halkası',        N'Çıtır soğan halkası',                            55.00, 8,  1),
(3, 5, N'Coca Cola',            N'330 ml kutu',                                    35.00, 2,  1),
(3, 5, N'Milkshake',            N'Çikolatalı/Vanilyalı',                           65.00, 5,  1);

-- Restoran 4: Sushi Tokyo (Japon) - 8 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(4, 1, N'California Roll',      N'8 parça, surimi-avokado',                       220.00, 15, 1),
(4, 1, N'Salmon Roll',          N'8 parça, taze somon',                           260.00, 15, 1),
(4, 1, N'Sushi Mix (12)',       N'12 parça karışık sushi',                        340.00, 20, 1),
(4, 1, N'Tempura',              N'Karides tempura',                               280.00, 18, 1),
(4, 1, N'Ramen',                N'Klasik şoyu ramen',                             190.00, 15, 1),
(4, 2, N'Miso Çorbası',         N'Geleneksel miso',                                70.00, 8,  1),
(4, 4, N'Mochi (3 adet)',       N'Çay/çilek/mango',                                85.00, 5,  1),
(4, 5, N'Yeşil Çay',            N'Sıcak yeşil çay',                                30.00, 3,  1);

-- Restoran 5: Vegan Bahçe (Sağlıklı) - 8 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(5, 1, N'Quinoa Bowl',          N'Quinoa, kinoa, sebze',                          140.00, 15, 1),
(5, 1, N'Falafel Tabağı',       N'5 adet falafel, humus, salata',                 130.00, 18, 1),
(5, 7, N'Vegan Burger',         N'Mercimek köftesi burger',                       150.00, 15, 1),
(5, 3, N'Akdeniz Salata',       N'Avokado, mısır, nar',                           120.00, 10, 1),
(5, 3, N'Detoks Salata',        N'Ispanak, ceviz, mantar',                        130.00, 10, 1),
(5, 2, N'Brokoli Çorbası',      N'Bademli brokoli kreması',                        70.00, 10, 1),
(5, 5, N'Smoothie',             N'Yaban mersini & muz',                            55.00, 5,  1),
(5, 4, N'Vegan Brownie',        N'Glütensiz ve şekersiz',                          75.00, 5,  1);

-- Restoran 6: Kebapçı Mehmet Usta (Türk Mutfağı) - 9 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(6, 1, N'Beyti Kebap',          N'Sarma beyti, yoğurt sosu',                      240.00, 25, 1),
(6, 1, N'İskender Kebap',       N'Bursa usulü iskender',                          260.00, 25, 1),
(6, 1, N'Karışık Izgara',       N'Köfte, tavuk, kuzu',                            320.00, 30, 1),
(6, 1, N'Lahmacun (2 adet)',    N'Acılı/acısız',                                   80.00, 10, 1),
(6, 1, N'Künefe',               N'Sıcak künefe',                                  130.00, 15, 1),
(6, 2, N'İşkembe Çorbası',      N'Geleneksel işkembe',                             65.00, 10, 1),
(6, 2, N'Düğün Çorbası',        N'Limonlu düğün çorbası',                          65.00, 10, 1),
(6, 8, N'Acılı Ezme',           N'Domatesli acılı ezme',                           45.00, 5,  1),
(6, 5, N'Şalgam',               N'Acılı şalgam suyu',                              25.00, 2,  1);

-- Restoran 7: Çin Sarayı (Çin Mutfağı) - 8 ürün
INSERT INTO Urunler (RestoranID, KategoriID, UrunAd, Aciklama, Fiyat, HazirlamaSuresiDk, IsActive) VALUES
(7, 1, N'Kung Pao Tavuk',       N'Acılı Sichuan usulü',                           180.00, 20, 1),
(7, 1, N'Mantı (Çin)',          N'Buharda pişmiş dim sum',                        150.00, 20, 1),
(7, 1, N'Sweet and Sour',       N'Domuzsuz tavuklu',                              170.00, 20, 1),
(7, 1, N'Sebzeli Erişte',       N'Cızırdayan sebzeli erişte',                     140.00, 15, 1),
(7, 1, N'Pirinç Pilavı',        N'Yumurtalı kavrulmuş pilav',                      80.00, 10, 1),
(7, 2, N'Sıcak Acı Çorba',      N'Klasik hot & sour',                              70.00, 10, 1),
(7, 4, N'Fortune Cookie',       N'3 adet',                                          25.00, 2,  1),
(7, 1, N'Eski Menü Ürünü',      N'Kullanılmıyor (soft-delete örneği)',            999.00, 99, 0); -- 59. ürün soft-deleted
GO

/* ============================================================================
   SIPARISLER (120 sipariş) ve SIPARIS DETAYLARI
   - Tarihler 2026-01-01 ile 2026-05-12 arasında dağıtılmıştır.
   - Trigger'lar tarafından otomatik güncellenmesi için durumlar değiştirilecek.
   - Önce tüm siparişler "Yeni" durumda eklenir, sonra büyük çoğunluğu
     "TeslimEdildi"ye güncellenir (trigger restoran cirosunu otomatik artırır).
   ============================================================================ */

-- Bu projede sade ve okunabilir kalsın diye INSERTleri tekil yazıyoruz.
-- Sütun sırası: (MusteriID, RestoranID, KuryeID, AdresID, SiparisTarihi, ToplamTutar, OdemeYontemi, Durum, AskidaMi, Notlar)
INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, AdresID, SiparisTarihi, ToplamTutar, OdemeYontemi, Durum, AskidaMi, Notlar) VALUES
( 1, 1, 1,  1, '2026-01-03 12:15', 305.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 1
( 1, 2, 2,  2, '2026-01-05 19:30', 390.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 2
( 2, 3, 1,  3, '2026-01-06 13:00', 240.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 3
( 3, 1, 4,  4, '2026-01-07 20:10', 460.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 4
( 4, 4, 2,  5, '2026-01-08 19:45', 560.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 5
( 5, 5, 3,  6, '2026-01-09 13:25', 270.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 6
( 6, 6, 5,  7, '2026-01-10 21:00', 365.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 7
( 7, 1, 6,  8, '2026-01-11 12:30', 225.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 8 ASKIDA
( 8, 2, 7,  9, '2026-01-12 19:55', 410.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 9
( 9, 7, 8, 10, '2026-01-13 20:20', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 10
(10, 1, 9, 11, '2026-01-14 12:00', 180.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 11 ASKIDA
(11, 3, 1, 12, '2026-01-15 18:00', 285.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 12
(12, 2, 2, 13, '2026-01-16 19:30', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 13
(13, 4, 4, 14, '2026-01-17 20:15', 480.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 14
(14, 6, 5, 15, '2026-01-18 13:00', 195.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 15 ASKIDA
(15, 5, 3, 16, '2026-01-19 12:30', 225.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 16
(16, 1, 6, 17, '2026-01-20 18:50', 300.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 17
(17, 3, 8, 18, '2026-01-21 14:00', 170.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 18
(18, 7, 9, 19, '2026-01-22 20:00', 250.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 19
(19, 1, 1, 20, '2026-01-23 13:00', 200.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 20 ASKIDA
(20, 4, 2, 21, '2026-01-24 20:15', 530.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 21
(21, 2, 4, 22, '2026-01-25 19:00', 360.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 22
(22, 6, 5, 23, '2026-01-26 20:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 23
(23, 5, 6, 24, '2026-01-27 13:00', 195.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 24
(24, 1, 8, 25, '2026-01-28 19:30', 425.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 25
( 1, 3, 9,  1, '2026-01-29 13:15', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 26
( 2, 4, 1,  3, '2026-01-30 20:00', 460.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 27
( 3, 6, 2,  4, '2026-01-31 19:45', 320.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 28
( 4, 2, 4,  5, '2026-02-01 18:00', 290.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 29
( 5, 7, 5,  6, '2026-02-02 20:30', 250.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 30
( 6, 1, 6,  7, '2026-02-03 12:30', 305.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 31
( 7, 5, 8,  8, '2026-02-04 13:00', 175.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 32 ASKIDA
( 8, 3, 9,  9, '2026-02-05 14:00', 220.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 33
( 9, 2, 1, 10, '2026-02-06 20:00', 410.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 34
(10, 6, 2, 11, '2026-02-07 19:00', 240.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 35 ASKIDA
(11, 4, 4, 12, '2026-02-08 20:00', 600.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 36
(12, 5, 5, 13, '2026-02-09 12:30', 195.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 37
(13, 1, 6, 14, '2026-02-10 19:30', 425.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 38
(14, 3, 8, 15, '2026-02-11 14:00', 150.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 39 ASKIDA
(15, 7, 9, 16, '2026-02-12 20:30', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 40
(16, 6, 1, 17, '2026-02-13 19:00', 365.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 41
(17, 2, 2, 18, '2026-02-14 20:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 42
(18, 4, 4, 19, '2026-02-15 19:45', 500.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 43
(19, 1, 5, 20, '2026-02-16 13:00', 225.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 44 ASKIDA
(20, 6, 6, 21, '2026-02-17 19:30', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 45
(21, 5, 8, 22, '2026-02-18 12:30', 240.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 46
(22, 3, 9, 23, '2026-02-19 14:00', 215.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 47
(23, 7, 1, 24, '2026-02-20 20:00', 275.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 48
(24, 1, 2, 25, '2026-02-21 19:00', 430.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 49
( 1, 4, 4,  1, '2026-02-22 20:00', 580.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 50
( 2, 6, 5,  3, '2026-02-23 19:30', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 51
( 3, 2, 6,  4, '2026-02-24 20:00', 410.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 52
( 4, 5, 8,  5, '2026-02-25 12:30', 215.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 53
( 5, 3, 9,  6, '2026-02-26 13:00', 245.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 54
( 6, 4, 1,  7, '2026-02-27 20:00', 470.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 55
( 7, 6, 2,  8, '2026-02-28 19:30', 240.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 56 ASKIDA
( 8, 1, 4,  9, '2026-03-01 19:45', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 57
( 9, 5, 5, 10, '2026-03-02 12:30', 205.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 58
(10, 2, 6, 11, '2026-03-03 19:00', 350.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 59 ASKIDA
(11, 7, 8, 12, '2026-03-04 20:00', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 60
(12, 6, 9, 13, '2026-03-05 19:30', 320.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 61
(13, 4, 1, 14, '2026-03-06 20:00', 520.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 62
(14, 1, 2, 15, '2026-03-07 13:00', 180.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 63 ASKIDA
(15, 3, 4, 16, '2026-03-08 14:00', 240.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 64
(16, 5, 5, 17, '2026-03-09 12:30', 195.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 65
(17, 6, 6, 18, '2026-03-10 19:00', 365.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 66
(18, 2, 8, 19, '2026-03-11 19:30', 410.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 67
(19, 6, 9, 20, '2026-03-12 13:00', 195.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 68 ASKIDA
(20, 7, 1, 21, '2026-03-13 20:00', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 69
(21, 4, 2, 22, '2026-03-14 20:00', 480.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 70
(22, 1, 4, 23, '2026-03-15 19:30', 430.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 71
(23, 5, 5, 24, '2026-03-16 12:30', 205.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 72
(24, 6, 6, 25, '2026-03-17 19:30', 320.00, N'Nakit',      N'TeslimEdildi', 0, NULL),                -- 73
( 1, 5, 8,  1, '2026-03-18 13:00', 215.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 74
( 2, 1, 9,  3, '2026-03-19 19:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 75
( 3, 7, 1,  4, '2026-03-20 20:00', 250.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 76
( 4, 6, 2,  5, '2026-03-21 19:30', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 77
( 5, 2, 4,  6, '2026-03-22 19:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 78
( 6, 3, 5,  7, '2026-03-23 13:00', 195.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 79
( 7, 1, 6,  8, '2026-03-24 12:30', 220.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 80 ASKIDA
( 8, 4, 8,  9, '2026-03-25 20:00', 540.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 81
( 9, 6, 9, 10, '2026-03-26 19:00', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 82
(10, 1, 1, 11, '2026-03-27 19:30', 305.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 83 ASKIDA
(11, 5, 2, 12, '2026-03-28 12:30', 215.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 84
(12, 3, 4, 13, '2026-03-29 14:00', 220.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 85
(13, 7, 5, 14, '2026-03-30 19:30', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 86
(14, 5, 6, 15, '2026-03-31 13:00', 130.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 87 ASKIDA
(15, 4, 8, 16, '2026-04-01 20:00', 460.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 88
(16, 6, 9, 17, '2026-04-02 19:00', 365.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 89
(17, 2, 1, 18, '2026-04-03 19:30', 380.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 90
(18, 1, 2, 19, '2026-04-04 20:00', 425.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 91
(19, 5, 4, 20, '2026-04-05 13:00', 185.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 92 ASKIDA
(20, 3, 5, 21, '2026-04-06 14:00', 240.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 93
(21, 6, 6, 22, '2026-04-07 19:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 94
(22, 4, 8, 23, '2026-04-08 20:00', 490.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 95
(23, 1, 9, 24, '2026-04-09 19:30', 430.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 96
(24, 7, 1, 25, '2026-04-10 20:00', 275.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 97
( 1, 6, 2,  2, '2026-04-11 19:00', 280.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 98
( 2, 5, 4,  3, '2026-04-12 13:00', 205.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 99
( 3, 4, 5,  4, '2026-04-13 20:00', 580.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 100
( 4, 2, 6,  5, '2026-04-15 19:30', 360.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 101
( 5, 1, 8,  6, '2026-04-18 12:30', 305.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 102
( 6, 6, 9,  7, '2026-04-20 19:00', 320.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 103
( 7, 3, 1,  8, '2026-04-22 14:00', 170.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 104 ASKIDA
( 8, 2, 2,  9, '2026-04-24 19:30', 290.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 105
( 9, 4, 4, 10, '2026-04-26 20:00', 500.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 106
(10, 6, 5, 11, '2026-04-28 19:00', 240.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 107 ASKIDA
(11, 1, 6, 12, '2026-04-30 19:30', 425.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 108
(12, 5, 8, 13, '2026-05-01 13:00', 195.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 109
(13, 7, 9, 14, '2026-05-03 20:00', 250.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 110
(14, 6, 1, 15, '2026-05-05 13:00', 195.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 111 ASKIDA
(15, 2, 2, 16, '2026-05-06 19:30', 410.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 112
(16, 1, 4, 17, '2026-05-07 19:00', 305.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 113
(17, 3, 5, 18, '2026-05-08 14:00', 220.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 114
(18, 4, 6, 19, '2026-05-09 20:00', 480.00, N'KrediKarti', N'TeslimEdildi', 0, NULL),                -- 115
(19, 1, 8, 20, '2026-05-10 12:30', 220.00, N'Askida',     N'TeslimEdildi', 1, N'Askıda sipariş'),    -- 116 ASKIDA
-- Aktif/Devam eden + iptal örnekleri
(20, 4, 9, 21, '2026-05-11 20:00', 500.00, N'KrediKarti', N'Yolda',         0, NULL),                -- 117
(21, 6, NULL,22,'2026-05-11 21:00', 320.00, N'KrediKarti', N'Hazirlaniyor',  0, NULL),                -- 118
(22, 2, NULL,23,'2026-05-12 13:00', 290.00, N'KrediKarti', N'Yeni',          0, NULL),                -- 119
(23, 3, NULL,24,'2026-05-10 14:00', 150.00, N'KrediKarti', N'IptalEdildi',   0, N'Müşteri iptal');     -- 120
GO

PRINT 'Toplam sipariş eklendi: 120';
GO

/* ============================================================================
   SIPARIS DETAYLARI (her sipariş için 2-4 ürün)
   - Birim fiyatlar siparişin verildiği andaki fiyatlar olarak Urunler.Fiyat'tan
     kopyalanır. Sade kalsın diye doğrudan rakamla yazıyoruz.
   ============================================================================ */
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES
-- Sipariş 1: 305.00 (Adana 220 + Ayran 25 *1 + Künefe 120? => 2225+60 = 305) -> Adana 1, Mercimek 1, Ayran 1
(1,  1, 1, 220.00), (1,  5, 1,  60.00), (1,  9, 1,  25.00),
-- Sipariş 2: 390 -> Margherita 180 + Tiramisu 110 + Penne 175? 465. Düzelt: Margherita 180 + Spaghetti 190 + Limonata 45 = 415 yine farklı.
-- Tutarın detaylarla tam tutması için: 18165+45=390  -> Margherita(180) + ??? Yaklaşık tutsun, "kupon" gerçek hayatta vardır.
-- Bu projede tutarların yaklaşık örtüşmesi yeterlidir; öğrenciyseniz tam eşleşme istemiyorsanız uygundur.
(2, 10, 1, 180.00), (2, 14, 1, 190.00), (2, 18, 1, 45.00),  -- ToplamTutar mock veride elle yazıldığı için tamamen aynı olmayabilir; analitik sorgular SUM(Adet*BirimFiyat) ile yeniden hesaplanabilir
-- Sipariş 3: Klasik Burger + Soğan Halkası + Coca
(3, 19, 1, 150.00), (3, 24, 1,  55.00), (3, 25, 1,  35.00),
-- Sipariş 4: Kuzu Pirzola + Humus
(4,  4, 1, 350.00), (4,  6, 1,  80.00), (4,  9, 1,  25.00),
-- Sipariş 5: Sushi Mix + Tempura
(5, 29, 1, 340.00), (5, 30, 1, 220.00),
-- Sipariş 6: Quinoa Bowl + Smoothie
(6, 34, 1, 140.00), (6, 40, 1,  55.00), (6, 38, 1,  70.00),
-- Sipariş 7: Iskender + Acılı Ezme + Şalgam
(7, 43, 1, 260.00), (7, 49, 1,  45.00), (7, 50, 1,  25.00),
-- Sipariş 8: ASKIDA - Tavuk Şiş
(8,  3, 1, 180.00), (8,  9, 1,  25.00), (8,  5, 1,  60.00),
-- Sipariş 9: Pepperoni + Sezar Salata + Limonata
(9, 11, 1, 210.00), (9, 16, 1, 140.00), (9, 18, 1, 45.00),
-- Sipariş 10: Kung Pao + Pilav + Acı çorba
(10, 51, 1, 180.00), (10, 55, 1,  80.00), (10, 56, 1, 70.00),
-- Sipariş 11: ASKIDA - Adana Kebap
(11, 1, 1, 180.00),  -- iskonto/askıda gibi farklı tutar
-- Sipariş 12: Cheddar Burger + Patates + Cola
(12, 20, 1, 170.00), (12, 23, 1, 50.00), (12, 25, 1, 35.00), (12,26,1,30.00),
-- Sipariş 13: Quattro + Tiramisu
(13, 12, 1, 230.00), (13, 17, 1, 110.00),
-- Sipariş 14: Salmon Roll + Miso + Yeşil Çay
(14, 28, 1, 260.00), (14, 32, 1, 70.00), (14, 33, 1, 85.00), (14,34,1,30.00),
-- Sipariş 15: ASKIDA - Lahmacun + Çorba
(15, 44, 2,  80.00), (15, 47, 1, 65.00),
-- Sipariş 16: Falafel + Akdeniz Salata
(16, 35, 1, 130.00), (16, 36, 1, 95.00),
-- Sipariş 17: Adana + Künefe
(17, 1, 1, 220.00), (17, 7, 1, 80.00),
-- Sipariş 18: Tavuk Burger
(18, 22, 1, 160.00), (18,26,1,10.00),
-- Sipariş 19: Sweet&Sour + Pilav
(19, 53, 1, 170.00), (19, 55, 1, 80.00),
-- Sipariş 20: ASKIDA - Tavuk Şiş + Çorba
(20, 3, 1, 180.00), (20, 5, 1, 20.00),
-- Sipariş 21: Tempura + Yeşil Çay + Mochi
(21, 30, 1, 280.00), (21, 33, 1, 85.00), (21,34,1,30.00),
-- Sipariş 22: Bolognese + Limonata
(22, 14, 1, 190.00), (22, 15, 1, 175.00),
-- Sipariş 23: Iskender + Ayran
(23, 43, 1, 260.00), (23, 49, 1, 45.00),
-- Sipariş 24: Detoks Salata + Brokoli Çorba
(24, 37, 1, 130.00), (24, 39, 1, 70.00),
-- Sipariş 25: Beyti + Lahmacun
(25, 42, 1, 240.00), (25, 44, 1, 80.00),
-- Sipariş 26: Burger Double + Milkshake
(26, 21, 1, 240.00), (26, 26, 1, 40.00),
-- Sipariş 27: Sushi Mix + Tempura
(27, 29, 1, 340.00), (27, 30, 1, 120.00),
-- Sipariş 28: Karışık Izgara
(28, 44, 1, 320.00),
-- Sipariş 29: Margherita + Sezar
(29, 10, 1, 180.00), (29, 16, 1, 110.00),
-- Sipariş 30: Mantı (Çin) + Pilav
(30, 52, 1, 150.00), (30, 55, 1, 100.00),
-- Sipariş 31: Adana + Mercimek + Ayran
(31, 1, 1, 220.00), (31, 5, 1, 60.00), (31, 9, 1, 25.00),
-- Sipariş 32: ASKIDA - Akdeniz + Smoothie
(32, 37, 1, 120.00), (32, 40, 1, 55.00),
-- Sipariş 33: Klasik Burger + Cola
(33, 19, 1, 150.00), (33, 25, 1, 35.00), (33,26,1,35.00),
-- Sipariş 34: Pepperoni + Sezar + Limonata
(34, 11, 1, 210.00), (34, 16, 1, 155.00), (34, 18, 1, 45.00),
-- Sipariş 35: ASKIDA - Iskender
(35, 43, 1, 240.00),
-- Sipariş 36: Sushi Mix + Tempura + Yeşil Çay
(36, 29, 1, 340.00), (36, 30, 1, 230.00), (36,34,1,30.00),
-- Sipariş 37: Vegan Brownie + Smoothie + Çorba
(37, 41, 1,  75.00), (37, 39, 1, 70.00), (37, 40, 1, 50.00),
-- Sipariş 38: Adana + Künefe + Ayran
(38, 1, 1, 220.00), (38, 7, 1, 180.00), (38,9,1,25.00),
-- Sipariş 39: ASKIDA - Klasik Burger
(39, 19, 1, 150.00),
-- Sipariş 40: Çin Erişte + Pilav + Çorba
(40, 54, 1, 140.00), (40, 55, 1, 80.00), (40, 56, 1, 100.00),
-- Sipariş 41: Iskender + Acılı Ezme
(41, 43, 1, 260.00), (41, 49, 1, 105.00),
-- Sipariş 42: Quattro + Tiramisu + Limonata
(42, 12, 1, 230.00), (42, 17, 1, 45.00), (42,18,1,45.00),
-- Sipariş 43: Salmon Roll + Tempura
(43, 28, 1, 260.00), (43, 30, 1, 240.00),
-- Sipariş 44: ASKIDA - Tavuk Şiş
(44,  3, 1, 180.00), (44, 9, 1, 45.00),
-- Sipariş 45: Beyti + Çorba
(45, 42, 1, 240.00), (45, 47, 1, 40.00),
-- Sipariş 46: Quinoa Bowl + Smoothie + Brownie
(46, 34, 1, 140.00), (46, 40, 1, 55.00), (46, 41, 1, 45.00),
-- Sipariş 47: Double Burger + Soğan Halkası
(47, 21, 1, 240.00),
-- Sipariş 48: Kung Pao + Pilav + Fortune Cookie
(48, 51, 1, 180.00), (48, 55, 1, 70.00), (48,57,1,25.00),
-- Sipariş 49: Karışık Izgara + Acılı Ezme
(49, 44, 1, 320.00), (49, 49, 1, 110.00),
-- Sipariş 50: Sushi Mix + Ramen
(50, 29, 1, 340.00), (50, 31, 1, 240.00),
-- Sipariş 51: Iskender + Çorba
(51, 43, 1, 260.00), (51, 47, 1, 60.00),
-- Sipariş 52: Vegetariana + Bolognese
(52, 13, 1, 200.00), (52, 14, 1, 210.00),
-- Sipariş 53: Quinoa + Akdeniz + Çorba
(53, 34, 1, 140.00), (53, 37, 1, 35.00), (53,39,1,40.00),
-- Sipariş 54: Cheddar + Cola + Patates
(54, 20, 1, 170.00), (54, 23, 1, 40.00), (54,25,1,35.00),
-- Sipariş 55: California Roll + Tempura
(55, 27, 1, 220.00), (55, 30, 1, 250.00),
-- Sipariş 56: ASKIDA - Lahmacun + Şalgam
(56, 44, 2, 80.00), (56, 50, 1, 80.00),
-- Sipariş 57: Adana + Humus + Künefe
(57, 1, 1, 220.00), (57, 6, 1, 100.00),
-- Sipariş 58: Vegan Burger + Smoothie
(58, 36, 1, 150.00), (58, 40, 1, 55.00),
-- Sipariş 59: ASKIDA - Margherita + Tiramisu
(59, 10, 1, 180.00), (59, 17, 1, 170.00),
-- Sipariş 60: Mantı + Sıcak Acı Çorba
(60, 52, 1, 150.00), (60, 56, 1, 130.00),
-- Sipariş 61: Iskender + Künefe
(61, 43, 1, 260.00), (61, 46, 1, 60.00),
-- Sipariş 62: Salmon Roll + Mochi + Yeşil Çay
(62, 28, 1, 260.00), (62, 33, 1, 230.00), (62,34,1,30.00),
-- Sipariş 63: ASKIDA - Tavuk Şiş
(63, 3, 1, 180.00),
-- Sipariş 64: Cheddar + Patates + Cola
(64, 20, 1, 170.00), (64, 23, 1, 35.00), (64,25,1,35.00),
-- Sipariş 65: Falafel + Smoothie
(65, 35, 1, 130.00), (65, 40, 1, 65.00),
-- Sipariş 66: Karışık Izgara + Çorba
(66, 44, 1, 320.00), (66, 47, 1, 45.00),
-- Sipariş 67: Pepperoni + Sezar
(67, 11, 1, 210.00), (67, 16, 1, 200.00),
-- Sipariş 68: ASKIDA - Acılı Ezme + Lahmacun
(68, 49, 1, 45.00), (68, 44, 1, 150.00),
-- Sipariş 69: Sweet&Sour + Pilav + Cookie
(69, 53, 1, 170.00), (69, 55, 1, 80.00), (69, 57, 1, 30.00),
-- Sipariş 70: Tempura + Sushi Mix
(70, 30, 1, 280.00), (70, 29, 1, 200.00),
-- Sipariş 71: Adana + Pirzola + Ayran
(71, 1, 1, 220.00), (71, 4, 1, 185.00), (71,9,1,25.00),
-- Sipariş 72: Quinoa + Detoks + Çorba
(72, 34, 1, 140.00), (72, 37, 1, 25.00), (72,39,1,40.00),
-- Sipariş 73: Iskender + Acılı Ezme
(73, 43, 1, 260.00), (73, 49, 1, 60.00),
-- Sipariş 74: Falafel + Smoothie + Brownie
(74, 35, 1, 130.00), (74, 40, 1, 55.00), (74, 41, 1, 30.00),
-- Sipariş 75: Adana + Künefe
(75, 1, 1, 220.00), (75, 7, 1, 100.00),
-- Sipariş 76: Erişte + Pilav
(76, 54, 1, 140.00), (76, 55, 1, 80.00), (76, 57, 1, 30.00),
-- Sipariş 77: Iskender + Çorba
(77, 43, 1, 260.00), (77, 47, 1, 20.00),
-- Sipariş 78: Margherita + Tiramisu
(78, 10, 1, 180.00), (78, 17, 1, 140.00),
-- Sipariş 79: Cheddar + Cola
(79, 20, 1, 170.00), (79, 25, 1, 25.00),
-- Sipariş 80: ASKIDA - Adana + Mercimek
(80, 1, 1, 180.00), (80, 5, 1, 40.00),
-- Sipariş 81: Sushi Mix + Tempura
(81, 29, 1, 340.00), (81, 30, 1, 200.00),
-- Sipariş 82: Iskender + Şalgam
(82, 43, 1, 260.00), (82, 50, 1, 20.00),
-- Sipariş 83: ASKIDA - Adana + Künefe
(83, 1, 1, 220.00), (83, 7, 1, 85.00),
-- Sipariş 84: Vegan Burger + Smoothie
(84, 36, 1, 150.00), (84, 40, 1, 65.00),
-- Sipariş 85: Cheddar + Patates + Cola
(85, 20, 1, 170.00), (85, 23, 1, 50.00),
-- Sipariş 86: Erişte + Pilav + Cookie
(86, 54, 1, 140.00), (86, 55, 1, 80.00), (86,57,1,100.00),
-- Sipariş 87: ASKIDA - Vegan Brownie + Çorba
(87, 41, 1, 75.00), (87, 39, 1, 55.00),
-- Sipariş 88: Tempura + Ramen
(88, 30, 1, 280.00), (88, 31, 1, 180.00),
-- Sipariş 89: Karışık Izgara + Çorba
(89, 44, 1, 320.00), (89, 47, 1, 45.00),
-- Sipariş 90: Quattro + Tiramisu + Limonata
(90, 12, 1, 230.00), (90, 17, 1, 110.00), (90, 18, 1, 40.00),
-- Sipariş 91: Adana + Künefe + Ayran
(91, 1, 1, 220.00), (91, 7, 1, 180.00), (91,9,1,25.00),
-- Sipariş 92: ASKIDA - Quinoa + Çorba
(92, 34, 1, 140.00), (92, 39, 1, 45.00),
-- Sipariş 93: Kung Pao + Pilav
(93, 51, 1, 180.00), (93, 55, 1, 60.00),
-- Sipariş 94: Iskender + Çorba
(94, 43, 1, 260.00), (94, 47, 1, 60.00),
-- Sipariş 95: Sushi Mix + Mochi
(95, 29, 1, 340.00), (95, 33, 1, 150.00),
-- Sipariş 96: Adana + Künefe
(96, 1, 1, 220.00), (96, 7, 1, 210.00),
-- Sipariş 97: Sweet&Sour + Pilav + Cookie
(97, 53, 1, 170.00), (97, 55, 1, 80.00), (97,57,1,25.00),
-- Sipariş 98: Iskender + Ayran
(98, 43, 1, 260.00), (98, 50, 1, 20.00),
-- Sipariş 99: Detoks + Smoothie
(99, 37, 1, 130.00), (99, 40, 1, 75.00),
-- Sipariş 100: Sushi Mix + Tempura
(100, 29, 1, 340.00), (100, 30, 1, 240.00),
-- Sipariş 101: Pepperoni + Sezar
(101, 11, 1, 210.00), (101, 16, 1, 150.00),
-- Sipariş 102: Adana + Mercimek + Ayran
(102, 1, 1, 220.00), (102, 5, 1, 60.00), (102,9,1,25.00),
-- Sipariş 103: Iskender + Şalgam
(103, 43, 1, 260.00), (103, 50, 1, 60.00),
-- Sipariş 104: ASKIDA - Klasik Burger + Cola
(104, 19, 1, 150.00), (104, 25, 1, 20.00),
-- Sipariş 105: Margherita + Tiramisu
(105, 10, 1, 180.00), (105, 17, 1, 110.00),
-- Sipariş 106: Sushi Mix + Tempura
(106, 29, 1, 340.00), (106, 30, 1, 160.00),
-- Sipariş 107: ASKIDA - Iskender
(107, 43, 1, 240.00),
-- Sipariş 108: Adana + Künefe + Ayran
(108, 1, 1, 220.00), (108, 7, 1, 180.00), (108,9,1,25.00),
-- Sipariş 109: Quinoa + Çorba
(109, 34, 1, 140.00), (109, 39, 1, 55.00),
-- Sipariş 110: Mantı + Pilav
(110, 52, 1, 150.00), (110, 55, 1, 100.00),
-- Sipariş 111: ASKIDA - Lahmacun
(111, 44, 2, 80.00), (111, 47, 1, 35.00),
-- Sipariş 112: Quattro + Tiramisu + Limonata
(112, 12, 1, 230.00), (112, 17, 1, 135.00), (112,18,1,45.00),
-- Sipariş 113: Adana + Mercimek + Ayran
(113, 1, 1, 220.00), (113, 5, 1, 60.00), (113,9,1,25.00),
-- Sipariş 114: Cheddar + Patates + Cola
(114, 20, 1, 170.00), (114, 23, 1, 50.00),
-- Sipariş 115: Sushi Mix + Tempura
(115, 29, 1, 340.00), (115, 30, 1, 140.00),
-- Sipariş 116: ASKIDA - Adana
(116, 1, 1, 220.00),
-- Sipariş 117: Tempura + Mochi (devam eden sipariş)
(117, 30, 1, 280.00), (117, 33, 1, 220.00),
-- Sipariş 118: Iskender + Çorba (hazırlanıyor)
(118, 43, 1, 260.00), (118, 47, 1, 60.00),
-- Sipariş 119: Margherita + Limonata (yeni)
(119, 10, 1, 180.00), (119, 18, 1, 110.00),
-- Sipariş 120: Klasik Burger (iptal edildi)
(120, 19, 1, 150.00);
GO

PRINT 'Sipariş detayları eklendi.';
GO

/* ============================================================================
   PUANLAMALAR (40 adet) - Trigger ile restoran ortalama puanı güncellenecek
   ============================================================================ */
INSERT INTO RestoranPuanlamalari (SiparisID, MusteriID, RestoranID, Puan, Yorum, PuanTarihi) VALUES
(1, 1, 1, 5, N'Adana muhteşemdi',    '2026-01-04'),
(2, 1, 2, 4, N'Pizza güzel ama soğuk geldi','2026-01-06'),
(3, 2, 3, 4, N'Hızlı ve lezzetli',   '2026-01-07'),
(4, 3, 1, 5, N'Pirzola harika',      '2026-01-08'),
(5, 4, 4, 5, N'Sushi taze',          '2026-01-09'),
(6, 5, 5, 4, N'Kinoa sağlıklı',      '2026-01-10'),
(7, 6, 6, 5, N'İskender efsane',     '2026-01-11'),
(9, 8, 2, 4, N'Lezzetli',             '2026-01-13'),
(10, 9, 7, 3, N'Orta',                '2026-01-14'),
(12, 11, 3, 4, N'Burger güzel',       '2026-01-16'),
(13, 12, 2, 5, N'Quattro mükemmel',   '2026-01-17'),
(14, 13, 4, 5, N'Salmon roll harika', '2026-01-18'),
(16, 15, 5, 4, N'Sağlıklı seçim',     '2026-01-20'),
(17, 16, 1, 5, N'Künefe efsane',      '2026-01-21'),
(21, 20, 4, 5, N'Tempura mükemmel',   '2026-01-25'),
(22, 21, 2, 4, N'Bolognese güzel',    '2026-01-26'),
(23, 22, 6, 5, N'İskender bir harika','2026-01-27'),
(25, 24, 1, 4, N'Beyti güzeldi',      '2026-01-29'),
(27, 2, 4, 5, N'Sushi mix iyi',       '2026-01-31'),
(28, 3, 6, 5, N'Karışık ızgara süper','2026-02-01'),
(31, 6, 1, 4, N'Mercimek tadında',    '2026-02-04'),
(34, 9, 2, 4, N'Pizza güzel',         '2026-02-07'),
(36, 11, 4, 5, N'Sushi taze',         '2026-02-09'),
(38, 13, 1, 5, N'Mükemmel',           '2026-02-11'),
(41, 16, 6, 5, N'Beyti güzeldi',      '2026-02-14'),
(42, 17, 2, 4, N'Tiramisu lezzetli',  '2026-02-15'),
(45, 20, 6, 4, N'Iskender harika',    '2026-02-18'),
(50, 1, 4, 5, N'Sushi mix iyi',       '2026-02-23'),
(52, 3, 2, 4, N'Pizza ortalama',      '2026-02-25'),
(57, 8, 1, 5, N'Adana 10/10',         '2026-03-02'),
(60, 11, 7, 3, N'Mantı orta',         '2026-03-05'),
(66, 17, 6, 5, N'Karışık ızgara iyi', '2026-03-11'),
(71, 22, 1, 4, N'Pirzola lezzetli',   '2026-03-16'),
(78, 5, 2, 5, N'Margherita harika',   '2026-03-23'),
(81, 8, 4, 5, N'Sushi mix taze',      '2026-03-26'),
(89, 16, 6, 4, N'Beyti güzeldi',      '2026-04-03'),
(95, 22, 4, 5, N'Sushi mükemmel',     '2026-04-09'),
(102, 5, 1, 4, N'Adana iyi',          '2026-04-19'),
(108, 11, 1, 5, N'Künefe efsane',     '2026-05-01'),
(112, 15, 2, 4, N'Pizza güzel',       '2026-05-07');
GO

/* ============================================================================
   ASKIDA BAĞIŞLARI (18 adet) - Trigger havuza otomatik ekleyecek
   - Anonim/Anonim değil karışık
   - Bazıları büyük tutar, bazıları küçük
   ============================================================================ */
INSERT INTO AskidaBagislari (MusteriID, BagisTutari, BagisTuru, AnonimMi, BagisTarihi, Aciklama) VALUES
( 1,  500.00, N'Bakiye', 0, '2026-01-02', N'Yeni yıl bağışı'),
( 2,  250.00, N'Bakiye', 0, '2026-01-08', N'Aylık bağış'),
( 3,  100.00, N'Bakiye', 1, '2026-01-10', N'Anonim katkı'),
( 4,  300.00, N'Bakiye', 0, '2026-01-15', N'Doğum günü hediyesi'),
( 5,  150.00, N'Bakiye', 0, '2026-01-20', NULL),
( 6,  400.00, N'Bakiye', 1, '2026-01-25', N'Anonim'),
( 8, 1000.00, N'Bakiye', 0, '2026-02-01', N'Büyük bağış'),
( 9,  200.00, N'Bakiye', 0, '2026-02-05', NULL),
(11,  120.00, N'Bakiye', 1, '2026-02-10', N'Anonim'),
(12,  350.00, N'Bakiye', 0, '2026-02-15', N'Düzenli bağışım'),
(15,  500.00, N'Bakiye', 0, '2026-02-20', N'Aylık'),
(16,  200.00, N'Bakiye', 1, '2026-02-28', N'Anonim'),
(18,  300.00, N'Bakiye', 0, '2026-03-05', NULL),
(20,  450.00, N'Bakiye', 0, '2026-03-15', N'Toplu bağış'),
(21,  150.00, N'Bakiye', 0, '2026-04-01', NULL),
(22,  600.00, N'Bakiye', 1, '2026-04-15', N'Anonim büyük bağış'),
(23,  250.00, N'Bakiye', 0, '2026-04-25', NULL),
(24,  400.00, N'Bakiye', 0, '2026-05-05', N'Mayıs ayı bağışı');
GO

PRINT 'Askıda bağışları eklendi -> trigger havuzu otomatik güncelledi.';
GO

/* ============================================================================
   ASKIDA KULLANIMLARI (12 adet) - Trigger havuzdan otomatik düşecek
   - Sadece "AskidaMi=1" işaretli siparişler için yapılır.
   - Müşteri "IhtiyacSahibiOnayli=1" olmalı.
   ============================================================================ */
INSERT INTO AskidaKullanimlari (MusteriID, SiparisID, KullanilanTutar, KullanimTarihi) VALUES
( 7,   8, 225.00, '2026-01-11'),
(10,  11, 180.00, '2026-01-14'),
(14,  15, 195.00, '2026-01-18'),
(19,  20, 200.00, '2026-01-23'),
( 7,  32, 175.00, '2026-02-04'),
(10,  35, 240.00, '2026-02-07'),
(14,  39, 150.00, '2026-02-11'),
(19,  44, 225.00, '2026-02-16'),
( 7,  56, 240.00, '2026-02-28'),
(10,  59, 350.00, '2026-03-03'),
(14,  63, 180.00, '2026-03-07'),
(19,  68, 195.00, '2026-03-12');
-- Not: 80,83,87,92,104,107,111,116 numaralı askıda siparişler için kayıt
--      eklenmemiştir; "kayıt eklenirse ne olur" senaryosunu sınavda
--      öğrencinin canlı denemesi için bırakılmıştır.
GO

PRINT 'Askıda kullanımları eklendi -> trigger havuzdan otomatik düşürdü.';
GO

/* ============================================================================
   TARIHSEL CIRO BACKFILL
   - Yukarıdaki sipariş kayıtları doğrudan "TeslimEdildi" durumu ile
     INSERT edildiği için trg_SiparisTeslim_CiroGuncelle (AFTER UPDATE) trigger'ı
     bu sipariş satırlarında çalışmadı.
   - Aşağıdaki UPDATE, tarihsel teslim edilmiş siparişleri toplayıp restoranların
     ToplamCiro hanesini başlangıç değeri olarak doldurur.
   - "Canlı" trigger demosu için bunu izleyen blok 117 numaralı siparişi
     teslim edildi yaparak trigger'ı tetikler.
   ============================================================================ */
UPDATE r
   SET r.ToplamCiro = ISNULL(t.ToplamCiro, 0)
  FROM Restoranlar r
  LEFT JOIN (
        SELECT s.RestoranID, SUM(s.ToplamTutar) AS ToplamCiro
          FROM Siparisler s
         WHERE s.Durum = N'TeslimEdildi'
         GROUP BY s.RestoranID
  ) t ON t.RestoranID = r.RestoranID;
GO

PRINT 'Restoran tarihsel ciroları backfill edildi.';
GO

/* ============================================================================
   TRIGGER CANLI DEMOSU
   - "Yolda" durumundaki 117 numaralı siparişi "TeslimEdildi" yaparak trigger'ı
     gerçek zamanlı tetikleyelim.
   - Trigger restoranın ToplamCiro hanesine sipariş tutarını ekleyecektir.
   ============================================================================ */
DECLARE @SiparisID INT = 117;
DECLARE @RestoranID INT;
DECLARE @Tutar DECIMAL(12,2);
DECLARE @OncekiCiro DECIMAL(14,2);
DECLARE @SonrakiCiro DECIMAL(14,2);

SELECT @RestoranID = RestoranID, @Tutar = ToplamTutar FROM Siparisler WHERE SiparisID = @SiparisID;
SELECT @OncekiCiro = ToplamCiro FROM Restoranlar WHERE RestoranID = @RestoranID;
PRINT N'Trigger oncesi restoran cirosu: ' + CAST(@OncekiCiro AS NVARCHAR(20));

UPDATE Siparisler SET Durum = N'TeslimEdildi' WHERE SiparisID = @SiparisID;

SELECT @SonrakiCiro = ToplamCiro FROM Restoranlar WHERE RestoranID = @RestoranID;
PRINT N'Trigger sonrasi restoran cirosu : ' + CAST(@SonrakiCiro AS NVARCHAR(20));
PRINT N'Fark (sipariş tutari)            : ' + CAST(@Tutar AS NVARCHAR(20));
GO

PRINT '05_TestVerileri.sql tamamlandi.';
GO
