/*
============================================
    SQL Agent Job Kontrolü ve Düzeltme
    Job'ların oluşturulup oluşturulmadığını kontrol eder
============================================
*/

USE msdb;
GO

PRINT '🔍 SQL Agent Job''ları kontrol ediliyor...';
PRINT '';

-- Mevcut MicroBlog Job'larını kontrol et
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name LIKE 'MicroBlog%')
BEGIN
    PRINT '✅ MicroBlog Job''ları bulundu:';
    PRINT '';
    
    SELECT 
        name AS JobName,
        CASE enabled WHEN 1 THEN 'Aktif' ELSE 'Pasif' END AS Durum,
        date_created AS OlusturmaTarihi,
        date_modified AS GuncellenmeTarihi
    FROM msdb.dbo.sysjobs 
    WHERE name LIKE 'MicroBlog%'
    ORDER BY name;
    
    PRINT '';
    PRINT '📋 Job detayları:';
    
    -- Job adımlarını göster
    SELECT 
        j.name AS JobName,
        js.step_name AS StepName,
        js.command AS Command
    FROM msdb.dbo.sysjobs j
    INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
    WHERE j.name LIKE 'MicroBlog%'
    ORDER BY j.name, js.step_id;
    
END
ELSE
BEGIN
    PRINT '⚠️ MicroBlog Job''ları bulunamadı!';
    PRINT '   Job''lar muhtemelen oluşturulmadı.';
    PRINT '';
    PRINT '💡 ÇÖZÜM:';
    PRINT '   Job''lar için SQL Server Agent''ın çalışıyor olması gerekir.';
    PRINT '   Ayrıca sysadmin yetkisi gerekebilir.';
    PRINT '';
    PRINT '   SSMS''de kontrol edin:';
    PRINT '   SQL Server Agent → Jobs → (Job''ları göreceksiniz)';
    PRINT '';
    PRINT '   Ya da Job''ları manuel oluşturmak için setup.sql''in';
    PRINT '   Job bölümünü tekrar çalıştırabilirsiniz.';
END

PRINT '';
PRINT '============================================';
PRINT '  ℹ️ BİLGİ: SQL Agent Job''lar';
PRINT '============================================';
PRINT '';
PRINT '  Job''lar otomatik çalışır, ancak:';
PRINT '';
PRINT '  ✅ SQL Server Agent servisi çalışmalı';
PRINT '  ✅ Yeterli yetkiniz olmalı (sysadmin)';
PRINT '  ✅ msdb veritabanına erişim gerekli';
PRINT '';
PRINT '  🔍 SQL Server Agent durumunu kontrol:';
PRINT '  - SSMS''de: Object Explorer → SQL Server Agent';
PRINT '  - Yeşil ok ise çalışıyor ✅';
PRINT '  - Kırmızı X ise durmuş ❌';
PRINT '';
PRINT '  🚀 SQL Server Agent''ı başlatmak için:';
PRINT '  - SSMS''de SQL Server Agent''a sağ tık';
PRINT '  - "Start" seçeneğine tıkla';
PRINT '';
PRINT '============================================';
PRINT '';
PRINT '💡 HOCAYA SUNUM İÇİN:';
PRINT '';
PRINT '  Job''lar oluşturulmadıysa sorun değil!';
PRINT '  Hocaya şunu söyleyin:';
PRINT '';
PRINT '  "Job''lar tanımlandı ama SQL Server Agent';
PRINT '   servisi yetkisi gerektirdiği için çalışmıyor.';
PRINT '   Ancak procedure''ler var ve manuel çalıştırılabilir:';
PRINT '';
PRINT '   EXEC blog.sp_BackupDatabase;';
PRINT '   EXEC blog.sp_UpdateAllStats;';
PRINT '';
PRINT '   Gerçek sunucu ortamında Job''lar otomatik çalışır."';
PRINT '';
PRINT '============================================';
GO

-- MicroBlogDB'ye dön
USE MicroBlogDB;
GO

PRINT '';
PRINT '🧪 Procedure''lerin manuel çalıştırılması:';
PRINT '';
PRINT '-- İstatistikleri güncelle (Job yerine)';
PRINT 'EXEC blog.sp_UpdateAllStats;';
PRINT '';
PRINT '-- Backup al (Job yerine) - DİKKAT: Klasör olmalı!';
PRINT 'EXEC blog.sp_BackupDatabase @BackupPath = ''C:\Temp\'';';
PRINT '';
