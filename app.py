from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_wtf.csrf import CSRFProtect
from dotenv import load_dotenv
import pyodbc
from datetime import datetime
import os
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash

load_dotenv()

app = Flask(__name__)
app.secret_key = os.environ['SECRET_KEY']
csrf = CSRFProtect(app)

# Dosya upload ayarları
UPLOAD_FOLDER = 'static/uploads/posts'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max

# Upload klasörünü oluştur
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

def allowed_file(filename):
    """Dosya uzantısı kontrolü"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# MSSQL Bağlantı Ayarları
CONNECTION_STRING = (
    f"DRIVER={{{os.environ.get('DB_DRIVER', 'ODBC Driver 17 for SQL Server')}}};"
    f"SERVER={os.environ.get('DB_SERVER', 'localhost')};"
    f"DATABASE={os.environ.get('DB_NAME', 'MicroBlogDB')};"
    "Trusted_Connection=yes;"
)

def get_db_connection():
    """Veritabanı bağlantısı oluşturur"""
    return pyodbc.connect(CONNECTION_STRING)

def is_password_hash(value):
    """Değerin Werkzeug formatında bir hash olup olmadığını kontrol eder"""
    return value.startswith(('scrypt:', 'pbkdf2:'))

# ==================== ANA SAYFA ====================
@app.route('/')
def index():
    """Ana sayfa - Direkt login sayfasına yönlendir"""
    if 'user_id' in session:
        return redirect(url_for('feed'))
    return redirect(url_for('login'))

# ==================== GİRİŞ ====================
@app.route('/login', methods=['GET', 'POST'])
def login():
    """Kullanıcı girişi"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Kullanıcıyı kontrol et
        cursor.execute("""
            SELECT UserId, Username, DisplayName, PasswordHash 
            FROM blog.Users 
            WHERE Username = ?
        """, (username,))
        
        user = cursor.fetchone()
        valid = False
        
        if user:
            if is_password_hash(user.PasswordHash):
                valid = check_password_hash(user.PasswordHash, password)
            elif user.PasswordHash == password:
                # Eski düz metin şifreyi ilk girişte hash'e çevir
                valid = True
                cursor.execute(
                    "UPDATE blog.Users SET PasswordHash = ? WHERE UserId = ?",
                    (generate_password_hash(password), user.UserId)
                )
                conn.commit()
        
        conn.close()
        
        if valid:
            session['user_id'] = user.UserId
            session['username'] = user.Username
            session['display_name'] = user.DisplayName
            flash('Giriş başarılı!', 'success')
            return redirect(url_for('feed'))
        else:
            flash('Kullanıcı adı veya şifre hatalı!', 'error')
    
    return render_template('login.html')

# ==================== KAYIT ====================
@app.route('/register', methods=['GET', 'POST'])
def register():
    """Yeni kullanıcı kaydı"""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        display_name = request.form['display_name']
        email = request.form['email']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT INTO blog.Users (Username, PasswordHash, DisplayName, Email, CreatedAt)
                VALUES (?, ?, ?, ?, GETDATE())
            """, (username, generate_password_hash(password), display_name, email))
            conn.commit()
            flash('Kayıt başarılı! Giriş yapabilirsiniz.', 'success')
            return redirect(url_for('login'))
        except pyodbc.IntegrityError:
            flash('Bu kullanıcı adı veya e-posta zaten kullanılıyor.', 'error')
        except Exception:
            app.logger.exception('Kayıt hatası')
            flash('Kayıt sırasında bir hata oluştu.', 'error')
        finally:
            conn.close()
    
    return render_template('register.html')

# ==================== ÇIKIŞ ====================
@app.route('/logout')
def logout():
    """Kullanıcı çıkışı"""
    session.clear()
    flash('Çıkış yapıldı.', 'info')
    return redirect(url_for('login'))

# ==================== ANA AKIŞ (FEED) ====================
@app.route('/feed')
def feed():
    """Ana akış - Tüm postları göster (VIEW kullanarak)"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # VIEW kullanarak postları getir 
    cursor.execute("""
        SELECT * FROM blog.vw_Feed 
        ORDER BY CreatedAt DESC
    """)
    
    posts = cursor.fetchall()
    conn.close()
    
    return render_template('feed.html', posts=posts)

