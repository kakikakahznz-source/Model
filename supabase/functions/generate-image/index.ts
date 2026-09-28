import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) return json({ error: "OPENAI_API_KEY is not configured on the server" }, 500);

  try {
    const body = await req.json();
    const prompt = typeof body.prompt === "string" ? body.prompt.trim() : "";
    const imageData = typeof body.imageData === "string" ? body.imageData : "";

    if (prompt.length < 5 || prompt.length > 4000) {
      return json({ error: "Prompt must be between 5 and 4000 characters" }, 400);
    }
    if (!/^data:image\/(png|jpe?g|webp);base64,/i.test(imageData)) {
      return json({ error: "A PNG, JPEG, or WebP image is required" }, 400);
    }

    const match = imageData.match(/^data:(image\/(?:png|jpe?g|webp));base64,(.+)$/i);
    if (!match) return json({ error: "Invalid image data" }, 400);
    const mime = match[1].toLowerCase().replace("jpg", "jpeg");
    const bytes = Uint8Array.from(atob(match[2]), (c) => c.charCodeAt(0));
    if (bytes.byteLength > 10 * 1024 * 1024) {
      return json({ error: "Image must be smaller than 10 MB" }, 413);
    }

    const form = new FormData();
    form.append("model", "gpt-image-1");
    form.append("prompt", prompt);
    form.append("size", "1024x1024");
    form.append("quality", "medium");
    form.append("image", new Blob([bytes], { type: mime }), `input.${mime.split("/")[1]}`);

    const response = await fetch("https://api.openai.com/v1/images/edits", {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}` },
      body: form,
    });
    const result = await response.json();
    if (!response.ok) {
      console.error("OpenAI image error", response.status, result);
      return json({ error: "Image generation failed", detail: result?.error?.message ?? "OpenAI request failed" }, response.status);
    }

    const b64 = result?.data?.[0]?.b64_json;
    if (!b64) return json({ error: "OpenAI returned no image" }, 502);
    return json({ imageData: `data:image/png;base64,${b64}` });
  } catch (error) {
    console.error("generate-image error", error);
    return json({ error: "Invalid request" }, 400);
  }
});
