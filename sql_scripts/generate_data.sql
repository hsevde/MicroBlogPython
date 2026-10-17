/*
============================================
    MicroBlog - 50,000+ Kayıt Ekleme Scripti
    Bu script veritabanına toplu veri ekler
    
    KAYIT SAYILARI:
    - 1,000 Kullanıcı
    - 30,000 Post
    - 100,000 Yorum
    - 50,000 Beğeni
    
    TOPLAM: 181,000+ kayıt
============================================
*/

USE MicroBlogDB;
GO

PRINT '🚀 Toplu veri ekleme başlıyor...';
PRINT '⏱️ Bu işlem 2-3 dakika sürebilir, lütfen bekleyin...';
PRINT '';

SET NOCOUNT ON;
GO

-- ============================================
-- 1. KULLANICILAR EKLEME (1,000 kullanıcı)
-- ============================================
PRINT '👥 Kullanıcılar ekleniyor...';

DECLARE @i INT = 1;
DECLARE @MaxUsers INT = 1000;
-- Tüm üretilen kullanıcıların şifresi: 123456 (Werkzeug scrypt hash)
DECLARE @DemoPasswordHash NVARCHAR(255) = 'scrypt:32768:8:1$3jOf7doFsUM8EsNy$a54db5e61d1f038bff17ec44c9553e6ecfa3adad01e14f86abeb2db9ad9d7fbb7dc5a9ffebd26f5aa71f30708f2a3d8a3234c17aafe8081527c5cd743a4466cb';
DECLARE @FirstNames TABLE (Name NVARCHAR(50));
DECLARE @LastNames TABLE (Name NVARCHAR(50));

-- Örnek isimler
INSERT INTO @FirstNames VALUES 
('Ahmet'),('Mehmet'),('Ali'),('Ayşe'),('Fatma'),('Zeynep'),('Emine'),('Mustafa'),
('Can'),('Cem'),('Deniz'),('Elif'),('Emre'),('Furkan'),('Gizem'),('Hakan'),
('İrem'),('Kemal'),('Leyla'),('Murat'),('Nur'),('Osman'),('Ömer'),('Pınar'),
('Recep'),('Selim'),('Selin'),('Tuba'),('Ufuk'),('Volkan'),('Yusuf'),('Zeki'),
('Berk'),('Burak'),('Canan'),('Derya'),('Ece'),('Ege'),('Esra'),('Gülay'),
('Hasan'),('İbrahim'),('Kaan'),('Melih'),('Nil'),('Onur'),('Özlem'),('Seda'),
('Serkan'),('Tuğba'),('Uğur'),('Yasemin'),('Banu'),('Cem'),('Dilek'),('Engin'),
('Ferhat'),('Gül'),('Hande'),('İlhan'),('Jale'),('Koray'),('Levent'),('Melis'),
('Neslihan'),('Orkun'),('Özge'),('Pelin'),('Rana'),('Semih'),('Tolga'),('Umut'),
('Veli'),('Yakup'),('Zehra'),('Aslı'),('Barış'),('Ceyda'),('Damla'),('Ebru');

INSERT INTO @LastNames VALUES 
('Yılmaz'),('Kaya'),('Demir'),('Çelik'),('Şahin'),('Yıldız'),('Yıldırım'),('Öztürk'),
('Aydın'),('Özdemir'),('Arslan'),('Doğan'),('Kılıç'),('Aslan'),('Çetin'),('Kara'),
('Koç'),('Kurt'),('Özkan'),('Şimşek'),('Erdoğan'),('Acar'),('Polat'),('Güneş'),
('Çakır'),('Taş'),('Akın'),('Bulut'),('Korkmaz'),('Çınar'),('Güler'),('Bal'),
('Tekin'),('Aktaş'),('Turan'),('Çoban'),('Aksoy'),('Şen'),('Yüksel'),('Karaca');