# ==================== YENİ POST ====================
@app.route('/post/new', methods=['POST'])
def new_post():
    """Yeni post oluştur (STORED PROCEDURE kullanarak) - Fotoğraf desteği ile"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    content = request.form['content']
    image_url = None
    
    # Fotoğraf yükleme kontrolü
    if 'image' in request.files:
        file = request.files['image']
        if file and file.filename != '' and allowed_file(file.filename):
            # Güvenli dosya adı oluştur
            filename = secure_filename(file.filename)
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            unique_filename = f"{session['user_id']}_{timestamp}_{filename}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
            
            try:
                file.save(filepath)
                # Veritabanına kaydedilecek URL (relative path)
                image_url = f'/static/uploads/posts/{unique_filename}'
            except Exception:
                app.logger.exception('Fotoğraf yükleme hatası')
                flash('Fotoğraf yüklenemedi.', 'error')
                return redirect(url_for('feed'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # STORED PROCEDURE kullanarak post oluştur  PROCEDURE
        cursor.execute("""
            EXEC blog.sp_CreatePost @UserId = ?, @Content = ?, @ImageUrl = ?
        """, (session['user_id'], content, image_url))
        conn.commit()
        flash('Post paylaşıldı!', 'success')
    except Exception:
        app.logger.exception('Post oluşturma hatası')
        flash('Post paylaşılamadı.', 'error')
    finally:
        conn.close()
    
    return redirect(url_for('feed'))

# ==================== YORUM EKLE ====================
@app.route('/comment/add', methods=['POST'])
def add_comment():
    """Yorum ekle (STORED PROCEDURE kullanarak)"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    post_id = request.form['post_id']
    content = request.form['content']
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # STORED PROCEDURE kullanarak yorum ekle
        cursor.execute("""
            EXEC blog.sp_AddComment @PostId = ?, @UserId = ?, @Content = ?
        """, (post_id, session['user_id'], content))
        conn.commit()
        flash('Yorum eklendi!', 'success')
    except Exception:
        app.logger.exception('Yorum ekleme hatası')
        flash('Yorum eklenemedi.', 'error')
    finally:
        conn.close()
    
    return redirect(url_for('feed'))

# ==================== YORUM SİL ====================
@app.route('/comment/delete/<int:comment_id>', methods=['POST'])
def delete_comment(comment_id):
    """Yorum sil"""
    if 'user_id' not in session:
        return {'error': 'Giriş yapmalısınız'}, 401
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Yorumun sahibi mi kontrol et
        cursor.execute("""
            SELECT PostId FROM blog.Comments 
            WHERE CommentId = ? AND UserId = ?
        """, (comment_id, session['user_id']))
        
        result = cursor.fetchone()
        
        if not result:
            return {'error': 'Bu yorumu silme yetkiniz yok'}, 403
        
        post_id = result.PostId
        
        # Yorumu sil (Trigger otomatik CommentCount güncelleyecek)
        cursor.execute("DELETE FROM blog.Comments WHERE CommentId = ?", (comment_id,))
        conn.commit()
        
        return {'success': True, 'post_id': post_id}
    except Exception:
        app.logger.exception('Yorum silme hatası')
        return {'error': 'Yorum silinemedi'}, 500
    finally:
        conn.close()

