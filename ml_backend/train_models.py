import os
import joblib
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import SVC
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_absolute_error, r2_score, accuracy_score

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")
os.makedirs(MODELS_DIR, exist_ok=True)

def train_linear_regression():
    print("[1/4] Training Linear Regression (Prediksi Uang Saku Magang)...")
    np.random.seed(42)
    n_samples = 400
    
    # Fitur:
    # 0: durasi_bulan (1 - 12)
    # 1: jam_per_minggu (20 - 45)
    # 2: jumlah_skills (1 - 10)
    # 3: industri_tier (1: Pendidikan/Lokal, 2: Manufaktur/Kreatif, 3: Teknologi/Fintech)
    # 4: tipe_kerja (1: WFH, 2: Hybrid, 3: WFO)
    durasi = np.random.randint(1, 13, size=n_samples)
    jam = np.random.randint(20, 46, size=n_samples)
    skills = np.random.randint(1, 11, size=n_samples)
    industri = np.random.choice([1, 2, 3], size=n_samples, p=[0.25, 0.35, 0.40])
    tipe_kerja = np.random.choice([1, 2, 3], size=n_samples, p=[0.20, 0.50, 0.30])
    
    # Formula dasar: base + jam*40rb + skills*150rb + industri*500rb + tipe_kerja*200rb + noise
    base_stipend = 1200000
    noise = np.random.normal(0, 150000, size=n_samples)
    uang_saku = (
        base_stipend
        + (jam * 45000)
        + (skills * 160000)
        + (industri * 650000)
        + (tipe_kerja * 250000)
        + noise
    )
    # Batasi minimal 1.000.000 dan bulatkan ke 50.000 terdekat
    uang_saku = np.maximum(1000000, uang_saku)
    uang_saku = np.round(uang_saku / 50000) * 50000
    
    X = np.column_stack([durasi, jam, skills, industri, tipe_kerja])
    y = uang_saku
    
    model = LinearRegression()
    model.fit(X, y)
    
    preds = model.predict(X)
    r2 = r2_score(y, preds)
    mae = mean_absolute_error(y, preds)
    print(f"   Linear Regression trained. R2 Score: {r2:.4f}, MAE: Rp {mae:,.0f}")
    
    model_path = os.path.join(MODELS_DIR, "linear_regression_stipend.joblib")
    joblib.dump(model, model_path)
    print(f"   Saved to {model_path}")
    return model

def train_logistic_regression():
    print("[2/4] Training Logistic Regression (Prediksi Kelolosan Seleksi Magang)...")
    np.random.seed(42)
    n_samples = 500
    
    # Fitur:
    # 0: ipk (2.0 - 4.0)
    # 1: kesesuaian_jurusan (0 = tidak relevan, 1 = relevan)
    # 2: matching_skills_count (0 - 8)
    # 3: skor_portofolio (30 - 100)
    # 4: pengalaman_organisasi (0 - 5 kali)
    # Feature distributions
    ipk = np.random.uniform(2.3, 4.0, size=n_samples)
    kesesuaian = np.random.choice([0, 1], size=n_samples, p=[0.4, 0.6])
    skills = np.random.randint(0, 9, size=n_samples)
    portofolio = np.random.uniform(30, 95, size=n_samples)
    organisasi = np.random.randint(0, 6, size=n_samples)
    
    # Balanced logit score centered around 0
    score = (
        ((ipk - 3.1) * 2.2)
        + ((kesesuaian - 0.5) * 1.8)
        + ((skills - 3.5) * 0.45)
        + ((portofolio - 65) * 0.05)
        + ((organisasi - 2) * 0.3)
    )
    prob = 1 / (1 + np.exp(-score))
    y = (prob >= 0.5).astype(int)
    print(f"   Class distribution: Diterima (1) = {np.sum(y == 1)}, Ditolak (0) = {np.sum(y == 0)}")
    
    X = np.column_stack([ipk, kesesuaian, skills, portofolio, organisasi])
    
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('classifier', LogisticRegression(random_state=42))
    ])
    pipeline.fit(X, y)
    
    preds = pipeline.predict(X)
    acc = accuracy_score(y, preds)
    print(f"   Logistic Regression trained. Accuracy: {acc * 100:.2f}%")
    
    model_path = os.path.join(MODELS_DIR, "logistic_regression_kelulusan.joblib")
    joblib.dump(pipeline, model_path)
    print(f"   Saved to {model_path}")
    return pipeline

