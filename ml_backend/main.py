import os
import joblib
import numpy as np
from typing import Dict, Any, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# Inisialisasi FastAPI
app = FastAPI(
    title="Aplikasi Magang AI & Machine Learning Microservice",
    description="REST API untuk 4 Algoritma Machine Learning (Linear Regression, Logistic Regression, Naive Bayes, SVM)",
    version="1.0.0",
)

# CORS Middleware agar bisa diakses oleh Flutter (Web, Mobile, Desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODELS_DIR = os.path.join(os.path.dirname(__file__), "models")

# Load Models
models: Dict[str, Any] = {}

def load_all_models():
    try:
        models["linear_reg"] = joblib.load(os.path.join(MODELS_DIR, "linear_regression_stipend.joblib"))
        models["logistic_reg"] = joblib.load(os.path.join(MODELS_DIR, "logistic_regression_kelulusan.joblib"))
        models["naive_bayes"] = joblib.load(os.path.join(MODELS_DIR, "naive_bayes_bundle.joblib"))
        models["svm"] = joblib.load(os.path.join(MODELS_DIR, "svm_candidate_matcher.joblib"))
        print("[OK] Semua 4 model Machine Learning berhasil dimuat!")
    except Exception as e:
        print(f"[ERROR] Gagal memuat model: {e}")

load_all_models()

# ==========================================
# PYDANTIC SCHEMAS
# ==========================================

# 1. Linear Regression Schema
class LinearRegressionInput(BaseModel):
    durasi_bulan: int = Field(default=3, ge=1, le=12, description="Durasi magang dalam bulan (1 - 12)")
    jam_per_minggu: int = Field(default=40, ge=10, le=50, description="Jam kerja per minggu (10 - 50)")
    jumlah_skills: int = Field(default=4, ge=1, le=15, description="Jumlah skills yang disyaratkan")
    industri: str = Field(default="Teknologi", description="Pendidikan, Manufaktur, atau Teknologi")
    tipe_kerja: str = Field(default="Hybrid", description="WFH, Hybrid, atau WFO")

# 2. Logistic Regression Schema
class LogisticRegressionInput(BaseModel):
    ipk: float = Field(default=3.5, ge=2.0, le=4.0, description="IPK Mahasiswa (2.0 - 4.0)")
    kesesuaian_jurusan: bool = Field(default=True, description="Apakah jurusan linier dengan posisi")
    matching_skills_count: int = Field(default=4, ge=0, le=10, description="Berapa banyak skill kandidat yang match")
    skor_portofolio: float = Field(default=80.0, ge=0.0, le=100.0, description="Skor kelayakan portofolio (0 - 100)")
    pengalaman_organisasi: int = Field(default=2, ge=0, le=10, description="Jumlah pengalaman organisasi/kepanitiaan")

# 3. Naive Bayes Schema
class TextInput(BaseModel):
    text: str = Field(..., min_length=3, description="Teks deskripsi diri/keahlian atau catatan logbook harian")

# 4. SVM Schema
class SVMInput(BaseModel):
    skill_match_score: float = Field(default=85.0, ge=0.0, le=100.0, description="Skor kecocokan skill (0 - 100)")
    tes_teknis_score: float = Field(default=80.0, ge=0.0, le=100.0, description="Skor tes teknis/asesmen (0 - 100)")
    wawancara_score: float = Field(default=82.0, ge=0.0, le=100.0, description="Skor wawancara/softskill (0 - 100)")
    jumlah_proyek_relevan: int = Field(default=3, ge=0, le=15, description="Jumlah proyek/portofolio yang relevan")
    ipk: float = Field(default=3.6, ge=2.0, le=4.0, description="IPK Mahasiswa")