# ==================== YORUMLARI GETİR ====================
@app.route('/comments/<int:post_id>')
def get_comments(post_id):
    """Bir postun yorumlarını getir"""
    if 'user_id' not in session:
        return {'error': 'Giriş yapmalısınız'}, 401
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT c.CommentId, c.Content, c.CreatedAt, c.UserId,
               u.Username, u.DisplayName
        FROM blog.Comments c
        INNER JOIN blog.Users u ON c.UserId = u.UserId
        WHERE c.PostId = ?
        ORDER BY c.CreatedAt DESC
    """, (post_id,))
    
    comments = []
    for row in cursor.fetchall():
        comments.append({
            'id': row.CommentId,
            'content': row.Content,
            'created_at': row.CreatedAt.strftime('%d/%m/%Y %H:%M') if row.CreatedAt else '',
            'username': row.Username,
            'display_name': row.DisplayName,
            'user_id': row.UserId,
            'can_delete': row.UserId == session.get('user_id')
        })
    
    conn.close()
    return {'comments': comments}

# ==================== BEĞENİ ====================
@app.route('/like/<int:post_id>', methods=['POST'])
def like_post(post_id):
    """Post beğen/beğeniyi kaldır (TOGGLE)"""
    if 'user_id' not in session:
        return {'error': 'Giriş yapmalısınız'}, 401
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Kullanıcı bu postu daha önce beğenmiş mi?
        cursor.execute("""
            SELECT LikeId FROM blog.Likes 
            WHERE PostId = ? AND UserId = ?
        """, (post_id, session['user_id']))
        
        existing_like = cursor.fetchone()
        
        if existing_like:
            # Beğeniyi kaldır
            cursor.execute("""
                DELETE FROM blog.Likes WHERE PostId = ? AND UserId = ?
            """, (post_id, session['user_id']))
            action = 'unliked'
        else:
            # Beğeni ekle
            cursor.execute("""
                INSERT INTO blog.Likes (PostId, UserId, CreatedAt)
                VALUES (?, ?, GETDATE())
            """, (post_id, session['user_id']))
            action = 'liked'
        
        conn.commit()
        
        # Güncel beğeni sayısını al
        cursor.execute("SELECT LikeCount FROM blog.Posts WHERE PostId = ?", (post_id,))
        like_count = cursor.fetchone()[0]
        
        return {'action': action, 'like_count': like_count}
    except Exception:
        app.logger.exception('Beğeni hatası')
        return {'error': 'Beğeni işlemi başarısız'}, 500
    finally:
        conn.close()

# ==================== BENİM POSTLARIM ====================
@app.route('/my-posts')
def my_posts():
    """Kullanıcının kendi postları (VIEW kullanarak)"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # VIEW kullanarak kullanıcının postlarını getir
    cursor.execute("""
        SELECT * FROM blog.vw_MyPosts 
        WHERE UserId = ?
        ORDER BY CreatedAt DESC
    """, (session['user_id'],))
    
    posts = cursor.fetchall()
    conn.close()
    
    return render_template('my_posts.html', posts=posts)

# ==================== POST SİL ====================
@app.route('/post/delete/<int:post_id>', methods=['POST'])
def delete_post(post_id):
    """Post sil (TRANSACTION kullanarak)"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # TRANSACTION ile silme işlemi (Hocanın konusu: TRANSACTION + TRY-CATCH)
        cursor.execute("""
            BEGIN TRY
                BEGIN TRANSACTION
                    -- Önce yorumları sil
                    DELETE FROM blog.Comments WHERE PostId = ?
                    -- Sonra postu sil
                    DELETE FROM blog.Posts WHERE PostId = ? AND UserId = ?
                COMMIT TRANSACTION
            END TRY
            BEGIN CATCH
                ROLLBACK TRANSACTION
                THROW
            END CATCH
        """, (post_id, post_id, session['user_id']))
        conn.commit()
        flash('Post silindi!', 'success')
    except Exception:
        app.logger.exception('Post silme hatası')
        flash('Post silinemedi.', 'error')
    finally:
        conn.close()
    
    return redirect(url_for('my_posts'))

# ==================== İSTATİSTİKLER ====================
@app.route('/stats')
def stats():
    """İstatistikler sayfası (CURSOR kullanarak)"""
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Genel istatistikler
    cursor.execute("SELECT COUNT(*) FROM blog.Users")
    total_users = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM blog.Posts")
    total_posts = cursor.fetchone()[0]
    
    cursor.execute("SELECT COUNT(*) FROM blog.Comments")
    total_comments = cursor.fetchone()[0]
    
    # En aktif kullanıcılar (CURSOR procedure ile)
    cursor.execute("EXEC blog.sp_GetTopUsers")
    top_users = cursor.fetchall()
    
    conn.close()
    
    return render_template('stats.html', 
                         total_users=total_users,
                         total_posts=total_posts,
                         total_comments=total_comments,
                         top_users=top_users)

# ==================== UYGULAMA BAŞLAT ====================
if __name__ == '__main__':
    print("🚀 MicroBlog başlatılıyor...")
    print("📍 http://localhost:5000 adresinde çalışıyor")
    app.run(debug=os.environ.get('FLASK_DEBUG') == '1', port=5000)
