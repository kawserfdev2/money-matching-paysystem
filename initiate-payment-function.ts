// // Supabase Edge Function: initiate-payment
// // Deploy with: supabase functions deploy initiate-payment

// import "https://deno.land/x/functions_framework/mod.ts";
// import { createClient } from "https://esm.sh/@supabase/supabase-core@2";

// const supabase = createClient(
//     Deno.env.get("SUPABASE_URL")!,
//     Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
// );

// const corsHeaders = {
//     "Access-Control-Allow-Origin": "*",
//     "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
// };

// Deno.serve(async (req) => {
//     // 1. Handle CORS
//     if (req.method === "OPTIONS") {
//         return new Response("ok", { headers: corsHeaders });
//     }

//     try {
//         // 2. Authenticate using Secret Key
//         const authHeader = req.headers.get("Authorization");
//         if (!authHeader || !authHeader.startsWith("Bearer ")) {
//             return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
//         }
//         const secretKey = authHeader.split(" ")[1];

//         // 3. Find brand associated with this key
//         const { data: keyData, error: keyError } = await supabase
//             .from("api_keys")
//             .select("brand_id, is_sandbox")
//             .eq("secret_key", secretKey)
//             .single();

//         if (keyError || !keyData) {
//             return new Response(JSON.stringify({ error: "Invalid API Key" }), { status: 401, headers: corsHeaders });
//         }

//         // 4. Parse request body
//         const { amount, currency, customer_email, success_url, cancel_url } = await req.json();

//         // 5. Create payment record
//         const { data: payment, error: payError } = await supabase
//             .from("payments")
//             .insert({
//                 amount,
//                 currency: currency || "BDT",
//                 customer_email,
//                 status: "pending",
//                 gateway: "api",
//                 is_sandbox: keyData.is_sandbox,
//                 metadata: {
//                     success_url,
//                     cancel_url,
//                     brand_id: keyData.brand_id
//                 }
//             })
//             .select()
//             .single();

//         if (payError) {
//             return new Response(JSON.stringify({ error: payError.message }), { status: 400, headers: corsHeaders });
//         }

//         // 6. Return Checkout URL
//         // Here we assume `/pay/:id` is the public route
//         const checkout_url = `https://your-amarpay-site.com/pay/${payment.id}`;

//         return new Response(
//             JSON.stringify({ checkout_url, payment_id: payment.id }),
//             { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
//         );

//     } catch (err) {
//         return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
//     }
// });