# 5. Comprehensive Schema
class ComprehensiveInput(BaseModel):
    nama_kandidat: str = Field(default="Budi Santoso")
    posisi_tujuan: str = Field(default="Flutter Mobile Developer")
    ipk: float = Field(default=3.65, ge=2.0, le=4.0)
    kesesuaian_jurusan: bool = Field(default=True)
    matching_skills_count: int = Field(default=5)
    total_skills_required: int = Field(default=6)
    skor_portofolio: float = Field(default=85.0)
    pengalaman_organisasi: int = Field(default=2)
    jam_per_minggu: int = Field(default=40)
    durasi_bulan: int = Field(default=4)
    industri: str = Field(default="Teknologi")
    tipe_kerja: str = Field(default="Hybrid")
    cover_letter: str = Field(default="Saya memiliki keahlian dalam membuat aplikasi mobile Flutter dengan state management Riverpod, integrasi REST API, dan database Supabase.")
    catatan_logbook_terakhir: Optional[str] = Field(default="Berhasil menyelesaikan modul integrasi API dan laporan tes lolos dengan hasil memuaskan.")


# ==========================================
# ENDPOINTS
# ==========================================

@app.get("/")
def root():
    return {
        "status": "online",
        "service": "Magangin AI/ML Microservice",
        "version": "1.0.0",
        "models_available": list(models.keys()),
        "algorithms": [
            "Linear Regression (Prediksi Uang Saku)",
            "Logistic Regression (Prediksi Kelolosan Seleksi)",
            "Naive Bayes (Klasifikasi Kategori & Analisis Sentimen)",
            "Support Vector Machine (Evaluasi Kecocokan Kandidat)"
        ]
    }

@app.get("/api/health")
def health_check():
    loaded = all(k in models for k in ["linear_reg", "logistic_reg", "naive_bayes", "svm"])
    return {
        "status": "healthy" if loaded else "degraded",
        "models_loaded": {k: (k in models) for k in ["linear_reg", "logistic_reg", "naive_bayes", "svm"]}
    }

# ----------------------------------------------------
# 1. LINEAR REGRESSION (Prediksi Uang Saku / Salary)
# ----------------------------------------------------
@app.post("/api/predict/linear-regression")
def predict_stipend(data: LinearRegressionInput):
    if "linear_reg" not in models:
        raise HTTPException(status_code=500, detail="Model Linear Regression belum dimuat")
    
    # Mapping kategori
    industri_map = {"pendidikan": 1, "kreatif": 2, "manufaktur": 2, "teknologi": 3, "fintech": 3}
    ind_tier = industri_map.get(data.industri.lower().strip(), 2)
    
    tipe_map = {"wfh": 1, "hybrid": 2, "wfo": 3}
    tipe_val = tipe_map.get(data.tipe_kerja.lower().strip(), 2)
    
    features = np.array([[
        data.durasi_bulan,
        data.jam_per_minggu,
        data.jumlah_skills,
        ind_tier,
        tipe_val
    ]])
    
    model = models["linear_reg"]
    pred = float(model.predict(features)[0])
    # Minimal 1.000.000 dan bulatkan ke 50.000 terdekat
    stipend = max(1000000, round(pred / 50000) * 50000)
    
    return {
        "algorithm": "Linear Regression (Ordinary Least Squares)",
        "predicted_stipend": stipend,
        "formatted_stipend": f"Rp {stipend:,.0f}".replace(",", "."),
        "input_features": {
            "durasi_bulan": data.durasi_bulan,
            "jam_per_minggu": data.jam_per_minggu,
            "jumlah_skills": data.jumlah_skills,
            "industri": data.industri,
            "tipe_kerja": data.tipe_kerja
        },
        "analysis": f"Berdasarkan jam kerja ({data.jam_per_minggu} jam/minggu), {data.jumlah_skills} kualifikasi skill di industri {data.industri} ({data.tipe_kerja}), rekomendasi uang saku adalah Rp {stipend:,.0f}".replace(",", ".")
    }

