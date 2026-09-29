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

    const { peserta_id } = await req.json();

    if (!peserta_id) {
      return new Response(JSON.stringify({ error: "Missing peserta_id" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Ambil semua logbook peserta
    const { data: logs, error: logsError } = await supabase
      .from("kegiatan_magang")
      .select("*")
      .eq("peserta_id", peserta_id)
      .order("tanggal", { ascending: false });

    if (logsError) throw logsError;

    const totalLogs = logs?.length || 0;
    const selesaiCount = logs?.filter((l) => l.status_kegiatan === "selesai").length || 0;
    const berjalanCount = logs?.filter((l) => l.status_kegiatan === "berjalan").length || 0;
    const totalHours = logs?.reduce((acc, curr) => acc + (parseFloat(curr.durasi_jam) || 0), 0) || 0;

    // Asumsi standar magang: target 480 jam (3 bulan x 20 hari x 8 jam)
    const targetHours = 480;
    const progressPercentage = Math.min(100, Math.round((totalHours / targetHours) * 100));

    return new Response(
      JSON.stringify({
        success: true,
        summary: {
          total_kegiatan: totalLogs,
          kegiatan_selesai: selesaiCount,
          kegiatan_berjalan: berjalanCount,
          total_jam: totalHours,
          target_jam: targetHours,
          persentase_selesai: progressPercentage,
          kegiatan_terbaru: logs?.slice(0, 5) || [],
        },
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