def train_naive_bayes():
    print("[3/4] Training Naive Bayes (Klasifikasi Kategori Minat & Sentimen Logbook)...")
    
    # Sub-model A: Klasifikasi Bidang Pekerjaan / Domain Magang dari Teks
    domain_data = [
        ("Membuat aplikasi mobile Flutter, integrasi REST API, Dart, state management Riverpod", "Mobile Development"),
        ("Membangun backend service menggunakan Python FastAPI, Node.js, PostgreSQL, Docker", "Backend Development"),
        ("Mendesain wireframe, mockup aplikasi, prototype figma, usability testing, user research", "UI/UX Design"),
        ("Analisis data dengan Pandas, Machine Learning Scikit-Learn, data visualization, SQL", "Data Science & AI"),
        ("Mengelola campaign media sosial, SEO, content writing, copywriting Instagram TikTok", "Digital Marketing"),
        ("Rekrutmen kandidat, screening CV peserta magang, onboarding karyawan, human capital", "Human Resources"),
        ("Frontend web development React, Vue, HTML, CSS responsive design, Tailwind", "Frontend Development"),
        ("QA testing, automation test, bug report, test case cypress selenium", "Quality Assurance"),
        ("DevOps CI/CD pipeline, AWS cloud infrastructure, Kubernetes, Linux server", "DevOps & Cloud"),
        ("Financial report, analisis keuangan, pembukuan, rekonsiliasi kas bank", "Finance & Accounting"),
        
        # Tambahan variasi kata
        ("Flutter developer android ios firebase dart mobile responsive", "Mobile Development"),
        ("Python developer flask django microservice mysql redis api", "Backend Development"),
        ("Figma user interface user experience design system prototype wireframing", "UI/UX Design"),
        ("Machine learning deep learning data analysis python tableau powerbi", "Data Science & AI"),
        ("Social media marketing ads meta google ads content creator copywriting", "Digital Marketing"),
        ("Recruiter HR talent acquisition talent management wawancara interview", "Human Resources"),
        ("Reactjs Nextjs html css javascript typescript web designer", "Frontend Development"),
        ("Software tester manual testing unit test automated testing bug hunter", "Quality Assurance"),
    ]
    
    texts = [item[0] for item in domain_data]
    labels = [item[1] for item in domain_data]
    
    pipeline_domain = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1)),
        ('nb', MultinomialNB(alpha=0.5))
    ])
    pipeline_domain.fit(texts, labels)
    
    # Sub-model B: Sentimen Logbook Aktivitas Peserta
    sentiment_data = [
        ("Berhasil menyelesaikan modul autentikasi dan tes berjalan lancar tanpa error", "Positif"),
        ("Mendapat feedback sangat bagus dari mentor mengenai desain mockup figma", "Positif"),
        ("Selesai tepat waktu dan fitur berhasil di-deploy ke staging server", "Positif"),
        ("Sangat senang bisa belajar teknologi baru dan implementasi sukses hari ini", "Positif"),
        ("Fitur telah selesai dikerjakan sesuai sprint backlog", "Positif"),
        ("Mengikuti meeting evaluasi mingguan dengan tim dan mendiskusikan roadmap", "Netral"),
        ("Menghadiri standup harian dan memaparkan progres pekerjaan hari ini", "Netral"),
        ("Membaca dokumentasi API dan mempelajari alur kerja sistem", "Netral"),
        ("Melakukan koordinasi dengan rekan tim terkait pembagian tugas", "Netral"),
        ("Menulis catatan review dan merangkum hasil diskusi dengan mentor", "Netral"),
        ("Mengalami kendala saat migrasi database dan butuh bantuan mentor segera", "Kendala"),
        ("Terjadi error fatal pada server dan belum menemukan solusinya", "Kendala"),
        ("Koneksi jaringan kantor terputus sehingga pekerjaan terhambat hari ini", "Kendala"),
        ("Kesulitan memahami instruksi tugas dan merasa tertinggal dari timeline", "Kendala"),
        ("Bug belum terpecahkan sejak kemarin dan membutuhkan arahan lebih lanjut", "Kendala"),
    ]
    
    sent_texts = [item[0] for item in sentiment_data]
    sent_labels = [item[1] for item in sentiment_data]
    
    pipeline_sentiment = Pipeline([
        ('tfidf', TfidfVectorizer(ngram_range=(1, 2), min_df=1)),
        ('nb', MultinomialNB(alpha=0.5))
    ])
    pipeline_sentiment.fit(sent_texts, sent_labels)
    
    nb_bundle = {
        'domain_classifier': pipeline_domain,
        'sentiment_classifier': pipeline_sentiment,
    }
    
    model_path = os.path.join(MODELS_DIR, "naive_bayes_bundle.joblib")
    joblib.dump(nb_bundle, model_path)
    print(f"   Naive Bayes models trained. Saved bundle to {model_path}")
    return nb_bundle