WHILE @i <= @MaxUsers
BEGIN
    DECLARE @Username NVARCHAR(50) = 'user' + CAST(@i AS NVARCHAR(10));
    DECLARE @FirstName NVARCHAR(50) = (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID());
    DECLARE @LastName NVARCHAR(50) = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
    DECLARE @DisplayName NVARCHAR(100) = @FirstName + ' ' + @LastName;
    DECLARE @Email NVARCHAR(100) = @Username + '@email.com';
    DECLARE @Bio NVARCHAR(500) = 'Merhaba, ben ' + @DisplayName + '. MicroBlog kullanıcısıyım.';
    
    INSERT INTO blog.Users (Username, PasswordHash, DisplayName, Email, Bio, CreatedAt, IsActive)
    VALUES (
        @Username,
        @DemoPasswordHash,
        @DisplayName,
        @Email,
        @Bio,
        DATEADD(DAY, -CAST(RAND(CHECKSUM(NEWID())) * 365 AS INT), GETDATE()),
        1
    );
    
    SET @i = @i + 1;
    
    -- Her 100 kayıtta ilerleme göster
    IF @i % 100 = 0
    BEGIN
        PRINT '  ✓ ' + CAST(@i AS NVARCHAR(10)) + ' kullanıcı eklendi...';
    END
END

PRINT '✅ TOPLAM ' + CAST(@MaxUsers AS NVARCHAR(10)) + ' kullanıcı eklendi!';
PRINT '';

-- ============================================
-- 2. POSTLAR EKLEME (30,000 post)
-- ============================================
PRINT '📝 Postlar ekleniyor...';

SET @i = 1;
DECLARE @MaxPosts INT = 30000;
DECLARE @PostContents TABLE (Content NVARCHAR(500));

-- Örnek post içerikleri
INSERT INTO @PostContents VALUES 
('Bugün harika bir gün! 🌞'),
('Yeni bir proje üzerinde çalışıyorum. 💻'),
('Kahve keyfi ☕'),
('Veritabanı dersi çok eğlenceli! 📚'),
('Spor yapmak çok iyi geliyor. 🏃'),
('Yeni bir kitap okuyorum. 📖'),
('Müzik dinlemek ruhu dinlendiriyor. 🎵'),
('Arkadaşlarımla güzel vakit geçirdim. 👨‍👩‍👧‍👦'),
('Yazılım geliştirme tutkum! 💪'),
('Tatil planları yapıyorum. 🏖️'),
('Bugün çok üretken bir gün geçirdim.'),
('Yeni teknolojileri öğrenmek heyecan verici!'),
('Sabah kahvaltısı en sevdiğim öğün. 🍳'),
('Film izlemek için harika bir akşam.'),
('Kod yazmak benim için terapi gibi.'),
('Doğa yürüyüşü yapmayı seviyorum. 🌲'),
('Yeni bir dil öğreniyorum.'),
('Fotoğraf çekmek hobim. 📷'),
('Seyahat etmek hayalim.'),
('Ailemle kaliteli zaman geçirmek paha biçilmez.');

WHILE @i <= @MaxPosts
BEGIN
    DECLARE @RandomUserId INT = CAST(RAND(CHECKSUM(NEWID())) * 1000 AS INT) + 1;
    DECLARE @PostContent NVARCHAR(500) = (SELECT TOP 1 Content FROM @PostContents ORDER BY NEWID());
    
    INSERT INTO blog.Posts (UserId, Content, CreatedAt, LikeCount, CommentCount)
    VALUES (
        @RandomUserId,
        @PostContent + ' #Post' + CAST(@i AS NVARCHAR(10)),
        DATEADD(MINUTE, -CAST(RAND(CHECKSUM(NEWID())) * 525600 AS INT), GETDATE()), -- Son 1 yıl içinde
        0,
        0
    );
    
    SET @i = @i + 1;
    
    -- Her 1000 kayıtta ilerleme göster
    IF @i % 1000 = 0
    BEGIN
        PRINT '  ✓ ' + CAST(@i AS NVARCHAR(10)) + ' post eklendi...';
    END
