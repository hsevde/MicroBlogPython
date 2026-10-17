// MicroBlog JavaScript

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener('DOMContentLoaded', function() {
    
    // Fotoğraf önizleme fonksiyonu
    const imageInput = document.getElementById('imageInput');
    const imagePreview = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    const removeImageBtn = document.getElementById('removeImage');
    
    if (imageInput) {
        imageInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            
            if (file) {
                // Dosya boyutu kontrolü (16MB)
                if (file.size > 16 * 1024 * 1024) {
                    alert('Dosya boyutu 16MB\'den küçük olmalıdır!');
                    this.value = '';
                    return;
                }
                
                // Dosya tipi kontrolü
                const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp'];
                if (!allowedTypes.includes(file.type)) {
                    alert('Sadece PNG, JPG, JPEG, GIF ve WEBP formatları desteklenmektedir!');
                    this.value = '';
                    return;
                }
                
                // Önizleme göster
                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImg.src = e.target.result;
                    imagePreview.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        });
        
        // Fotoğraf kaldırma
        if (removeImageBtn) {
            removeImageBtn.addEventListener('click', function() {
                imageInput.value = '';
                imagePreview.style.display = 'none';
                previewImg.src = '';
            });
        }
    }
    
    // Beğeni butonları
    document.querySelectorAll('.like-btn').forEach(btn => {
        btn.addEventListener('click', async function() {
            const postId = this.dataset.postId;
            const icon = this.querySelector('i');
            const countSpan = this.querySelector('.like-count');
            
            try {
                const response = await fetch(`/like/${postId}`, {
                    method: 'POST',
                    headers: {
                        'X-CSRFToken': csrfToken
                    }
                });
                
                const data = await response.json();
                
                if (data.error) {
                    alert(data.error);
                    return;
                }
                
                // Sayıyı güncelle
                countSpan.textContent = data.like_count;
                
                // İkon rengini değiştir
                if (data.action === 'liked') {
                    icon.classList.remove('bi-heart');
                    icon.classList.add('bi-heart-fill');
                    icon.style.color = '#e0245e';
                } else {
                    icon.classList.remove('bi-heart-fill');
                    icon.classList.add('bi-heart');
                    icon.style.color = '';
                }
            } catch (error) {
                console.error('Beğeni hatası:', error);
            }
        });
    });
    
    // Yorum butonları - tıklandığında yorumları yükle
    document.querySelectorAll('[data-bs-toggle="collapse"]').forEach(btn => {
        btn.addEventListener('click', async function() {
            const target = this.dataset.bsTarget;
            const postId = target.replace('#comments-', '');
            const commentsList = document.getElementById(`comments-list-${postId}`);
            
            // Zaten yüklendiyse tekrar yükleme
            if (commentsList.dataset.loaded === 'true') return;
            
            try {
                const response = await fetch(`/comments/${postId}`);
                const data = await response.json();
                
                if (data.error) {
                    commentsList.innerHTML = `<div class="text-danger small">${escapeHtml(data.error)}</div>`;
                    return;
                }
                
                if (data.comments.length === 0) {
                    commentsList.innerHTML = '<div class="text-muted small text-center py-2">Henüz yorum yok</div>';
                } else {
                    let html = '';
                    data.comments.forEach(comment => {
                        html += `
                            <div class="comment-item d-flex mb-2">
                                <div class="flex-shrink-0">
                                    <div class="bg-secondary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px; font-size: 0.8rem;">
                                        ${escapeHtml(comment.display_name[0])}
                                    </div>
                                </div>
                                <div class="flex-grow-1 ms-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <strong class="small">${escapeHtml(comment.display_name)}</strong>
                                            <small class="text-muted ms-1">${escapeHtml(comment.created_at)}</small>
                                        </div>
                                        ${comment.can_delete ? `
                                            <button class="btn btn-sm btn-link text-danger p-0 delete-comment-btn" 
                                                    data-comment-id="${comment.id}"
                                                    data-post-id="${postId}">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        ` : ''}
                                    </div>
                                    <p class="mb-0 small mt-1">${escapeHtml(comment.content)}</p>
                                </div>
                            </div>
                        `;
                    });
                    commentsList.innerHTML = html;
                    
                    // Silme butonlarına event listener ekle
                    commentsList.querySelectorAll('.delete-comment-btn').forEach(btn => {
                        btn.addEventListener('click', async function() {
                            if (!confirm('Bu yorumu silmek istediğinize emin misiniz?')) return;
                            
                            const commentId = this.dataset.commentId;
                            const postId = this.dataset.postId;
                            
                            try {
                                const response = await fetch(`/comment/delete/${commentId}`, {
                                    method: 'POST',
                                    headers: {
                                        'X-CSRFToken': csrfToken
                                    }
                                });
                                
                                const data = await response.json();
                                
                                if (data.success) {
                                    // Yorumu DOM'dan sil
                                    this.closest('.comment-item').remove();
                                    
                                    // Yorum sayısını güncelle
                                    const commentBtn = document.querySelector(`[data-bs-target="#comments-${postId}"]`);
                                    if (commentBtn) {
                                        const countText = commentBtn.textContent.trim();
                                        const currentCount = parseInt(countText.match(/\d+/)[0]);
                                        commentBtn.innerHTML = `<i class="bi bi-chat"></i> ${currentCount - 1}`;
                                    }
                                } else {
                                    alert(data.error || 'Yorum silinemedi');
                                }
                            } catch (error) {
                                console.error('Silme hatası:', error);
                                alert('Bir hata oluştu');
                            }
                        });
                    });
                }
                
                commentsList.dataset.loaded = 'true';
            } catch (error) {
                console.error('Yorum yükleme hatası:', error);
                commentsList.innerHTML = '<div class="text-danger small">Yorumlar yüklenemedi</div>';
            }
        });
    });
});