# ----------------------------------------------------
# 2. LOGISTIC REGRESSION (Prediksi Kelolosan Seleksi)
# ----------------------------------------------------
@app.post("/api/predict/logistic-regression")
def predict_admission(data: LogisticRegressionInput):
    if "logistic_reg" not in models:
        raise HTTPException(status_code=500, detail="Model Logistic Regression belum dimuat")
    
    features = np.array([[
        data.ipk,
        1 if data.kesesuaian_jurusan else 0,
        data.matching_skills_count,
        data.skor_portofolio,
        data.pengalaman_organisasi
    ]])
    
    pipeline = models["logistic_reg"]
    pred_class = int(pipeline.predict(features)[0])
    probs = pipeline.predict_proba(features)[0]
    prob_accepted = float(probs[1])
    
    percentage = round(prob_accepted * 100, 1)
    status = "Diterima" if prob_accepted >= 0.50 else "Ditolak"
    
    # Rekomendasi perbaikan jika probabilitas rendah
    tips = []
    if data.ipk < 3.2:
        tips.append("Tingkatkan capaian akademik atau sertakan sertifikasi kompetensi pendukung.")
    if data.matching_skills_count < 3:
        tips.append("Pelajari skill spesifik yang tercantum pada kualifikasi lowongan.")
    if data.skor_portofolio < 70:
        tips.append("Lengkapi link proyek nyata atau repositori GitHub di profil.")
    if not tips:
        tips.append("Profil sangat kompetitif dan memenuhi kualifikasi utama.")

    return {
        "algorithm": "Logistic Regression (Sigmoid Classification)",
        "status": status,
        "probability": round(prob_accepted, 4),
        "percentage": percentage,
        "recommendation": tips,
        "is_accepted": (status == "Diterima")
    }

# ----------------------------------------------------
# 3. NAIVE BAYES (Domain Kategori & Sentimen Logbook)
# ----------------------------------------------------
@app.post("/api/predict/naive-bayes/domain")
def classify_domain(data: TextInput):
    if "naive_bayes" not in models:
        raise HTTPException(status_code=500, detail="Model Naive Bayes belum dimuat")
    
    pipeline = models["naive_bayes"]["domain_classifier"]
    pred = pipeline.predict([data.text])[0]
    probs = pipeline.predict_proba([data.text])[0]
    classes = pipeline.classes_
    
    prob_dict = {cls: round(float(p), 4) for cls, p in zip(classes, probs)}
    max_conf = round(float(np.max(probs)), 4)
    
    return {
        "algorithm": "Multinomial Naive Bayes (NLP Classifier)",
        "predicted_domain": pred,
        "confidence": max_conf,
        "top_probabilities": sorted(prob_dict.items(), key=lambda x: x[1], reverse=True)[:3]
    }

@app.post("/api/predict/naive-bayes/sentiment")
def analyze_logbook_sentiment(data: TextInput):
    if "naive_bayes" not in models:
        raise HTTPException(status_code=500, detail="Model Naive Bayes belum dimuat")
    
    pipeline = models["naive_bayes"]["sentiment_classifier"]
    pred = pipeline.predict([data.text])[0]
    probs = pipeline.predict_proba([data.text])[0]
    classes = pipeline.classes_
    
    prob_dict = {cls: round(float(p), 4) for cls, p in zip(classes, probs)}
    
    color_map = {
        "Positif": "#10B981", # green
        "Netral": "#3B82F6",  # blue
        "Kendala": "#EF4444"  # red
    }
    
    advice_map = {
        "Positif": "Pekerjaan berjalan lancar. Pertahankan produktivitas dan kualitas hasil tugas.",
        "Netral": "Aktivitas standar operasional tercatat dengan baik dalam logbook.",
        "Kendala": "Terdeteksi adanya kendala teknis/hambatan. Disarankan menghubungi mentor atau koordinator magang."
    }
    
    return {
        "algorithm": "Multinomial Naive Bayes (Sentiment Analysis)",
        "sentiment": pred,
        "color": color_map.get(pred, "#6B7280"),
        "confidence": round(float(np.max(probs)), 4),
        "advice": advice_map.get(pred, ""),
        "sentiment_probabilities": prob_dict
    }