END

PRINT '✅ TOPLAM ' + CAST(@MaxPosts AS NVARCHAR(10)) + ' post eklendi!';
PRINT '';

-- ============================================
-- 3. YORUMLAR EKLEME (100,000 yorum)
-- ============================================
PRINT '💬 Yorumlar ekleniyor...';

SET @i = 1;
DECLARE @MaxComments INT = 100000;
DECLARE @CommentContents TABLE (Content NVARCHAR(300));

-- Örnek yorum içerikleri
INSERT INTO @CommentContents VALUES 
('Çok güzel paylaşım! 👍'),
('Katılıyorum, haklısın.'),
('Bence de öyle! 😊'),
('Süper! 🎉'),
('Tebrikler!'),
('Harika fikir!'),
('İlginç...'),
('Ben de aynı şeyi düşünüyordum.'),
('Çok doğru söyledin.'),
('Kesinlikle!'),
('Aynen öyle.'),
('İyi ki paylaştın.'),
('Faydalı bilgi, teşekkürler.'),
('Bunu bilmiyordum.'),
('Detaylı anlatım için sağol.'),
('Devamını bekliyorum.'),
('Güzel tespit.'),
('Ben de deneyeceğim.'),
('İlham verici!'),
('Muhteşem! ❤️');

WHILE @i <= @MaxComments
BEGIN
    DECLARE @RandomPostId INT = CAST(RAND(CHECKSUM(NEWID())) * 30000 AS INT) + 1;
    DECLARE @RandomCommentUserId INT = CAST(RAND(CHECKSUM(NEWID())) * 1000 AS INT) + 1;
    DECLARE @CommentContent NVARCHAR(300) = (SELECT TOP 1 Content FROM @CommentContents ORDER BY NEWID());
    
    IF EXISTS (SELECT 1 FROM blog.Posts WHERE PostId = @RandomPostId)
    BEGIN
        INSERT INTO blog.Comments (PostId, UserId, Content, CreatedAt)
        VALUES (
            @RandomPostId,
            @RandomCommentUserId,
            @CommentContent,
            DATEADD(MINUTE, -CAST(RAND(CHECKSUM(NEWID())) * 525600 AS INT), GETDATE())
        );
        
        SET @i = @i + 1;
    END
    
    -- Her 5000 kayıtta ilerleme göster
    IF @i % 5000 = 0
    BEGIN
        PRINT '  ✓ ' + CAST(@i AS NVARCHAR(10)) + ' yorum eklendi...';
    END
END

PRINT '✅ TOPLAM ' + CAST(@MaxComments AS NVARCHAR(10)) + ' yorum eklendi!';
PRINT '';

-- ============================================
-- 4. BEĞENİLER EKLEME (50,000 beğeni)
-- ============================================
PRINT '❤️ Beğeniler ekleniyor...';

SET @i = 1;
DECLARE @MaxLikes INT = 50000;
DECLARE @AddedLikes INT = 0;

WHILE @AddedLikes < @MaxLikes
BEGIN
    DECLARE @RandomLikePostId INT = CAST(RAND(CHECKSUM(NEWID())) * 30000 AS INT) + 1;
    DECLARE @RandomLikeUserId INT = CAST(RAND(CHECKSUM(NEWID())) * 1000 AS INT) + 1;
    
    -- Aynı kullanıcı aynı postu iki kez beğenemesin
    IF NOT EXISTS (SELECT 1 FROM blog.Likes WHERE PostId = @RandomLikePostId AND UserId = @RandomLikeUserId)
    BEGIN
        INSERT INTO blog.Likes (PostId, UserId, CreatedAt)
        VALUES (
            @RandomLikePostId,
            @RandomLikeUserId,
            DATEADD(MINUTE, -CAST(RAND(CHECKSUM(NEWID())) * 525600 AS INT), GETDATE())
        );
        
        SET @AddedLikes = @AddedLikes + 1;
        
        -- Her 2500 kayıtta ilerleme göster
        IF @AddedLikes % 2500 = 0
        BEGIN
            PRINT '  ✓ ' + CAST(@AddedLikes AS NVARCHAR(10)) + ' beğeni eklendi...';
        END
    END
    
    SET @i = @i + 1;
    
    -- Sonsuz döngüyü önlemek için limit koy
    IF @i > @MaxLikes * 2
        BREAK;
