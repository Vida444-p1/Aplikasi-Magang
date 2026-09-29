-- ==============================================================================
-- DATABASE SCHEMA: APLIKASI MAGANG (PRD v1.0)
-- Techstack: Supabase (PostgreSQL), Edge Functions, Flutter Client
-- ==============================================================================

-- 1. ENUMS
CREATE TYPE user_role AS ENUM ('peserta', 'perusahaan', 'admin');
CREATE TYPE sistem_kerja AS ENUM ('wfo', 'wfh', 'hybrid');
CREATE TYPE status_lowongan AS ENUM ('aktif', 'ditutup');
CREATE TYPE status_pendaftaran AS ENUM ('menunggu', 'diproses', 'diterima', 'ditolak');
CREATE TYPE status_kegiatan AS ENUM ('berjalan', 'selesai');

-- 2. TABEL PROFILES (Terkoneksi langsung dengan auth.users Supabase)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    nama_lengkap TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'peserta',
    nomor_telepon TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL PESERTA DETAILS
CREATE TABLE IF NOT EXISTS public.peserta_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    nim TEXT,
    program_studi TEXT,
    universitas TEXT,
    alamat TEXT,
    keahlian TEXT[],
    cv_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL PERUSAHAAN DETAILS
CREATE TABLE IF NOT EXISTS public.perusahaan_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    nama_perusahaan TEXT NOT NULL,
    industri TEXT,
    alamat TEXT,
    website TEXT,
    deskripsi TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL LOWONGAN MAGANG
CREATE TABLE IF NOT EXISTS public.lowongan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    perusahaan_id UUID NOT NULL REFERENCES public.perusahaan_details(id) ON DELETE CASCADE,
    posisi TEXT NOT NULL,
    bidang TEXT NOT NULL,
    deskripsi TEXT NOT NULL,
    tanggung_jawab TEXT,
    persyaratan TEXT NOT NULL,
    lokasi TEXT NOT NULL,
    sistem_kerja sistem_kerja NOT NULL DEFAULT 'wfo',
    durasi_bulan INTEGER NOT NULL DEFAULT 3,
    jadwal TEXT,
    kuota INTEGER NOT NULL DEFAULT 1,
    batas_pendaftaran DATE NOT NULL,
    status status_lowongan NOT NULL DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TABEL PENDAFTARAN
CREATE TABLE IF NOT EXISTS public.pendaftaran (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lowongan_id UUID NOT NULL REFERENCES public.lowongan(id) ON DELETE CASCADE,
    peserta_id UUID NOT NULL REFERENCES public.peserta_details(id) ON DELETE CASCADE,
    tanggal_daftar TIMESTAMPTZ DEFAULT NOW(),
    cv_url TEXT NOT NULL,
    surat_pengantar_url TEXT,
    portofolio_url TEXT,
    status status_pendaftaran NOT NULL DEFAULT 'menunggu',
    catatan_perusahaan TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(lowongan_id, peserta_id)
);

