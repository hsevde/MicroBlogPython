SELECT 
    'Kullanıcılar' AS Tablo, COUNT(*) AS Sayı FROM blog.Users
UNION ALL SELECT 'Postlar', COUNT(*) FROM blog.Posts
UNION ALL SELECT 'Yorumlar', COUNT(*) FROM blog.Comments
UNION ALL SELECT 'Beğeniler', COUNT(*) FROM blog.Likes;