def train_svm():
    print("[4/4] Training SVM (Support Vector Machine - Evaluasi Kecocokan Kandidat)...")
    np.random.seed(42)
    n_samples = 450
    
    # Fitur:
    # 0: skill_match_score (0.0 - 100.0)
    # 1: tes_teknis_score (0.0 - 100.0)
    # 2: wawancara_score (0.0 - 100.0)
    # 3: jumlah_proyek_relevan (0 - 10)
    # 4: ipk_score (50 - 100) -> e.g. IPK 3.5 -> 87.5
    skill = np.random.uniform(40, 100, size=n_samples)
    teknis = np.random.uniform(35, 100, size=n_samples)
    wawancara = np.random.uniform(40, 100, size=n_samples)
    proyek = np.random.randint(0, 8, size=n_samples)
    ipk_norm = np.random.uniform(60, 100, size=n_samples)
    
    # Score komposit
    composite = (
        (skill * 0.35)
        + (teknis * 0.30)
        + (wawancara * 0.20)
        + (proyek * 3.5)
        + (ipk_norm * 0.15)
    )
    
    # Kategori SVM:
    # 0: Kurang Sesuai
    # 1: Cukup Sesuai
    # 2: Sangat Cocok
    labels = []
    for c in composite:
        if c >= 78.0:
            labels.append("Sangat Cocok")
        elif c >= 60.0:
            labels.append("Cukup Sesuai")
        else:
            labels.append("Kurang Sesuai")
    
    X = np.column_stack([skill, teknis, wawancara, proyek, ipk_norm])
    y = np.array(labels)
    
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('svm', SVC(kernel='rbf', C=1.0, probability=True, random_state=42))
    ])
    pipeline.fit(X, y)
    
    preds = pipeline.predict(X)
    acc = accuracy_score(y, preds)
    print(f"   SVM Classifier trained. Accuracy: {acc * 100:.2f}%")
    
    model_path = os.path.join(MODELS_DIR, "svm_candidate_matcher.joblib")
    joblib.dump(pipeline, model_path)
    print(f"   Saved to {model_path}")
    return pipeline

if __name__ == "__main__":
    print("=" * 60)
    print("  MEMULAI PELATIHAN 4 MODEL MACHINE LEARNING MAGANG")
    print("=" * 60)
    train_linear_regression()
    train_logistic_regression()
    train_naive_bayes()
    train_svm()
    print("=" * 60)
    print("  SEMUA MODEL BERHASIL DILATIH & DISIMPAN DI ml_backend/models/")
    print("=" * 60)
