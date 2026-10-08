#!/usr/bin/env bash
# Restores and validates the upload keystore from CI secrets. Never prints secret values.
# Env: KS_B64, KS_PASS, KEY_PASS, KEY_ALIAS. Writes android/app/upload-keystore.p12 and android/key.properties.
set -euo pipefail
out=android/app
fail() { echo "::error::$*"; exit 1; }
[ -n "${KS_B64:-}" ]   || fail "Secret ANDROID_KEYSTORE_BASE64 is empty or missing."
[ -n "${KS_PASS:-}" ]  || fail "Secret ANDROID_KEYSTORE_PASSWORD is empty or missing."
KEY_PASS=${KEY_PASS:-$KS_PASS}
KEY_ALIAS=$(printf '%s' "${KEY_ALIAS:-upload}" | tr -d '[:space:]'); KEY_ALIAS=${KEY_ALIAS:-upload}
# Pasting into the GitHub UI can add spaces, CR or line breaks: strip them before decoding.
if ! printf '%s' "$KS_B64" | tr -d ' \r\n\t' | base64 -d > "$out/upload-keystore.src" 2>/dev/null; then
  fail "ANDROID_KEYSTORE_BASE64 is not valid base64. Paste the full contents of upload-keystore.base64.txt."
fi
echo "Decoded keystore: $(stat -c %s "$out/upload-keystore.src") bytes, sha256 $(sha256sum "$out/upload-keystore.src" | cut -c1-16)"
if ! keytool -list -keystore "$out/upload-keystore.src" -storepass "$KS_PASS" >/dev/null 2>&1; then
  fail "Keystore could not be opened. Either ANDROID_KEYSTORE_BASE64 is not the full base64 text, or ANDROID_KEYSTORE_PASSWORD is wrong."
fi
if ! keytool -list -keystore "$out/upload-keystore.src" -storepass "$KS_PASS" -alias "$KEY_ALIAS" >/dev/null 2>&1; then
  fail "Keystore opened, but it has no key named '$KEY_ALIAS'. Set ANDROID_KEY_ALIAS to the right alias (usually: upload)."
fi
# Normalise to PKCS12: Gradle's bundle signer can fail on legacy JKS with "Tag number over 30".
keytool -importkeystore -noprompt -srckeystore "$out/upload-keystore.src" -srcstorepass "$KS_PASS" \
  -srcalias "$KEY_ALIAS" -srckeypass "$KEY_PASS" \
  -destkeystore "$out/upload-keystore.p12" -deststoretype PKCS12 -deststorepass "$KS_PASS" -destkeypass "$KS_PASS" >/dev/null 2>&1 \
  || fail "Key '$KEY_ALIAS' could not be read. ANDROID_KEY_PASSWORD is probably wrong (it is usually the same as the keystore password)."
rm -f "$out/upload-keystore.src"
cat > android/key.properties <<PROPS
storePassword=$KS_PASS
keyPassword=$KS_PASS
keyAlias=$KEY_ALIAS
storeFile=upload-keystore.p12
PROPS
echo "Upload keystore OK (alias '$KEY_ALIAS', converted to PKCS12)."
