# Changelog

## 1.0.0+1 (unreleased)
- First release: map + list of nearby langars, timings and open-now filter, directions, call, share, donate (UPI/website), seva slots, add-a-langar with admin review, favourites, phone OTP / Google / Apple sign-in, account deletion, English / Hindi / Punjabi.
- Fix: signed-out Profile screen, seva Join button and dialog action buttons crashed on layout because the theme forced filled buttons to infinite width.
- Store screenshots for en / hi / pa in `store/screenshots/`, generated from the real widgets by `tool/store_screenshots_test.dart`.
- Fix: overnight timings (e.g. 20:00–02:00) showed "open" on the wrong night. They now cover the evening they start and the next early morning, in the app and in the `nearby_langars` RPC.
- Fix: approving a langar from the Supabase dashboard reset it to pending. Trusted server roles now bypass the review guard.
- Fix: seva slots could be overbooked and ended slots joined. A row-locking trigger enforces capacity, and the app shows a clear message. Join/Leave ignores repeat taps while a request is in flight.
- Fix: a failed timings insert left a half-saved langar that a retry duplicated. Submissions now go through one `submit_langar` transaction.
- Hardening: length/format checks for UPI IDs, https-only donate links, phone, text fields and reports; photo URLs must be in the submitter's own storage folder; `nearby_langars` clamps radius and limit. The form validates the same rules before sending.
