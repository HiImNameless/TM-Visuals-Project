# Brandon's restored admin features

This Flutter checkout restores the admin calendar, whole-day date availability and uploading an existing invoice PDF. It uses the team's Provider/MVVM structure. The existing Bookings, Profile, Settings, Portfolio, Service and Invoice List implementations are linked through routes and retain their existing behavior.

## Where to edit

| Responsibility | Files |
| --- | --- |
| Calendar UI | `lib/views/calendar.dart` |
| Whole-day editor UI | `lib/views/date_manager.dart` |
| Calendar data and state | `lib/models/calendar_model.dart`, `lib/services/calendar_service.dart`, `lib/viewmodels/calendar_viewmodel.dart`, `lib/viewmodels/date_availability_viewmodel.dart` |
| Shared booked-session preview | `lib/widgets/admin_widgets.dart` |
| Bottom navigation | `lib/widgets/admin_bottom_nav.dart` |
| PDF upload UI | `lib/views/add_invoice.dart` |
| Invoice data and state | Existing `lib/models/add_invoice_model.dart`, completed `lib/services/add_invoice_service.dart` and `lib/viewmodels/add_invoice_view_model.dart` |
| More menu | `lib/views/admin_more.dart` |
| Admin authentication | `lib/services/admin_auth_service.dart`, `lib/viewmodels/admin_auth_viewmodel.dart`, `lib/views/admin_entry.dart`, `lib/views/admin_sign_in.dart` |
| App providers/theme and route registration | `lib/app.dart`, `lib/routes/route_manager.dart` |
| Bootstrap only | `lib/main.dart` |

The gold bottom bar on Brandon's main screens links Bookings, Calendar, Profile and More. More links Upload invoice, the team's existing Invoice List, Portfolio, Services and Settings. Existing team pages keep their own bottom bars; their implementations were not refactored. Use Back to return from those pages. Returning to Calendar refreshes its data.

## Run

`config/supabase.local.json` contains the project URL and public publishable key and is git-ignored. The example is safe to commit. Never put secret/service-role keys in a Flutter application.

```powershell
flutter pub get
flutter run --dart-define-from-file=config/supabase.local.json
```

When this Flutter app folder is open in VS Code, use **TM Visuals (local Supabase config)**. Stop and restart after configuration changes; hot reload does not update Dart defines. Without settings, the app shows setup instructions. With settings, it opens admin sign-in, then Calendar after trusted `public.admin` membership is checked. An existing saved admin session opens Calendar directly.

## Database contract and behavior

Uses the previously deployed project `fswyeuiajsbdlkhhydnx`: `users`, `admin` (singular), `client`, `booking`, `booking_slot`, `time_slot`, `date_availability` and `invoice`, plus the private `invoices` Storage bucket. This restoration does not change hosted data, create accounts or reapply database policies.

The existing admin migration and whole-day availability migration must remain installed. Availability reads use `date_availability(slot_date,is_available)`. Saves upsert one date with `updated_by` set to the signed-in admin's ID. Missing date overrides mean available. Closed dates are grey even when reserved. The editor freshly loads all selected-date bookings and uses the same sorted preview as Calendar. Closing a date preserves reservations and their time ranges; existing database guards reject new reservations/reactivation on closed dates. Dates use South African business dates without UTC-converting SQL dates.

PDF uploads require a booking, a reference of 1–120 characters and a file with a `.pdf` extension and `%PDF-` header, at most 10 MiB. The persistent path is `<admin_id>/<booking_id>/<invoice_id>.pdf`. Opening the uploaded PDF requests a five-minute signed URL. The team's existing Invoice List is not replaced; its database integration remains that page's responsibility. The upload confirmation offers **Open PDF** directly.

Repeated submissions while busy are blocked. An uncertain upload retains its PDF and stable invoice ID. Leaving/reopening the form resumes that attempt during the same authorized app session, preserving its booking, reference and PDF. Details are cleared after successful completion when starting another invoice, or when the authorized session ends. Gateway/transport failures never trigger PDF cleanup. Only definite first-attempt SQL rejection codes permit cleanup. Closing the application ends in-memory recovery; inspect saved invoices before starting another upload after an unresolved interruption.

## Verification

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --dart-define-from-file=config/supabase.local.json
```

Verified with Flutter 3.41.6 / Dart 3.11.4. `video_player` uses `^2.11.1` for compatibility with that SDK. PDF picker native support requires iOS 14; native targets and macOS network/selected-file permissions are updated. Apple/Android native builds require their toolchains and have not been exercised on this Windows machine.

The suite covers month request races, availability failure/retry, closing/reopening booked dates, Cancel, shared previews, navigation return refresh, sign-in/membership/sign-out, PDF validation, duplicate-submit prevention, stable/resumable attempts, canonical Storage paths, gateway timeouts and late invoice commits. `test/admin_previews_test.dart` renders sample-data screenshots to `build/admin-previews`; it adds no database records. For readable previews, set `FLUTTER_ROOT` to your SDK path before running that test.

The configured web release build and 18 tests passed. Full analysis reports one existing `withOpacity` deprecation in the team's Profile page; the restored files have no findings. The supplied public configuration reached Supabase Auth with HTTP 200. A real signed-in PDF upload still requires testing with an existing admin account; no account credentials were requested or created.

Reference: [Supabase Flutter initialization](https://supabase.com/docs/reference/dart/initializing), [private Storage access](https://supabase.com/docs/guides/storage/security/access-control).