# ----------------------------------------------------
# 4. SUPPORT VECTOR MACHINE (Candidate-Job Matchmaking)
# ----------------------------------------------------
@app.post("/api/predict/svm")
def evaluate_candidate_match(data: SVMInput):
    if "svm" not in models:
        raise HTTPException(status_code=500, detail="Model SVM belum dimuat")
    
    ipk_norm = (data.ipk / 4.0) * 100.0
    features = np.array([[
        data.skill_match_score,
        data.tes_teknis_score,
        data.wawancara_score,
        data.jumlah_proyek_relevan,
        ipk_norm
    ]])
    
    pipeline = models["svm"]
    pred_class = pipeline.predict(features)[0]
    probs = pipeline.predict_proba(features)[0]
    classes = pipeline.classes_
    prob_dict = {cls: round(float(p), 4) for cls, p in zip(classes, probs)}
    
    badge_colors = {
        "Sangat Cocok": "#10B981",
        "Cukup Sesuai": "#F59E0B",
        "Kurang Sesuai": "#EF4444"
    }
    
    return {
        "algorithm": "Support Vector Machine (RBF Kernel Classifier)",
        "match_tier": pred_class,
        "tier_color": badge_colors.get(pred_class, "#6B7280"),
        "confidence": round(float(np.max(probs)), 4),
        "probabilities": prob_dict,
        "summary": f"Kandidat dikategorikan sebagai '{pred_class}' berdasarkan margin hiperplane SVM pada 5 dimensi penilaian."
    }

# ----------------------------------------------------
# 5. ALL-IN-ONE COMPREHENSIVE INSIGHT
# ----------------------------------------------------
@app.post("/api/predict/comprehensive")
def comprehensive_insight(data: ComprehensiveInput):
    # 1. Linear Regression
    lr_input = LinearRegressionInput(
        durasi_bulan=data.durasi_bulan,
        jam_per_minggu=data.jam_per_minggu,
        jumlah_skills=data.matching_skills_count,
        industri=data.industri,
        tipe_kerja=data.tipe_kerja
    )
    lr_res = predict_stipend(lr_input)
    
    # 2. Logistic Regression
    log_input = LogisticRegressionInput(
        ipk=data.ipk,
        kesesuaian_jurusan=data.kesesuaian_jurusan,
        matching_skills_count=data.matching_skills_count,
        skor_portofolio=data.skor_portofolio,
        pengalaman_organisasi=data.pengalaman_organisasi
    )
    log_res = predict_admission(log_input)
    
    # 3. Naive Bayes (Domain & Sentiment)
    nb_domain = classify_domain(TextInput(text=f"{data.posisi_tujuan} {data.cover_letter}"))
    nb_sentiment = None
    if data.catatan_logbook_terakhir:
        nb_sentiment = analyze_logbook_sentiment(TextInput(text=data.catatan_logbook_terakhir))
        
    # 4. SVM
    skill_pct = min(100.0, (data.matching_skills_count / max(1, data.total_skills_required)) * 100.0)
    svm_input = SVMInput(
        skill_match_score=skill_pct,
        tes_teknis_score=data.skor_portofolio,
        wawancara_score=85.0 if data.kesesuaian_jurusan else 70.0,
        jumlah_proyek_relevan=data.pengalaman_organisasi,
        ipk=data.ipk
    )
    svm_res = evaluate_candidate_match(svm_input)
    
    return {
        "kandidat": data.nama_kandidat,
        "posisi": data.posisi_tujuan,
        "linear_regression": lr_res,
        "logistic_regression": log_res,
        "naive_bayes": {
            "bidang_minat": nb_domain,
            "analisis_logbook": nb_sentiment
        },
        "svm": svm_res
    }
