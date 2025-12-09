import { useState, useEffect, useRef } from 'react';
import './App.css';

function App() {

  // --- STATES ---
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [showLoginModal, setShowLoginModal] = useState(false);

  // YENİ: Kullanıcının seçtiği kategoriler
  const [selectedCategories, setSelectedCategories] = useState([
    'Teknoloji','Finans','Spor','Siyaset'
  ]);

  // YENİ: Kategori seçim modali
  const [showCategoryModal, setShowCategoryModal] = useState(false);

  const [activeCategory, setActiveCategory] = useState('Tümü');
  const [currentPlayingId, setCurrentPlayingId] = useState(null);

  const audioRef = useRef(new Audio());

  // --- FETCH NEWS ---
  useEffect(() => {
    const fetchNews = async () => {
      try {
        const API_URL = "https://cwok4mgh9k.execute-api.us-east-1.amazonaws.com/prod/news";
        const response = await fetch(API_URL);
        const data = await response.json();
        if (data && data.length > 0) setNews(data);
      } catch (e) {
        console.error("API Error:", e);
      } finally {
        setLoading(false);
      }
    };
    fetchNews();
  }, []);

  // --- Filtrelenmiş Haberler ---
  const filteredNews = activeCategory === 'Tümü'
    ? news.filter(n => selectedCategories.includes(n.category))
    : news.filter(n => n.category === activeCategory);

  // --- Audio ---
  const togglePlay = (id) => {
    const item = news.find(n => (n.news_id || n.id) === id);
    if (!item || !item.ses_url) return;

    const player = audioRef.current;

    if (currentPlayingId === id) {
      player.pause();
      setCurrentPlayingId(null);
    } else {
      player.src = item.ses_url;
      player.play();
      setCurrentPlayingId(id);
    }

    player.onended = () => setCurrentPlayingId(null);
  };

  // YENİ: Kullanıcı giriş yaptığında kategori seçim aç
  const handleLogin = () => {
    setIsLoggedIn(true);
    setShowLoginModal(false);
    setShowCategoryModal(true);
  };

  // YENİ: Checkbox değişikliği
  const toggleCategory = (cat) => {
    if (selectedCategories.includes(cat)) {
      setSelectedCategories(prev => prev.filter(c => c !== cat));
    } else {
      setSelectedCategories(prev => [...prev, cat]);
    }
  };

  return (
    <div className="dashboard-layout">

      {/* --- SIDEBAR --- */}
      <aside className="sidebar">
        <div className="logo"><span>⚡</span> Briefly.ai</div>

        <div className="menu-label">Haber Akışı</div>

        <div className="menu-items">
          <button
            className={`menu-btn ${activeCategory === 'Tümü' ? 'active' : ''}`}
            onClick={() => setActiveCategory('Tümü')}
          >
            🏠 Genel Bakış
          </button>

          {/* YENİ: Kullanıcının seçtiği kategoriler listeleniyor */}
          {selectedCategories.map(cat => (
            <button
              key={cat}
              className={`menu-btn ${activeCategory === cat ? 'active' : ''}`}
              onClick={() => setActiveCategory(cat)}
            >
              {cat === 'Teknoloji' && '💻 Teknoloji'}
              {cat === 'Finans' && '📈 Finans'}
              {cat === 'Spor' && '⚽ Spor'}
              {cat === 'Siyaset' && '🏛️ Siyaset'}
            </button>
          ))}
        </div>

        {/* User */}
        {!isLoggedIn ? (
          <div className="user-section" style={{ justifyContent: 'center' }}>
            <button className="login-btn" onClick={() => setShowLoginModal(true)}>Giriş Yap</button>
          </div>
        ) : (
          <div className="user-section">
            <div className="avatar">A</div>
            <div>
              <div style={{ fontSize: '0.9rem' }}>Ahmet Yılmaz</div>
              <div
                style={{ fontSize: '0.75rem', color: '#64748b', cursor: 'pointer' }}
                onClick={() => setIsLoggedIn(false)}
              >
                Çıkış Yap
              </div>
            </div>
          </div>
        )}
      </aside>

      {/* --- MAIN CONTENT --- */}
      <main className="main-content">
        <header className="header">
          <div className="page-title">
            <h1>{activeCategory === 'Tümü' ? 'Günün Özetleri' : `${activeCategory} Haberleri`}</h1>
            <p>Bugün sizin için {filteredNews.length} önemli başlık var.</p>
          </div>
        </header>

        {loading ? (
          <div>Yükleniyor...</div>
        ) : (
          <div className="news-grid">
            {filteredNews.map(item => (
              <div key={item.news_id || item.id} className="news-card">
                <div className="category-tag">{item.category}</div>
                <h3>{item.title}</h3>
                <p>{item.summary}</p>

                <div className="card-footer">
                  <a href={item.url} target="_blank" rel="noopener noreferrer" className="read-more-link">
                    Haberi Oku ↗
                  </a>

                  <button
                    className={`play-button ${currentPlayingId === (item.news_id || item.id) ? 'playing' : ''}`}
                    onClick={() => togglePlay(item.news_id || item.id)}
                  >
                    {currentPlayingId === (item.news_id || item.id) ? '⏸ Durdur' : '▶️ Dinle'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* --- LOGIN MODAL --- */}
      {showLoginModal && (
        <div className="modal-overlay">
          <div className="modal-box">
            <h2>Giriş Yap</h2>
            <input type="email" placeholder="E-Posta" />
            <input type="password" placeholder="Şifre" />
            <button className="login-btn" onClick={handleLogin}>Giriş Yap</button>
            <div className="close-btn" onClick={() => setShowLoginModal(false)}>Kapat</div>
          </div>
        </div>
      )}

      {/* --- KATEGORİ SEÇİM MODAL --- */}
      {showCategoryModal && (
        <div className="modal-overlay">
          <div className="modal-box">
            <h2>Hangi Haberleri Görmek İstersiniz?</h2>

            {['Teknoloji','Finans','Spor','Siyaset'].map(cat => (
              <label className="checkbox-item" key={cat}>
                <input
                  type="checkbox"
                  checked={selectedCategories.includes(cat)}
                  onChange={() => toggleCategory(cat)}
                />
                {cat}
              </label>
            ))}

            <button
              className="login-btn"
              style={{ width:'100%', marginTop: 15 }}
              onClick={() => setShowCategoryModal(false)}
            >
              Kaydet ve Devam Et
            </button>
          </div>
        </div>
      )}

    </div>
  );
}

export default App;
