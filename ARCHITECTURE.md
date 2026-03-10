# Arsitektur Sistem ESI Pipeline

## Alur Bisnis (Business Flow)

```
PHASE 1 — RFI
─────────────
Inquiry Masuk
     │
     ▼
[RFI Tracker] ──► Qualified? ──► Tidak ──► Tidak Dilanjutkan
                      │
                      ▼ Ya
              [Converted Bridge]
                      │
                      ▼
PHASE 2 — PROPOSAL
──────────────────
              [Request Form / RFP]
                      │ (auto-create)
                      ▼
              [Status Tracker]
                      │
                      ▼
                  Disetujui?
                      │
                      ▼ Ya
              [Approved Bridge]
                      │
                      ▼
PHASE 3 — PROJECT
─────────────────
              [Data Project] ◄─── auto-create ─── [MONEV 4-Gate]
                      │                                   │
                      ▼                             Gate sync
              [Weekly Update]                       progress %
                      │
                      ▼
DELIVERABLE
───────────
        [Project Report Tracker]
        [Research Documentation]
```

## Arsitektur Data

```
localStorage (browser)          Supabase (PostgreSQL)
──────────────────────          ─────────────────────
e3_rfi      ──────────────────► rfi
e3_cv       ──────────────────► converted
e3_rfp      ──────────────────► rfp
e3_st       ──────────────────► status_tracker
e3_ap       ──────────────────► approved
e3_pj       ──────────────────► projects
e3_mn       ──────────────────► monev
e3_wk       ──────────────────► weekly
e4_pr       ──────────────────► project_report
e4_rd       ──────────────────► research_doc
```

## Komponen Frontend

```
pipeline.html
├── Sidebar navigation (sticky, scrollable)
├── Topbar (sticky, frosted glass)
├── Pages (10 halaman, show/hide via JS)
│   ├── #pg-dashboard    — Master Dashboard + KPI + Funnel
│   ├── #pg-rfi          — RFI Tracker
│   ├── #pg-converted    — Bridge 1→2
│   ├── #pg-rfp          — Request Form
│   ├── #pg-status       — Status Tracker
│   ├── #pg-approved     — Bridge 2→3
│   ├── #pg-projects     — Data Project
│   ├── #pg-monev        — MONEV 4-Gate
│   ├── #pg-weekly       — Weekly Update
│   ├── #pg-projreport   — Project Report Tracker
│   └── #pg-resdoc       — Research Documentation
├── Modal (single modal, re-used for all forms)
└── Toast notification system

dashboard.html
├── Sidebar navigation
├── Topbar
├── Pages (6 halaman)
│   ├── Executive Summary  — KPI + Funnel + Donut Chart
│   ├── RFI & Inquiry
│   ├── Proposal & Status
│   ├── Active Projects
│   ├── Project Report
│   └── Research Docs
└── Reads data from same localStorage keys
```

## Auto-sync Logic

| Event | Efek Otomatis |
|-------|---------------|
| RFI status → "Converted to Proposal" | Entry baru di `converted` |
| RFP disimpan | Entry baru di `status_tracker` |
| Status proposal → "Disetujui" | Entry baru di `approved` |
| Project baru dibuat | Entry baru di `monev` + `project_report` |
| MONEV gate diupdate | `progress` project = (gate ✅ count × 25)% |
