# 🚀 MicroBlog - Modern Mikro Blog Platformu

Tam fonksiyonel, modern ve kullanıcı dostu mikro blog platformu. Python Flask ve Microsoft SQL Server ile geliştirilmiştir.

[![Python](https://img.shields.io/badge/Python-3.12+-blue.svg)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0+-green.svg)](https://flask.palletsprojects.com/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-red.svg)](https://www.microsoft.com/sql-server/)
**🎓 Veritabanı Yönetimi Dersi - Final Projesi**  
**📊 181,000+ Kayıt | 7 Index | 6 Procedure | 2 Trigger | 2 Job**

---

## 📋 İçindekiler

- [Özellikler](#-özellikler)
- [Kurulum](#-kurulum)
- [Veritabanı Kurulumu](#-veritabanı-kurulumu)
- [Kullanım](#-kullanım)
- [Veritabanı Mimarisi](#-veritabanı-mimarisi)
- [SQL Konuları](#-sql-konuları)
- [Teknolojiler](#-teknolojiler)
- [Proje Yapısı](#-proje-yapısı)

---

## ✨ Özellikler

### 👤 Kullanıcı Yönetimi
- ✅ Kayıt olma ve giriş yapma
- ✅ Oturum yönetimi (Flask session)
- ✅ Profil bilgileri (Bio, avatar)
- ✅ Kullanıcı istatistikleri

### 📝 Post Yönetimi
- ✅ Yeni post paylaşma (**Stored Procedure kullanarak**)
- ✅ **Fotoğraf upload desteği** (PNG, JPG, JPEG, GIF, WEBP)
- ✅ Fotoğraf önizleme özelliği
- ✅ Kendi postlarını görüntüleme (**VIEW kullanarak**)
- ✅ Post silme (**Transaction ile**)
- ✅ Post istatistikleri (beğeni, yorum sayısı)

### 💬 Yorum Sistemi
- ✅ Postlara yorum yapma (**Stored Procedure**)
- ✅ Yorumları dinamik yükleme (AJAX)
- ✅ Kendi yorumlarını silme (AJAX)
- ✅ Otomatik yorum sayacı (**Trigger ile**)

### ❤️ Beğeni Sistemi
- ✅ Post beğenme/beğeniyi kaldırma (toggle)
- ✅ Anlık beğeni sayısı güncelleme (AJAX)
- ✅ Otomatik beğeni sayacı (**Trigger ile**)
- ✅ Tekil beğeni kontrolü (UNIQUE constraint)

### 📊 İstatistikler
- ✅ Toplam kullanıcı, post, yorum sayıları
- ✅ En aktif kullanıcılar listesi (**CURSOR kullanarak**)
- ✅ Kullanıcı bazlı istatistikler
- ✅ Otomatik istatistik güncelleme (**SQL Agent Job**)

### 🎨 Modern Arayüz
- ✅ Responsive tasarım (mobil uyumlu)
- ✅ Glassmorphism efekti
- ✅ Gradient renkler ve smooth animasyonlar
- ✅ Bootstrap 5.3 + Custom CSS
- ✅ Bootstrap Icons
- ✅ Loading animasyonları

### 🔐 Güvenlik & Performans
- ✅ **7 adet Index** (sorgu optimizasyonu)
- ✅ **Transaction** kullanımı (veri bütünlüğü)
- ✅ **Trigger'lar** (otomatik güncelleme)
- ✅ **SQL Agent Jobs** (otomatik yedekleme)
- ✅ Dosya tipi ve boyut kontrolü
- ✅ SQL injection koruması (parameterized queries)
- ✅ Şifreler hash'lenerek saklanır (Werkzeug scrypt)
- ✅ CSRF koruması (Flask-WTF)
- ✅ XSS koruması (kullanıcı içeriği escape edilir)
- ✅ Gizli bilgiler `.env` dosyasında, kodda değil

---

## 🔧 Kurulum

### Gereksinimler

- ✅ Python 3.12 veya üzeri
- ✅ Microsoft SQL Server 2019 veya üzeri
- ✅ ODBC Driver 17 for SQL Server
- ✅ SQL Server Management Studio (SSMS) - önerilir

### Adım 1: Projeyi İndirin

```bash
git clone <repo-adresi>
cd MicroBlogPython
```

### Adım 2: Python Bağımlılıklarını Yükleyin

```bash
python -m venv .venv
.venv\Scripts\activate        # Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
```

### Adım 3: Veritabanını Kurun

1. SQL Server Management Studio'yu (SSMS) açın
2. SQL Server'ınıza bağlanın
3. `sql_scripts/setup.sql` dosyasını açın
4. Script'i çalıştırın (F5)

Script otomatik olarak:
- `MicroBlogDB` veritabanını oluşturur
- Tüm tabloları oluşturur
- View'ları, Procedure'ları, Trigger'ları ekler
- Örnek kullanıcılar ve postlar ekler

İsteğe bağlı olarak `sql_scripts/generate_data.sql` ile 181,000+ test kaydı ekleyebilirsiniz (2-3 dakika sürer).

### Adım 4: Ortam Değişkenlerini Ayarlayın

`.env.example` dosyasını `.env` adıyla kopyalayın ve kendi değerlerinizi girin:

```bash
copy .env.example .env        # Linux/macOS: cp .env.example .env
```

```ini
SECRET_KEY=uzun-rastgele-bir-deger
DB_DRIVER=ODBC Driver 17 for SQL Server
DB_SERVER=SUNUCU_ADINIZ\INSTANCE_ADI
DB_NAME=MicroBlogDB
FLASK_DEBUG=1
```

`SECRET_KEY` üretmek için: `python -c "import secrets; print(secrets.token_hex(32))"`

### Adım 5: Uygulamayı Başlatın

```bash
python app.py
```

Tarayıcınızda açın: **http://localhost:5000**

---

## 🎮 Kullanım

### Test Kullanıcıları

Script otomatik olarak test kullanıcıları oluşturur:

| Kullanıcı Adı | Şifre | Rol |
|---------------|-------|-----|
| admin | 123456 | Yönetici |
| ali | 123456 | Kullanıcı |
| ayse | 123456 | Kullanıcı |
| mehmet | 123456 | Kullanıcı |
| user1 … user1000 | 123456 | `generate_data.sql` çalıştırıldıysa |

> Bunlar yalnızca yerel geliştirme için demo hesaplarıdır.

### Temel İşlemler

1. **Giriş Yapma:** `http://localhost:5000` → Kullanıcı adı ve şifre ile giriş
2. **Post Paylaşma:** Ana sayfada üst kısımda "Ne düşünüyorsun?" alanına yazın ve "Paylaş" butonuna tıklayın
3. **Yorum Yapma:** Bir postun altındaki yorum ikonuna tıklayın, yorum yazıp gönderin
4. **Beğenme:** Kalp ikonuna tıklayarak beğenin, tekrar tıklayarak beğeniyi kaldırın
5. **İstatistikler:** Üst menüden "İstatistikler" sayfasına giderek toplam verileri ve en aktif kullanıcıları görün

---

## 🗄️ Veritabanı Mimarisi

### Schema: `blog`

Tüm veritabanı nesneleri `blog` şeması altında organize edilmiştir.

### Tablolar

| Tablo | Açıklama | İlişkiler |
|-------|----------|-----------|
| **blog.Users** | Kullanıcı bilgileri | - |
| **blog.Posts** | Paylaşılan postlar | UserId → Users |
| **blog.Comments** | Postlara yapılan yorumlar | PostId → Posts, UserId → Users |
| **blog.Likes** | Post beğenileri | PostId → Posts, UserId → Users |
| **blog.UserStats** | Kullanıcı istatistikleri | UserId → Users |

### Entity-Relationship Diagram (ER)

```
Users (1) ──< (N) Posts (1) ──< (N) Comments
  │                  │
  │                  └──< (N) Likes
  │
  └──< (1) UserStats
```

### View'lar

- **blog.vw_Feed:** Postları kullanıcı bilgileriyle birlikte gösterir
- **blog.vw_MyPosts:** Belirli bir kullanıcının postlarını gösterir

### Stored Procedures

- **blog.sp_CreatePost:** Yeni post oluşturur (Transaction + Try-Catch)
- **blog.sp_AddComment:** Yorum ekler (Transaction)
- **blog.sp_GetTopUsers:** En aktif kullanıcıları bulur (Cursor kullanır)
- **blog.sp_BackupDatabase:** Veritabanı yedeği alır
- **blog.sp_UpdateAllStats:** Kullanıcı istatistiklerini günceller (MERGE)
- **blog.sp_CleanOldPosts:** Eski kayıtları temizler

### Triggers

- **blog.trg_UpdateCommentCount:** Yorum eklendiğinde post sayacını günceller
- **blog.trg_UpdateLikeCount:** Beğeni eklenip/silindiğinde sayacı günceller

### Index'ler

- **IX_Posts_UserId:** Kullanıcı bazlı sorguları hızlandırır
- **IX_Posts_CreatedAt:** Tarih sıralı sorguları optimize eder
- **IX_Comments_PostId:** Post bazlı yorum sorgularını hızlandırır
- **IX_Comments_UserId:** Kullanıcı bazlı yorum sorgularını hızlandırır
- **IX_Likes_PostId:** Beğeni sorgularını hızlandırır
- **IX_Users_Username:** Login sorgusunu hızlandırır
- **IX_Likes_PostId_UserId:** Beğeni toggle kontrolü (composite)

---

## 🛠️ Teknolojiler

### Backend
- **Python 3.12:** Ana programlama dili
- **Flask 3.0:** Web framework
- **pyodbc:** SQL Server bağlantısı

### Database
- **Microsoft SQL Server:** İlişkisel veritabanı
- **T-SQL:** Stored procedures, triggers, views

### Frontend
- **HTML5 & CSS3:** Yapı ve stil
- **Bootstrap 5:** Responsive tasarım framework'ü
- **Bootstrap Icons:** İkon seti
- **Vanilla JavaScript:** AJAX işlemleri, dinamik içerik

### Araçlar
- **VS Code:** Kod editörü
- **SQL Server Management Studio (SSMS):** Veritabanı yönetimi
- **Git:** Versiyon kontrolü

---

## 📚 SQL Konuları

Bu proje, veritabanı yönetimi dersinde öğretilen tüm konuları kapsamaktadır:

| # | Konu | Uygulama | Konum |
|---|------|----------|-------|
| 1 | **Schema** | `blog` şeması | setup.sql |
| 2 | **Tables** | 5 tablo (Users, Posts, Comments, Likes, UserStats) | setup.sql |
| 3 | **Primary Key** | Tüm tablolarda | setup.sql |
| 4 | **Foreign Key** | İlişkili tablolarda | setup.sql |
| 5 | **Index** | 7 performans indeksi | setup.sql |
| 6 | **View** | 2 view (vw_Feed, vw_MyPosts) | setup.sql |
| 7 | **Stored Procedure** | 6 procedure | setup.sql |
| 8 | **Transaction** | Tüm procedure'larda | setup.sql |
| 9 | **Try-Catch** | Hata yönetimi | setup.sql |
| 10 | **Trigger** | 2 otomatik tetikleyici | setup.sql |
| 11 | **Cursor** | sp_GetTopUsers içinde | setup.sql |
| 12 | **Backup** | sp_BackupDatabase | setup.sql |
| 13 | **JOIN** | View'larda kullanıldı | setup.sql |
| 14 | **SQL Agent Job** | Günlük yedek + haftalık istatistik | setup.sql |

---

## 📂 Proje Yapısı

```
MicroBlogPython/
│
├── app.py                          # Ana Flask uygulaması
├── requirements.txt                # Python bağımlılıkları
├── .env.example                    # Örnek ortam değişkenleri
├── README.md                       # Bu dosya
│
├── sql_scripts/
│   ├── setup.sql                  # Veritabanı kurulum script'i
│   ├── generate_data.sql          # 181,000+ test kaydı
│   ├── check_jobs.sql             # SQL Agent Job kontrolü
│   ├── create_diagram.sql         # ER diyagramı
│   └── fix_missing_procedure.sql  # Eksik procedure düzeltmesi
│
├── templates/                      # HTML şablonları
│   ├── layout.html                # Ana layout (navbar, footer)
│   ├── login.html                 # Giriş sayfası
│   ├── register.html              # Kayıt sayfası
│   ├── feed.html                  # Ana akış
│   ├── my_posts.html              # Kullanıcının postları
│   └── stats.html                 # İstatistikler
│
└── static/                         # Statik dosyalar
    ├── css/
    │   └── style.css              # Özel CSS stilleri
    ├── js/
    │   └── app.js                 # Frontend JavaScript (AJAX)
    └── uploads/                   # Yüklenen fotoğraflar (git'e eklenmez)
```

---

## 🧪 Test Etme

### SQL Test Sorguları

```sql
-- View'ları test et
SELECT * FROM blog.vw_Feed;
SELECT * FROM blog.vw_MyPosts WHERE UserId = 1;

-- Procedure'ları test et
EXEC blog.sp_CreatePost @UserId=1, @Content='Test post';
EXEC blog.sp_GetTopUsers;

-- Trigger'ı test et
INSERT INTO blog.Comments (PostId, UserId, Content) VALUES (1, 1, 'Test yorum');
SELECT CommentCount FROM blog.Posts WHERE PostId = 1;  -- Otomatik arttı!
```

---

## 🚀 Geliştirme

### Yeni Özellik Ekleme

1. Backend (app.py):
```python
@app.route('/yeni-ozellik')
def yeni_ozellik():
    # Kod buraya
    return render_template('yeni.html')
```

2. Frontend (templates/yeni.html):
```html
{% extends "layout.html" %}
{% block content %}
    <!-- İçerik buraya -->
{% endblock %}
```

3. Veritabanı (SQL):
```sql
-- Yeni tablo/procedure ekle
CREATE TABLE blog.YeniTablo (...)
```

### Debug Mode

`.env` dosyasında `FLASK_DEBUG=1` ayarlandığında debug mode açılır ve kod değişikliklerinde uygulama otomatik yenilenir. Üretimde `0` bırakın.

---

