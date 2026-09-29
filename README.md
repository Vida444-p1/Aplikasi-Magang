<<<<<<< HEAD
# Aplikasi-Magang
=======
# 🚀 Aplikasi Magang (Prototipe Terpadu)

**Versi:** 1.0 (Berdasarkan PRD v1.0)  
**Techstack Utama:** 
- **Frontend / Client:** Flutter (Web & Multiplatform)
- **Backend & Database:** Supabase (PostgreSQL, Supabase Auth, Row Level Security, Storage Buckets)
- **Serverless API:** Supabase Edge Functions (TypeScript / Deno)
- **State Management:** Flutter Riverpod
- **Routing:** GoRouter

---

## 📌 Ringkasan Sistem

Aplikasi Magang merupakan platform digital terpadu untuk menghubungkan **Mahasiswa/Peserta Magang**, **Perusahaan/Instansi**, dan **Admin/Koordinator Kampus** dalam 3 pilar fungsional utama:
1. **Pencarian Lowongan Magang**: Penemuan lowongan lengkap dengan filter posisi, bidang, lokasi, sistem kerja (WFO/WFH/Hybrid), kuota, dan deadline.
2. **Pendaftaran Peserta**: Pengajuan berkas (CV, surat rekomendasi, portofolio) dengan status terstruktur (*Menunggu* $\rightarrow$ *Diproses* $\rightarrow$ *Diterima* / *Ditolak*).
3. **Monitoring Kegiatan (Logbook)**: Pencatatan harian jam kerja dan aktivitas magang peserta, dilengkapi perhitungan progres otomatis serta catatan umpan balik pembimbing.

---

## 📂 Struktur Proyek

```text
Aplikasi Magang/
├── .env                              # Variabel lingkungan (Supabase URL & Anon Key)
├── .env.example                      # Contoh template kredensial
├── pubspec.yaml                      # Konfigurasi dependensi Flutter
│
├── web/                              # Konfigurasi Flutter Web
│   ├── index.html                    # Entry point HTML dengan font & loading spinner
│   └── manifest.json                 # Web App Manifest
│
├── lib/
│   ├── main.dart                     # Entry point Flutter & inisialisasi Riverpod
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── router/app_router.dart    # Konfigurasi routing GoRouter
│   │   ├── theme/app_theme.dart      # Design system & palet warna modern
│   │   └── utils/supabase_config.dart # Inisialisasi klien Supabase
│   ├── models/                       # Data Model & Serializer JSON
│   │   ├── profile_model.dart        # UserProfile, PesertaProfile, PerusahaanProfile
│   │   ├── vacancy_model.dart        # Lowongan Magang
│   │   ├── application_model.dart    # Berkas Pendaftaran & Status
│   │   ├── activity_model.dart       # Logbook Harian & Monitoring
│   │   └── notification_model.dart   # In-app Notification
│   ├── services/                     # Layanan Komunikasi Supabase & Edge Function
│   │   ├── auth_service.dart
│   │   ├── vacancy_service.dart
│   │   ├── application_service.dart
│   │   ├── activity_service.dart
│   │   └── notification_service.dart
│   ├── providers/                    # Riverpod State Management
│   │   ├── auth_provider.dart        # Session & Switch Role Demo
│   │   ├── vacancy_provider.dart     # Filter, Search, & List Lowongan
│   │   ├── application_provider.dart
│   │   └── activity_provider.dart
│   ├── widgets/                      # Komponen UI Reusable
│   │   ├── app_sidebar.dart          # Navigasi samping responsif + role switcher
│   │   ├── responsive_scaffold.dart  # Wrapper Scaffold Web & Mobile
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── stat_card.dart
│   │   └── status_badge.dart
│   └── views/                        # Halaman Antarmuka (3 Peran)
│       ├── auth/                     # Login & Register
│       ├── peserta/                  # Dashboard, Lowongan, Detail, Apply, Status, Logbook, Profil
│       ├── perusahaan/               # Dashboard, Kelola Lowongan, Form Lowongan, Pelamar, Monitoring
│       ├── admin/                    # Dashboard, Manajemen User, Lowongan, Rekap Logbook
│       └── common/                   # Pusat Notifikasi
│
└── supabase/
    ├── migrations/
    │   └── 20260928000001_initial_schema.sql # Skema PostgreSQL, RLS, & Trigger Auth
    └── functions/
        ├── update-application-status/index.ts # Edge Function pengubah status & auto-notif
        ├── generate-logbook-summary/index.ts  # Edge Function rekapitulasi progres logbook
        └── send-notification/index.ts         # Edge Function pengirim notifikasi
```

---

## 🛠️ Langkah-Langkah Menjalankan Proyek

### 1. Persiapan Database Supabase
1. Buat proyek baru di [Supabase Dashboard](https://supabase.com).
2. Buka menu **SQL Editor** pada dashboard Supabase.
3. Salin seluruh isi file [`supabase/migrations/20260928000001_initial_schema.sql`](file:///c:/FSD/Aplikasi%20Magang/supabase/migrations/20260928000001_initial_schema.sql) dan klik **Run**.
4. Skema tabel, Row Level Security (RLS), trigger pembuatan profil otomatis, dan storage bucket (`documents` & `activity-attachments`) akan langsung terpasang.

### 2. Konfigurasi Edge Functions
Jika Anda memiliki Supabase CLI yang terpasang:
```bash
supabase functions deploy update-application-status
supabase functions deploy generate-logbook-summary
supabase functions deploy send-notification
```

### 3. Konfigurasi File Lingkungan (.env)
Buka file `.env` di direktori proyek dan masukkan URL serta Anon Key dari proyek Supabase Anda:
```env
SUPABASE_URL=https://<your-project-id>.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

### 4. Menjalankan Aplikasi Flutter Web
Pastikan Flutter SDK terpasang di komputer Anda. Jalankan perintah berikut:
```bash
# 1. Ambil paket dependensi
flutter pub get

# 2. Jalankan aplikasi pada browser Chrome
flutter run -d chrome
```

---

## 🎭 Fitur Demonstrasi Role Cepat (Demo Switcher)

Untuk memudahkan presentasi dan evaluasi pengujian tanpa perlu repot logout-login berulang kali, aplikasi dilengkapi **Peralihan Role Instan**:
* Klik chip role **Peserta**, **Perusahaan**, atau **Admin** di sidebar kiri atau halaman login untuk langsung merasakan perspektif dan fitur masing-masing pengguna secara real-time.
>>>>>>> 07b969e (Update)
