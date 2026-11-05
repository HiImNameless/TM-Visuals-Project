# Calendar migration recovery

The forward migration was recovered from the session's complete SQL output, rather than recreated from memory. Its SHA-256 is `e754bd155ae6ae3b97b4a422c6d582fb3be164fa07587803b42167707588a7b1`. All 15 function bodies matched the running local calendar sandbox.

- Forward: `migrations/20261104204723_calendar_time_blocks.sql`.
- Rollback: `rollback/20261104204723_calendar_time_blocks.sql`.
- Backup helper: `../scripts/Backup-TMVisualsDatabase.ps1`.

The migration is explicitly allowed by the root `.gitignore`; keep these SQL files and the helper in version control. Database exports contain sensitive information and belong outside the repository.

## Create a fresh database export

Pause writes through the app and website, and avoid schema changes during the export. Start Docker Desktop. From the repository root:

```powershell
.\scripts\Backup-TMVisualsDatabase.ps1
```

Open the main project (`fswyeuiajsbdlkhhydnx`) in Supabase, click **Connect**, select **Session pooler**, and copy the PostgreSQL URI with the database password filled in. Use port **5432**. Paste it at the script's hidden prompt; do not send it through chat. Special characters in the password must be URL-encoded. The default direct connection needs IPv6, which was unavailable on this computer.

The helper pins Supabase CLI 3.0.0 and uses its verified `--remote=<URI>` syntax. It validates the project and creates timestamped `roles.sql`, `schema.sql`, and `data.sql` under `Documents/TM-Visuals-Backups`. `COMPLETE.json` is written only after all three exports finish successfully and contain data; it records file hashes. This indicates export completion, not a verified restoration. The three exports are separate snapshots. Keep writes paused throughout them.

The connection URI is hidden from console output and command history, but is passed to the CLI as a process argument while it runs. Keep the files and credentials private. Copy the completed backup folder to a second secure location.

Uploaded Storage files (PDFs, photos, videos), project settings, managed-schema customizations, and migration history need separate consideration for a full-project restore. Test restoration in an isolated database before relying on exports as a recovery method. Supabase's guide: https://supabase.com/docs/guides/platform/migrating-within-supabase/backup-restore

## Rollback

The rollback restores the five previous booking/calendar functions captured from the main database before migration, removes the ten new functions and manual-block table, and removes the newly added anonymous private-schema access. It preserves bookings, users, invoices, slots, and whole-day availability records. Saved manual blocked-time ranges are deleted when their table is removed.

Stop the updated app and website before rollback, and restore matching application versions afterward. Run SQL with error-stop enabled; the rollback wraps its changes in a transaction. If the forward migration was applied through a migration-history runner, repair its history record as part of rollback before reapplying; running SQL alone does not update the migration history.

## Verification performed

The migration and rollback were run against a separate local verification database using a dummy booking. Shared availability included a 10:00–12:00 closure and a reservation's one-hour travel buffers. Rollback removed the new objects, restored the original private-schema access, and preserved the booking, its slot link, and all 32 generated day slots.

## Main project application

On 4 November 2026, the user explicitly authorized proceeding without a fresh full backup because the database contains sample data and its password was unavailable. The reviewed SQL was applied to `fswyeuiajsbdlkhhydnx` through Supabase MCP as migration `20261104204723_calendar_time_blocks`. The local filenames were aligned with that recorded version; the forward SQL hash did not change.

Post-application checks confirmed the four public APIs exist, the manual-block table has RLS, anonymous users cannot read block rows or save availability, and authenticated users cannot directly insert block rows. A transaction tested administrator block saving, public availability reading, and nonadministrator denial, then rolled back. The test left no dates or blocks behind. Counts remained 20 bookings, 231 slots, and 19 whole-day availability records. Security advisory categories and counts remained unchanged from the preflight review.

No fresh full main-database backup was created. The rollback script has been tested locally but has not been run on main. If rollback is needed, coordinate its application with restoring the previous app/website versions and removing the applied migration-history entry for version `20261104204723` through the supported migration-history repair workflow.
