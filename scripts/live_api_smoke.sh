#!/usr/bin/env bash
# Smoke-tests the live Supabase backend with the public (anon) key, using exactly the
# PostgREST query shapes the Flutter app sends. Fails fast on the first mismatch.
#   SUPABASE_URL=https://xxx.supabase.co SUPABASE_ANON_KEY=sb_publishable_... scripts/live_api_smoke.sh
set -euo pipefail
: "${SUPABASE_URL:?set SUPABASE_URL}"; : "${SUPABASE_ANON_KEY:?set SUPABASE_ANON_KEY}"
U=$SUPABASE_URL; K=$SUPABASE_ANON_KEY
H=(-sS -H "apikey: $K" -H "Authorization: Bearer $K" -H "Content-Type: application/json")
fail() { echo "FAIL: $*" >&2; exit 1; }
pass=0; ok() { echo "ok  - $*"; pass=$((pass+1)); }

# 1. nearby_langars RPC from central Delhi
body=$(curl "${H[@]}" -X POST "$U/rest/v1/rpc/nearby_langars" \
  -d '{"p_lat":28.6315,"p_lng":77.2167,"p_radius_m":25000,"p_open_now":false,"p_limit":100}')
n=$(echo "$body" | jq 'length'); [ "$n" -ge 5 ] || fail "nearby_langars returned $n rows: $body"
first=$(echo "$body" | jq -r '.[0].name'); ID=$(echo "$body" | jq -r '.[0].id')
echo "$body" | jq -e '.[0] | has("distance_m") and has("is_open")' >/dev/null || fail "missing distance_m/is_open"
echo "$body" | jq -e '[.[].distance_m] == ([.[].distance_m] | sort)' >/dev/null || fail "not sorted by distance"
ok "nearby_langars: $n rows, nearest '$first'"

# 2. open-now filter is a subset
n2=$(curl "${H[@]}" -X POST "$U/rest/v1/rpc/nearby_langars" -d '{"p_lat":28.6315,"p_lng":77.2167,"p_open_now":true}' | jq 'length')
[ "$n2" -le "$n" ] || fail "open_now returned more rows ($n2) than unfiltered ($n)"
ok "open_now filter: $n2 of $n"

# 3. langar by id (detail screen select)
cols='id,name,description,lat,lng,address,city,state,photos,contact_phone,donate_upi_id,donate_url,status,submitted_by,rejection_reason,created_at'
curl "${H[@]}" "$U/rest/v1/langars?select=$cols&id=eq.$ID" | jq -e '.[0].status == "approved"' >/dev/null || fail "langar by id"
ok "langar by id"

# 4. timings
t=$(curl "${H[@]}" "$U/rest/v1/langar_timings?select=day_of_week,opens_at,closes_at,is_24h&langar_id=eq.$ID&order=day_of_week,opens_at")
[ "$(echo "$t" | jq 'length')" -ge 7 ] || fail "timings: $t"
ok "timings: $(echo "$t" | jq 'length') rows"

# 5. seva_slots with the `joined` computed column (must be 200 even if empty)
code=$(curl "${H[@]}" -o /tmp/slots.json -w '%{http_code}' "$U/rest/v1/seva_slots?select=id,langar_id,title,description,starts_at,ends_at,capacity,joined&langar_id=eq.$ID&order=starts_at")
[ "$code" = 200 ] || fail "seva_slots joined column HTTP $code: $(cat /tmp/slots.json)"
ok "seva_slots + joined computed column"

# 6/7. embed syntaxes used by favourites and my-seva screens
for q in "favourites?select=langars($cols)" "seva_signups?select=seva_slots(id,langar_id,title,description,starts_at,ends_at,capacity,joined,langars(name))&status=eq.joined"; do
  code=$(curl "${H[@]}" -o /tmp/embed.json -w '%{http_code}' "$U/rest/v1/$q")
  [ "$code" = 200 ] || fail "embed '$q' HTTP $code: $(cat /tmp/embed.json)"
done
ok "favourites and seva_signups embeds parse"

# 8/9. RLS: anon sees no pending langars, no profiles
[ "$(curl "${H[@]}" "$U/rest/v1/langars?select=id&status=eq.pending" | jq 'length')" = 0 ] || fail "pending langars visible to anon"
[ "$(curl "${H[@]}" "$U/rest/v1/profiles?select=id" | jq 'length')" = 0 ] || fail "profiles visible to anon"
ok "RLS hides pending langars and profiles from anon"

# 10. anon cannot insert
code=$(curl "${H[@]}" -o /dev/null -w '%{http_code}' -X POST "$U/rest/v1/langars" -d '{"name":"smoke","lat":1,"lng":1}')
[ "$code" = 401 ] || [ "$code" = 403 ] || fail "anon insert returned HTTP $code"
ok "anon insert rejected ($code)"

# 11. storage bucket is public (missing object -> 400/404, never 403)
code=$(curl -sS -o /dev/null -w '%{http_code}' "$U/storage/v1/object/public/langar-photos/does-not-exist.jpg")
[ "$code" = 400 ] || [ "$code" = 404 ] || fail "storage public read HTTP $code"
ok "storage bucket public read ($code)"

# 12. edge function refuses anon
code=$(curl "${H[@]}" -o /dev/null -w '%{http_code}' -X POST "$U/functions/v1/delete-account")
[ "$code" = 401 ] || fail "delete-account with anon key returned HTTP $code"
ok "delete-account rejects anon (401)"

# 13. trigger functions are not exposed as RPC
code=$(curl "${H[@]}" -o /dev/null -w '%{http_code}' -X POST "$U/rest/v1/rpc/langars_guard" -d '{}')
[ "$code" != 200 ] || fail "langars_guard callable via RPC"
ok "trigger function not callable via RPC ($code)"

# 14. submit_langar is for signed-in users only
code=$(curl "${H[@]}" -o /dev/null -w '%{http_code}' -X POST "$U/rest/v1/rpc/submit_langar" -d '{"p":{"name":"smoke","lat":1,"lng":1}}')
[ "$code" = 401 ] || [ "$code" = 403 ] || fail "anon submit_langar returned HTTP $code"
ok "submit_langar rejects anon ($code)"

# 15. nearby_langars clamps an abusive limit/radius instead of scanning everything
n3=$(curl "${H[@]}" -X POST "$U/rest/v1/rpc/nearby_langars" -d '{"p_lat":28.6315,"p_lng":77.2167,"p_radius_m":1e12,"p_limit":1000000}' | jq 'length')
[ "$n3" -le 200 ] || fail "nearby_langars returned $n3 rows for a huge limit"
ok "nearby_langars clamps radius/limit ($n3 rows)"

# 16. the seva capacity trigger is not exposed as RPC
code=$(curl "${H[@]}" -o /dev/null -w '%{http_code}' -X POST "$U/rest/v1/rpc/seva_signup_guard" -d '{}')
[ "$code" != 200 ] || fail "seva_signup_guard callable via RPC"
ok "seva_signup_guard not callable via RPC ($code)"

echo "ALL $pass CHECKS PASSED"
