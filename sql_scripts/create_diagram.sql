/*
============================================
    Database Diagram Oluşturma Scripti
    SSMS'de visual diagram için
============================================
*/

USE MicroBlogDB;
GO

PRINT '📊 Database Diagram Bilgileri';
PRINT '════════════════════════════════════════════════════════';
PRINT '';
PRINT '🎨 SSMS''de Database Diagram Oluşturmak:';
PRINT '';
PRINT '1. SSMS''de MicroBlogDB''yi genişlet';
PRINT '2. "Database Diagrams" klasörüne sağ tıkla';
PRINT '3. "New Database Diagram" seçeneğini tıkla';
PRINT '4. İlk seferinde diagram desteği eklemek ister - "Yes" de';
PRINT '5. Tablo seçme penceresinde blog schema''sındaki 5 tabloyu seç:';
PRINT '   ✓ blog.Users';
PRINT '   ✓ blog.Posts';
PRINT '   ✓ blog.Comments';
PRINT '   ✓ blog.Likes';
PRINT '   ✓ blog.UserStats';
PRINT '6. "Add" butonuna tıkla';
PRINT '7. Otomatik olarak FK ilişkileri çizilir';
PRINT '8. Tabloları sürükleyerek düzenle';
PRINT '9. Ctrl+S ile kaydet (örn: "MicroBlog_Schema")';
PRINT '';
PRINT '════════════════════════════════════════════════════════';
PRINT '';

-- Tablo ve ilişkileri göster
PRINT '📋 Tablolar ve Sütunları:';
PRINT '';

SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable,
    CASE WHEN ic.column_id IS NOT NULL THEN 'PK' ELSE '' END AS IsPrimaryKey,
    CASE WHEN fkc.parent_column_id IS NOT NULL THEN 'FK' ELSE '' END AS IsForeignKey
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
LEFT JOIN sys.index_columns ic ON ic.object_id = t.object_id 
    AND ic.column_id = c.column_id 
    AND ic.index_id = (
        SELECT index_id FROM sys.indexes 
        WHERE object_id = t.object_id AND is_primary_key = 1
    )
LEFT JOIN sys.foreign_key_columns fkc ON fkc.parent_object_id = t.object_id 
    AND fkc.parent_column_id = c.column_id
WHERE t.schema_id = SCHEMA_ID('blog')
ORDER BY t.name, c.column_id;

PRINT '';
PRINT '🔗 Foreign Key İlişkileri:';
PRINT '';

SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    c1.name AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    c2.name AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns c1 ON fkc.parent_object_id = c1.object_id 
    AND fkc.parent_column_id = c1.column_id
INNER JOIN sys.columns c2 ON fkc.referenced_object_id = c2.object_id 
    AND fkc.referenced_column_id = c2.column_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'blog'
ORDER BY ChildTable, ChildColumn;

PRINT '';
PRINT '════════════════════════════════════════════════════════';
PRINT '';
PRINT '💡 İpucu: Diagram''ı PDF veya PNG olarak kaydetmek için:';
PRINT '   1. Diagram açıkken File → Save As Image';
PRINT '   2. Veya Print → Microsoft Print to PDF';
PRINT '';
PRINT '🎨 Diagram Düzenleme İpuçları:';
PRINT '   • Tabloları sürükle-bırak ile yerleştir';
PRINT '   • Sağ tık → Table View → Standard (sadece önemli kolonlar)';
PRINT '   • Sağ tık → Relationships → Çizgi stilini değiştir';
PRINT '   • Zoom: Ctrl + Mouse Wheel';
PRINT '';
PRINT '════════════════════════════════════════════════════════';
GO

-- Text-based ASCII diagram
PRINT '';
PRINT '📐 Text-Based Database Diagram:';
PRINT '';
PRINT '        ┌─────────────┐';
PRINT '        │blog.Users   │';
PRINT '        │─────────────│';
PRINT '        │🔑 UserId    │';
PRINT '        │  Username   │';
PRINT '        │  Email      │';
PRINT '        │  Password   │';
PRINT '        └──────┬──────┘';
PRINT '               │';
PRINT '       ┌───────┼───────┬─────────┐';
PRINT '       │       │       │         │';
PRINT '   ┌───▼───┐ ┌─▼────┐ ┌▼──────┐ ┌▼─────────┐';
PRINT '   │Posts  │ │Cmnts │ │Likes  │ │UserStats │';
PRINT '   │───────│ │──────│ │───────│ │──────────│';
PRINT '   │🔑PstId│ │🔑CmId│ │🔑LkId │ │🔑UserId  │';
PRINT '   │🔗UsrId│ │🔗PsId│ │🔗PsId │ │ PostCnt  │';
PRINT '   │Content│ │🔗UsId│ │🔗UsId │ │ CmntCnt  │';
PRINT '   └───┬───┘ │Cntnt │ └───────┘ │ LikeCnt  │';
PRINT '       │     └──────┘            └──────────┘';
PRINT '       │';
PRINT '   ┌───┴───────────┐';
PRINT '   │               │';
PRINT ' Comments       Likes';
PRINT ' (PostId FK)    (PostId FK)';
PRINT '';
PRINT '🔐 Constraints:';
PRINT '   • Users.Username → UNIQUE';
PRINT '   • Users.Email → UNIQUE';
PRINT '   • Likes (PostId + UserId) → UNIQUE';
PRINT '';
GO
