# Backfill Planning and Troubleshooting

Use this for both design-time prevention and runtime recovery.

## 1) Plan to prevent known failures

- Confirm execution path first:
  - If runtime traces point to bundle workspace paths, include bundle redeploy/sync in your validation plan.
- Keep run-cell compatibility:
  - Avoid hard dependency on `__file__`.
  - Avoid `raise SystemExit(main())` in entrypoints executed by run-cell wrappers.
- Design volume-safe I/O:
  - For `/Volumes/...`, include `dbutils.fs` fallback for mkdir/write/read paths.
- Design SQL/merge safety:
  - Quote identifiers with backticks.
  - Avoid `UPDATE SET *` / `INSERT *`; build explicit, quoted mappings.
  - Deduplicate source by merge key before merge.
- Design schema-drift behavior:
  - Preserve `_ingestion_ts` and `_source_file`.
  - Normalize raw source keys to deterministic Delta-safe names before first-write bootstrap/merge.
  - Resolve base + `%` collisions to semantic aliases (`*_count`, `*_pct`) before hashed suffix fallback.
  - Persist only drift/unmapped payload into `_rescued_data` (JSON) in Bronze.
  - On first-write bootstrap, avoid `CTAS SELECT *` from raw source columns; use normalized Delta-compatible columns.
- Keep batch backfill runtime-safe:
  - Do not assume batch `cloudFiles` availability; include JSON batch fallback.

## 2) Signature → fix map

| Error signature | Fix |
|---|---|
| `NameError: __file__ is not defined` | Add fallback import bootstrap via `sys.argv[0]` and `Path.cwd()`. |
| `SystemExit: 0` with successful logs | Remove `raise SystemExit(main())` and call `main()` directly. |
| `OSError: [Errno 95] ... /Volumes/...` | Switch affected I/O to `dbutils.fs`. |
| `[INVALID_IDENTIFIER]` | Backtick-quote all identifier components. |
| `[CF_INCORRECT_BATCH_USAGE]` | Use/fallback to batch JSON read path. |
| `[DELTA_MERGE_UNRESOLVED_EXPRESSION]` | Replace wildcard merge clauses with explicit mapping. |
| `[DELTA_MULTIPLE_SOURCE_ROW_MATCHING_TARGET_ROW_IN_MERGE]` | Dedupe source rows per key before MERGE. |
| `[DELTA_INVALID_CHARACTERS_IN_COLUMN_NAMES]` | Normalize raw source keys to Delta-safe physical columns before bootstrap/merge. |
| Unexpected hashed metric aliases | Update normalization to promote semantic aliases before hash fallback. |

## 3) Completion checks

- Logs include expected completion markers.
- Backfill checkpoint state advanced.
- Bronze table sanity check passes (row movement + recent `_source_file`).
