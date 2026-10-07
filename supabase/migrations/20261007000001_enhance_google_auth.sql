-- ==============================================================================
-- MIGRATION: ENHANCE GOOGLE AUTH TRIGGER & AVATAR HANDLING
-- ==============================================================================

-- Perbarui fungsi trigger handle_new_user() agar dapat menangkap metadata Google OAuth secara optimal:
-- nama_lengkap dari full_name / name / given_name
-- avatar_url dari picture / avatar_url
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    assigned_role user_role := 'peserta';
    user_name TEXT;
    user_avatar TEXT;
    raw_role TEXT;
BEGIN
    -- 1. Deteksi Role dari metadata atau default ke 'peserta'
    raw_role := LOWER(COALESCE(new.raw_user_meta_data->>'role', 'peserta'));
    IF raw_role IN ('peserta', 'perusahaan', 'admin') THEN
        assigned_role := raw_role::user_role;
    ELSE
        assigned_role := 'peserta';
    END IF;

    -- 2. Ambil nama lengkap (kompatibel Google OAuth, Apple, Email SignUp)
    user_name := COALESCE(
        new.raw_user_meta_data->>'nama_lengkap', 
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'name',
        split_part(COALESCE(new.email, 'Pengguna'), '@', 1)
    );

    -- 3. Ambil avatar URL (kompatibel Google profile picture)
    user_avatar := COALESCE(
        new.raw_user_meta_data->>'avatar_url',
        new.raw_user_meta_data->>'picture'
    );

    -- 4. Upsert ke public.profiles
    INSERT INTO public.profiles (id, email, nama_lengkap, role, avatar_url)
    VALUES (new.id, COALESCE(new.email, ''), user_name, assigned_role, user_avatar)
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        nama_lengkap = COALESCE(EXCLUDED.nama_lengkap, public.profiles.nama_lengkap),
        avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);

    -- 5. Insert ke detail profil sesuai role jika belum ada
    IF assigned_role = 'peserta' THEN
        INSERT INTO public.peserta_details (user_id) 
        VALUES (new.id)
        ON CONFLICT (user_id) DO NOTHING;
    ELSIF assigned_role = 'perusahaan' THEN
        INSERT INTO public.perusahaan_details (user_id, nama_perusahaan) 
        VALUES (new.id, COALESCE(new.raw_user_meta_data->>'nama_perusahaan', user_name))
        ON CONFLICT (user_id) DO NOTHING;
    END IF;

    -- 6. Kirim notifikasi sambutan selamat datang
    INSERT INTO public.notifikasi (user_id, judul, pesan, tipe)
    VALUES (
        new.id,
        'Selamat Datang di Aplikasi Magang!',
        'Akun Anda berhasil terhubung via Google. Silakan eksplorasi lowongan dan lengkapi profil.',
        'success'
    );

    RETURN new;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Error pada handle_new_user trigger: %', SQLERRM;
        RETURN new;
END;
$$;