-- 7. TABEL KEGIATAN MAGANG (LOGBOOK / MONITORING)
CREATE TABLE IF NOT EXISTS public.kegiatan_magang (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    peserta_id UUID NOT NULL REFERENCES public.peserta_details(id) ON DELETE CASCADE,
    lowongan_id UUID REFERENCES public.lowongan(id) ON DELETE SET NULL,
    tanggal DATE NOT NULL,
    judul_kegiatan TEXT NOT NULL,
    deskripsi_kegiatan TEXT NOT NULL,
    durasi_jam NUMERIC(4, 1) NOT NULL DEFAULT 8.0,
    status_kegiatan status_kegiatan NOT NULL DEFAULT 'selesai',
    catatan_pembimbing TEXT,
    lampiran_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TABEL NOTIFIKASI
CREATE TABLE IF NOT EXISTS public.notifikasi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    judul TEXT NOT NULL,
    pesan TEXT NOT NULL,
    tipe TEXT NOT NULL DEFAULT 'info',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    link_target TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.peserta_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.perusahaan_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lowongan ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pendaftaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kegiatan_magang ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifikasi ENABLE ROW LEVEL SECURITY;

-- Helper Function untuk cek Role
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS user_role AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Profiles: Siapapun terautentikasi dapat membaca profile, pemilik dan admin dapat mengedit
CREATE POLICY "Profiles readable by authenticated users"
ON public.profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Profiles update by owner or admin"
ON public.profiles FOR UPDATE TO authenticated
USING (auth.uid() = id OR public.get_my_role() = 'admin');

-- Peserta Details:
CREATE POLICY "Peserta details readable by authenticated"
ON public.peserta_details FOR SELECT TO authenticated USING (true);

CREATE POLICY "Peserta details update by owner or admin"
ON public.peserta_details FOR ALL TO authenticated
USING (user_id = auth.uid() OR public.get_my_role() = 'admin');

-- Perusahaan Details:
CREATE POLICY "Perusahaan details readable by authenticated"
ON public.perusahaan_details FOR SELECT TO authenticated USING (true);

CREATE POLICY "Perusahaan details manage by owner or admin"
ON public.perusahaan_details FOR ALL TO authenticated
USING (user_id = auth.uid() OR public.get_my_role() = 'admin');

-- Lowongan:
CREATE POLICY "Lowongan viewable by authenticated"
ON public.lowongan FOR SELECT TO authenticated USING (true);

CREATE POLICY "Lowongan manageable by company owner or admin"
ON public.lowongan FOR ALL TO authenticated
USING (
    perusahaan_id IN (SELECT id FROM public.perusahaan_details WHERE user_id = auth.uid())
    OR public.get_my_role() = 'admin'
);

-- Pendaftaran:
CREATE POLICY "Pendaftaran viewable by participant, company, or admin"
ON public.pendaftaran FOR SELECT TO authenticated
USING (
    peserta_id IN (SELECT id FROM public.peserta_details WHERE user_id = auth.uid())
    OR lowongan_id IN (
        SELECT l.id FROM public.lowongan l
        JOIN public.perusahaan_details p ON l.perusahaan_id = p.id
        WHERE p.user_id = auth.uid()
    )
    OR public.get_my_role() = 'admin'
);

CREATE POLICY "Pendaftaran insertable by peserta"
ON public.pendaftaran FOR INSERT TO authenticated
WITH CHECK (
    peserta_id IN (SELECT id FROM public.peserta_details WHERE user_id = auth.uid())
);

CREATE POLICY "Pendaftaran status update by company or admin"
ON public.pendaftaran FOR UPDATE TO authenticated
USING (
    lowongan_id IN (
        SELECT l.id FROM public.lowongan l
        JOIN public.perusahaan_details p ON l.perusahaan_id = p.id
        WHERE p.user_id = auth.uid()
    )
    OR public.get_my_role() = 'admin'
);

-- Kegiatan Magang:
CREATE POLICY "Kegiatan viewable by peserta, mentor company, or admin"
ON public.kegiatan_magang FOR SELECT TO authenticated
USING (
    peserta_id IN (SELECT id FROM public.peserta_details WHERE user_id = auth.uid())
    OR lowongan_id IN (
        SELECT l.id FROM public.lowongan l
        JOIN public.perusahaan_details p ON l.perusahaan_id = p.id
        WHERE p.user_id = auth.uid()
    )
    OR public.get_my_role() = 'admin'
);

CREATE POLICY "Kegiatan manageable by peserta"
ON public.kegiatan_magang FOR ALL TO authenticated
USING (
    peserta_id IN (SELECT id FROM public.peserta_details WHERE user_id = auth.uid())
    OR public.get_my_role() = 'admin'
);

-- Notifikasi:
CREATE POLICY "Notifikasi manageable by receiver"
ON public.notifikasi FOR ALL TO authenticated
USING (user_id = auth.uid());

-- ==============================================================================
-- 10. TRIGGER AUTO-CREATE PROFILE ON AUTH.USER SIGNUP
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    assigned_role user_role;
    user_name TEXT;
BEGIN
    assigned_role := COALESCE((new.raw_user_meta_data->>'role')::user_role, 'peserta');
    user_name := COALESCE(new.raw_user_meta_data->>'nama_lengkap', split_part(new.email, '@', 1));

    INSERT INTO public.profiles (id, email, nama_lengkap, role)
    VALUES (new.id, new.email, user_name, assigned_role);

    IF assigned_role = 'peserta' THEN
        INSERT INTO public.peserta_details (user_id) VALUES (new.id);
    ELSIF assigned_role = 'perusahaan' THEN
        INSERT INTO public.perusahaan_details (user_id, nama_perusahaan) 
        VALUES (new.id, COALESCE(new.raw_user_meta_data->>'nama_perusahaan', user_name));
    END IF;

    -- Kirim notifikasi selamat datang
    INSERT INTO public.notifikasi (user_id, judul, pesan, tipe)
    VALUES (
        new.id,
        'Selamat Datang di Aplikasi Magang!',
        'Akun Anda berhasil dibuat. Silakan lengkapi profil Anda untuk memulai.',
        'success'
    );

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pasang trigger pada auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 11. STORAGE BUCKETS (Dijalankan via Supabase Dashboard / SQL Script)
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public) 
VALUES ('documents', 'documents', true) 
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('activity-attachments', 'activity-attachments', true) 
ON CONFLICT (id) DO NOTHING;