END

PRINT '✅ TOPLAM ' + CAST(@AddedLikes AS NVARCHAR(10)) + ' beğeni eklendi!';
PRINT '';

-- ============================================
-- 5. TRİGGERLARI TETİKLE (Sayaçları Güncelle)
-- ============================================
PRINT '🔄 Post sayaçları güncelleniyor (Trigger tetikleniyor)...';

-- LikeCount güncelleme
UPDATE p
SET p.LikeCount = (SELECT COUNT(*) FROM blog.Likes WHERE PostId = p.PostId)
FROM blog.Posts p;

PRINT '  ✓ LikeCount güncellendi';

-- CommentCount güncelleme
UPDATE p
SET p.CommentCount = (SELECT COUNT(*) FROM blog.Comments WHERE PostId = p.PostId)
FROM blog.Posts p;

PRINT '  ✓ CommentCount güncellendi';
PRINT '';

-- ============================================
-- 6. KULLANICI İSTATİSTİKLERİNİ GÜNCELLE
-- ============================================
PRINT '📊 Kullanıcı istatistikleri güncelleniyor...';

EXEC blog.sp_UpdateAllStats;

PRINT '';

-- ============================================
-- 7. ÖZET RAPOR
-- ============================================
PRINT '============================================';
PRINT '  📊 VERİ EKLEME TAMAMLANDI!';
PRINT '============================================';

DECLARE @TotalUsers INT = (SELECT COUNT(*) FROM blog.Users);
DECLARE @TotalPosts INT = (SELECT COUNT(*) FROM blog.Posts);
DECLARE @TotalComments INT = (SELECT COUNT(*) FROM blog.Comments);
DECLARE @TotalLikes INT = (SELECT COUNT(*) FROM blog.Likes);
DECLARE @TotalRecords INT = @TotalUsers + @TotalPosts + @TotalComments + @TotalLikes;

PRINT '  📈 KAYIT İSTATİSTİKLERİ:';
PRINT '  ----------------------------------------';
PRINT '  👥 Kullanıcılar:    ' + CAST(@TotalUsers AS NVARCHAR(10));
PRINT '  📝 Postlar:         ' + CAST(@TotalPosts AS NVARCHAR(10));
PRINT '  💬 Yorumlar:        ' + CAST(@TotalComments AS NVARCHAR(10));
PRINT '  ❤️  Beğeniler:      ' + CAST(@TotalLikes AS NVARCHAR(10));
PRINT '  ----------------------------------------';
PRINT '  📊 TOPLAM KAYIT:    ' + CAST(@TotalRecords AS NVARCHAR(10));
PRINT '';

IF @TotalRecords >= 50000
BEGIN
    PRINT '  ✅ BAŞARILI! 50,000+ kayıt hedefine ulaşıldı!';
    PRINT '  🎯 Hocanızın gereksinimi karşılandı!';
END
ELSE
BEGIN
    PRINT '  ⚠️  Uyarı: 50,000 kayıt hedefine ulaşılamadı.';
    PRINT '  📝 Script''i tekrar çalıştırabilirsiniz.';
END

PRINT '';
PRINT '============================================';
PRINT '  🚀 Sistem kullanıma hazır!';
PRINT '============================================';

GO
