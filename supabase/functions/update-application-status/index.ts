// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { pendaftaran_id, new_status, catatan } = await req.json();

    if (!pendaftaran_id || !new_status) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: pendaftaran_id, new_status" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Update status pendaftaran
    const { data: updatedApp, error: updateError } = await supabase
      .from("pendaftaran")
      .update({
        status: new_status,
        catatan_perusahaan: catatan || null,
        updated_at: new Date().toISOString(),
      })
      .eq("id", pendaftaran_id)
      .select("*, lowongan:lowongan_id(posisi, perusahaan:perusahaan_id(nama_perusahaan)), peserta:peserta_id(user_id)")
      .single();

    if (updateError || !updatedApp) {
      throw updateError || new Error("Gagal memperbarui status pendaftaran");
    }

    // 2. Kirim notifikasi in-app otomatis ke peserta
    const targetUserId = updatedApp.peserta?.user_id;
    const posisi = updatedApp.lowongan?.posisi ?? "Posisi Magang";
    const namaPerusahaan = updatedApp.lowongan?.perusahaan?.nama_perusahaan ?? "Perusahaan";

    let statusMsg = `Status lamaran Anda untuk "${posisi}" di ${namaPerusahaan} telah diubah menjadi: ${new_status.toUpperCase()}.`;
    if (new_status === "diterima") {
      statusMsg = `🎉 Selamat! Anda DITERIMA magang untuk posisi "${posisi}" di ${namaPerusahaan}. Silakan periksa dashboard Anda dan mulai pencatatan kegiatan magang!`;
    } else if (new_status === "ditolak") {
      statusMsg = `Lamaran Anda untuk posisi "${posisi}" di ${namaPerusahaan} belum dapat diterima saat ini. Jangan berkecil hati, tetap semangat!`;
    }

    if (targetUserId) {
      await supabase.from("notifikasi").insert({
        user_id: targetUserId,
        judul: `Pembaruan Status Lamaran: ${new_status.toUpperCase()}`,
        pesan: statusMsg,
        tipe: new_status === "diterima" ? "success" : new_status === "ditolak" ? "warning" : "info",
        link_target: "/peserta/pendaftaran",
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Status pendaftaran berhasil diperbarui dan notifikasi telah dikirim.",
        data: updatedApp,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
