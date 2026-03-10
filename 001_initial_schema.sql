-- ============================================================
--  ESI PIPELINE — Supabase PostgreSQL Schema  v3
--  Compatible: PostgreSQL 12, 13, 14, 15 (Supabase all versions)
--  IDEMPOTENT: aman dijalankan berkali-kali
--  Upload via: Supabase → SQL Editor → Run
-- ============================================================

-- ── EXTENSIONS ──────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
--  RESET BERSIH (drop semua jika sudah ada)
-- ============================================================

-- Views
DROP VIEW IF EXISTS v_weekly_terbaru    CASCADE;
DROP VIEW IF EXISTS v_funnel_konversi   CASCADE;
DROP VIEW IF EXISTS v_project_aktif     CASCADE;
DROP VIEW IF EXISTS v_pipeline_summary  CASCADE;

-- Tables (urutan: child dulu, parent belakangan)
DROP TABLE IF EXISTS research_doc       CASCADE;
DROP TABLE IF EXISTS project_report     CASCADE;
DROP TABLE IF EXISTS weekly             CASCADE;
DROP TABLE IF EXISTS monev              CASCADE;
DROP TABLE IF EXISTS projects           CASCADE;
DROP TABLE IF EXISTS approved           CASCADE;
DROP TABLE IF EXISTS status_tracker     CASCADE;
DROP TABLE IF EXISTS rfp                CASCADE;
DROP TABLE IF EXISTS converted          CASCADE;
DROP TABLE IF EXISTS rfi                CASCADE;

-- ENUM Types
DROP TYPE IF EXISTS sumber_inquiry      CASCADE;
DROP TYPE IF EXISTS output_rfp          CASCADE;
DROP TYPE IF EXISTS kluster_industri    CASCADE;
DROP TYPE IF EXISTS jenis_layanan       CASCADE;
DROP TYPE IF EXISTS jenis_output_riset  CASCADE;
DROP TYPE IF EXISTS jenis_metodologi    CASCADE;
DROP TYPE IF EXISTS status_laporan      CASCADE;
DROP TYPE IF EXISTS keputusan_monev     CASCADE;
DROP TYPE IF EXISTS status_gate         CASCADE;
DROP TYPE IF EXISTS fase_project        CASCADE;
DROP TYPE IF EXISTS status_project      CASCADE;
DROP TYPE IF EXISTS status_onboarding   CASCADE;
DROP TYPE IF EXISTS status_proposal     CASCADE;
DROP TYPE IF EXISTS status_rfp          CASCADE;
DROP TYPE IF EXISTS prioritas_level     CASCADE;
DROP TYPE IF EXISTS potensi_level       CASCADE;
DROP TYPE IF EXISTS status_rfi          CASCADE;

-- Indexes
DROP INDEX IF EXISTS idx_rfi_status;
DROP INDEX IF EXISTS idx_rfi_potensi;
DROP INDEX IF EXISTS idx_rfi_created_at;
DROP INDEX IF EXISTS idx_conv_rfi_id;
DROP INDEX IF EXISTS idx_rfp_klien;
DROP INDEX IF EXISTS idx_rfp_deadline;
DROP INDEX IF EXISTS idx_rfp_prioritas;
DROP INDEX IF EXISTS idx_stat_status;
DROP INDEX IF EXISTS idx_stat_rfp_id;
DROP INDEX IF EXISTS idx_appr_klien;
DROP INDEX IF EXISTS idx_appr_tgl;
DROP INDEX IF EXISTS idx_proj_status;
DROP INDEX IF EXISTS idx_proj_pm;
DROP INDEX IF EXISTS idx_proj_deadline;
DROP INDEX IF EXISTS idx_monev_project_id;
DROP INDEX IF EXISTS idx_weekly_project_id;
DROP INDEX IF EXISTS idx_weekly_tgl;
DROP INDEX IF EXISTS idx_pr_project_id;
DROP INDEX IF EXISTS idx_rd_project_id;

-- Functions
DROP FUNCTION IF EXISTS set_updated_at()             CASCADE;
DROP FUNCTION IF EXISTS sync_progress_from_monev()   CASCADE;
DROP FUNCTION IF EXISTS auto_create_monev_and_report() CASCADE;


-- ============================================================
--  ENUM TYPES
-- ============================================================

CREATE TYPE status_rfi AS ENUM (
  'Diskusi Awal', 'Qualified', 'Converted to Proposal', 'Tidak Dilanjutkan'
);

CREATE TYPE potensi_level AS ENUM ('High', 'Medium', 'Low');

CREATE TYPE prioritas_level AS ENUM ('High', 'Medium', 'Low');

CREATE TYPE status_rfp AS ENUM (
  'Belum Diisi', 'Sudah Diisi', 'Dalam Review Internal', 'Proposal Terkirim'
);

CREATE TYPE status_proposal AS ENUM (
  'Draft', 'Review Internal', 'Terkirim', 'Revisi',
  'Disetujui', 'Ditolak', 'On Hold'
);

CREATE TYPE status_onboarding AS ENUM (
  'Belum Dimulai', 'Onboarding', 'Kick-off Done', 'Dalam Pengerjaan', 'Selesai'
);

CREATE TYPE status_project AS ENUM (
  '🟢 On Track', '🟡 Perhatian', '🔴 Terlambat', '✅ Selesai', '⏸ Ditunda'
);

CREATE TYPE fase_project AS ENUM (
  'Persiapan', 'Fieldwork', 'Analisis Data', 'Penulisan',
  'Review Internal', 'Gate Review', 'Revisi', 'Finalisasi', 'Selesai'
);

CREATE TYPE status_gate AS ENUM (
  '⬜ Belum', '🔄 On Review', '❌ Revisi', '✅ Approved'
);

CREATE TYPE keputusan_monev AS ENUM (
  'Dalam Proses', 'Approved', 'Ditolak', 'Perlu Revisi Mayor'
);

CREATE TYPE status_laporan AS ENUM (
  'Belum Mulai', 'Dalam Pengerjaan', 'Review Internal', 'Final', 'Selesai'
);

CREATE TYPE jenis_metodologi AS ENUM (
  'Kuantitatif', 'Kualitatif', 'Mixed Methods', 'Desk Study',
  'Survei', 'FGD', 'In-depth Interview', 'Observasi', 'Lainnya'
);

CREATE TYPE jenis_output_riset AS ENUM (
  'Laporan Riset', 'Jurnal Ilmiah', 'Policy Brief',
  'Infografis', 'Dataset', 'Presentasi', 'Lainnya'
);

CREATE TYPE jenis_layanan AS ENUM (
  'Pemetaan Sosial', 'IKM', 'Stakeholder Engagement', 'SLH',
  'Jurnal Ilmiah', 'REA', 'PROPER', 'SROI', 'Comdev Class', 'Lainnya'
);

CREATE TYPE kluster_industri AS ENUM (
  'Manufaktur', 'Migas', 'Perbankan', 'FMCG', 'Energi',
  'Makanan & Minuman', 'Konstruksi', 'Telekomunikasi',
  'Pertambangan', 'Transportasi', 'Kesehatan', 'Pemerintahan', 'Lainnya'
);

CREATE TYPE output_rfp AS ENUM ('Proposal', 'BOQ', 'Keduanya');

CREATE TYPE sumber_inquiry AS ENUM (
  'LinkedIn', 'Referral', 'Cold Call / Email',
  'Conference / Exhibition', 'Tender', 'Website', 'Lainnya'
);


-- ============================================================
--  TABLES
-- ============================================================

-- Phase 1 — Inquiry
CREATE TABLE rfi (
  id          UUID          PRIMARY KEY DEFAULT uuid_generate_v4(),
  perusahaan  TEXT          NOT NULL,
  industri    kluster_industri,
  pic         TEXT,
  jabatan     TEXT,
  kontak      TEXT,
  sumber      sumber_inquiry,
  kebutuhan   TEXT,
  lokasi      TEXT,
  status      status_rfi    NOT NULL DEFAULT 'Diskusi Awal',
  potensi     potensi_level,
  next_action TEXT,
  catatan     TEXT,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Bridge 1→2
CREATE TABLE converted (
  id             UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  rfi_id         UUID        REFERENCES rfi(id) ON DELETE SET NULL,
  klien          TEXT        NOT NULL,
  pic            TEXT,
  kontak         TEXT,
  kebutuhan      TEXT,
  lokasi         TEXT,
  tgl_converted  DATE        NOT NULL DEFAULT CURRENT_DATE,
  status_rfp     status_rfp  NOT NULL DEFAULT 'Belum Diisi',
  catatan        TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Phase 2 — Request Form
CREATE TABLE rfp (
  id            UUID             PRIMARY KEY DEFAULT uuid_generate_v4(),
  converted_id  UUID             REFERENCES converted(id) ON DELETE SET NULL,
  klien         TEXT             NOT NULL,
  pic           TEXT,
  sektor        kluster_industri,
  layanan       jenis_layanan,
  jumlah        TEXT,
  lokasi        TEXT,
  deadline      DATE,
  target_mulai  DATE,
  prioritas     prioritas_level  NOT NULL DEFAULT 'Medium',
  output        output_rfp,
  catatan       TEXT,
  created_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- Phase 2 — Status Tracker
CREATE TABLE status_tracker (
  id         UUID             PRIMARY KEY DEFAULT uuid_generate_v4(),
  rfp_id     UUID             REFERENCES rfp(id) ON DELETE SET NULL,
  no_ref     TEXT,
  klien      TEXT             NOT NULL,
  layanan    TEXT,
  sektor     TEXT,
  deadline   DATE,
  prioritas  prioritas_level,
  tgl_request DATE,
  tgl_kirim  DATE,
  status     status_proposal  NOT NULL DEFAULT 'Draft',
  nilai      NUMERIC(18,0),
  feedback   TEXT,
  tindak_lanjut TEXT,
  created_at TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- Bridge 2→3
CREATE TABLE approved (
  id                  UUID              PRIMARY KEY DEFAULT uuid_generate_v4(),
  status_tracker_id   UUID              REFERENCES status_tracker(id) ON DELETE SET NULL,
  no_ref              TEXT,
  klien               TEXT              NOT NULL,
  layanan             TEXT,
  nilai               NUMERIC(18,0),
  tgl_disetujui       DATE              NOT NULL DEFAULT CURRENT_DATE,
  pm                  TEXT,
  tgl_mulai           DATE,
  status_onboarding   status_onboarding NOT NULL DEFAULT 'Onboarding',
  catatan             TEXT,
  created_at          TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

-- Phase 3 — Data Project
CREATE TABLE projects (
  id           UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
  approved_id  UUID           REFERENCES approved(id) ON DELETE SET NULL,
  nama         TEXT           NOT NULL UNIQUE,
  jenis_riset  jenis_layanan,
  klien        TEXT,
  pm           TEXT,
  tgl_mulai    DATE,
  deadline     DATE,
  tim_peneliti TEXT,
  lokasi       TEXT,
  nilai        NUMERIC(18,0),
  progress     SMALLINT       NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
  fase         fase_project   NOT NULL DEFAULT 'Persiapan',
  status       status_project NOT NULL DEFAULT '🟢 On Track',
  catatan      TEXT,
  created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- Phase 3 — MONEV 4-Gate
CREATE TABLE monev (
  id           UUID            PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id   UUID            UNIQUE REFERENCES projects(id) ON DELETE CASCADE,
  nama_proyek  TEXT            NOT NULL,
  pm           TEXT,
  jenis_riset  TEXT,
  g1           status_gate     NOT NULL DEFAULT '⬜ Belum',
  g2           status_gate     NOT NULL DEFAULT '⬜ Belum',
  g3           status_gate     NOT NULL DEFAULT '⬜ Belum',
  g4           status_gate     NOT NULL DEFAULT '⬜ Belum',
  keputusan    keputusan_monev NOT NULL DEFAULT 'Dalam Proses',
  catatan      TEXT,
  created_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Phase 3 — Weekly Update
CREATE TABLE weekly (
  id           UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id   UUID        REFERENCES projects(id) ON DELETE CASCADE,
  nama_proyek  TEXT        NOT NULL,
  pm           TEXT,
  minggu       SMALLINT    NOT NULL CHECK (minggu > 0),
  progress     SMALLINT    NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
  tgl_update   DATE        NOT NULL DEFAULT CURRENT_DATE,
  sudah        TEXT,
  rencana      TEXT,
  kendala      TEXT,
  bantuan_bd   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Deliverable — Project Report Tracker
CREATE TABLE project_report (
  id           UUID           PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id   UUID           REFERENCES projects(id) ON DELETE SET NULL,
  jenis_riset  TEXT           NOT NULL,
  client       TEXT,
  pm           TEXT,
  lokasi       TEXT,
  link_draft   TEXT,
  input_data   BOOLEAN        NOT NULL DEFAULT FALSE,
  bab1         BOOLEAN        NOT NULL DEFAULT FALSE,
  bab2         BOOLEAN        NOT NULL DEFAULT FALSE,
  bab3         BOOLEAN        NOT NULL DEFAULT FALSE,
  bab4         BOOLEAN        NOT NULL DEFAULT FALSE,
  bab5         BOOLEAN        NOT NULL DEFAULT FALSE,
  status       status_laporan NOT NULL DEFAULT 'Belum Mulai',
  catatan      TEXT,
  created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- Deliverable — Research Documentation
CREATE TABLE research_doc (
  id                UUID               PRIMARY KEY DEFAULT uuid_generate_v4(),
  project_id        UUID               REFERENCES projects(id) ON DELETE SET NULL,
  judul             TEXT               NOT NULL,
  client            TEXT,
  lokasi            TEXT,
  tgl_mulai         DATE,
  tgl_selesai       DATE,
  metodologi        jenis_metodologi,
  research_output   jenis_output_riset,
  research_overview TEXT,
  temuan            TEXT,
  scope             TEXT,
  link_dok          TEXT,
  catatan           TEXT,
  created_at        TIMESTAMPTZ        NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ        NOT NULL DEFAULT NOW()
);


-- ============================================================
--  INDEXES
-- ============================================================

CREATE INDEX idx_rfi_status        ON rfi(status);
CREATE INDEX idx_rfi_potensi       ON rfi(potensi);
CREATE INDEX idx_rfi_created_at    ON rfi(created_at DESC);
CREATE INDEX idx_conv_rfi_id       ON converted(rfi_id);
CREATE INDEX idx_rfp_klien         ON rfp(klien);
CREATE INDEX idx_rfp_deadline      ON rfp(deadline);
CREATE INDEX idx_rfp_prioritas     ON rfp(prioritas);
CREATE INDEX idx_stat_status       ON status_tracker(status);
CREATE INDEX idx_stat_rfp_id       ON status_tracker(rfp_id);
CREATE INDEX idx_appr_klien        ON approved(klien);
CREATE INDEX idx_appr_tgl          ON approved(tgl_disetujui DESC);
CREATE INDEX idx_proj_status       ON projects(status);
CREATE INDEX idx_proj_pm           ON projects(pm);
CREATE INDEX idx_proj_deadline     ON projects(deadline);
CREATE INDEX idx_monev_project_id  ON monev(project_id);
CREATE INDEX idx_weekly_project_id ON weekly(project_id);
CREATE INDEX idx_weekly_tgl        ON weekly(tgl_update DESC);
CREATE INDEX idx_pr_project_id     ON project_report(project_id);
CREATE INDEX idx_rd_project_id     ON research_doc(project_id);


-- ============================================================
--  FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rfi_upd        BEFORE UPDATE ON rfi            FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_conv_upd       BEFORE UPDATE ON converted       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_rfp_upd        BEFORE UPDATE ON rfp             FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_stat_upd       BEFORE UPDATE ON status_tracker  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_appr_upd       BEFORE UPDATE ON approved        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_proj_upd       BEFORE UPDATE ON projects        FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_monev_upd      BEFORE UPDATE ON monev           FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_weekly_upd     BEFORE UPDATE ON weekly          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_pr_upd         BEFORE UPDATE ON project_report  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_rd_upd         BEFORE UPDATE ON research_doc    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Sync progress dari MONEV gate (tiap gate approved = +25%)
CREATE OR REPLACE FUNCTION sync_progress_from_monev()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_count SMALLINT;
BEGIN
  v_count :=
    (CASE WHEN NEW.g1 = '✅ Approved' THEN 1 ELSE 0 END) +
    (CASE WHEN NEW.g2 = '✅ Approved' THEN 1 ELSE 0 END) +
    (CASE WHEN NEW.g3 = '✅ Approved' THEN 1 ELSE 0 END) +
    (CASE WHEN NEW.g4 = '✅ Approved' THEN 1 ELSE 0 END);
  UPDATE projects SET progress = v_count * 25 WHERE id = NEW.project_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_monev_sync
  AFTER INSERT OR UPDATE ON monev
  FOR EACH ROW EXECUTE FUNCTION sync_progress_from_monev();

-- Auto-create MONEV + Project Report saat project baru dibuat
CREATE OR REPLACE FUNCTION auto_create_on_project()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO monev (project_id, nama_proyek, pm, jenis_riset)
    VALUES (NEW.id, NEW.nama, NEW.pm, NEW.jenis_riset::TEXT)
    ON CONFLICT (project_id) DO NOTHING;

  INSERT INTO project_report (project_id, jenis_riset, client, pm, lokasi)
    VALUES (NEW.id, NEW.nama, NEW.klien, NEW.pm, NEW.lokasi)
    ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_project_auto
  AFTER INSERT ON projects
  FOR EACH ROW EXECUTE FUNCTION auto_create_on_project();


-- ============================================================
--  ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE rfi            ENABLE ROW LEVEL SECURITY;
ALTER TABLE converted      ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfp            ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_tracker ENABLE ROW LEVEL SECURITY;
ALTER TABLE approved       ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects       ENABLE ROW LEVEL SECURITY;
ALTER TABLE monev          ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly         ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_report ENABLE ROW LEVEL SECURITY;
ALTER TABLE research_doc   ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'rfi','converted','rfp','status_tracker','approved',
    'projects','monev','weekly','project_report','research_doc'
  ]
  LOOP
    EXECUTE format(
      'CREATE POLICY "auth_full_%s" ON %I FOR ALL TO authenticated USING (true) WITH CHECK (true);',
      tbl, tbl
    );
  END LOOP;
END;
$$;


-- ============================================================
--  VIEWS
-- ============================================================

CREATE OR REPLACE VIEW v_pipeline_summary AS
SELECT
  (SELECT COUNT(*)  FROM rfi)                                        AS total_inquiry,
  (SELECT COUNT(*)  FROM rfi   WHERE status = 'Qualified')           AS qualified,
  (SELECT COUNT(*)  FROM rfi   WHERE status = 'Converted to Proposal') AS converted,
  (SELECT COUNT(*)  FROM rfp)                                        AS total_rfp,
  (SELECT COUNT(*)  FROM status_tracker WHERE status = 'Disetujui') AS proposal_approved,
  (SELECT COUNT(*)  FROM projects)                                   AS total_projects,
  (SELECT COUNT(*)  FROM projects
     WHERE status NOT IN ('✅ Selesai','⏸ Ditunda'))                 AS project_aktif,
  (SELECT COUNT(*)  FROM projects WHERE status = '✅ Selesai')       AS project_selesai,
  (SELECT COUNT(*)  FROM project_report)                             AS total_reports,
  (SELECT COUNT(*)  FROM research_doc)                               AS total_research_docs,
  (SELECT COALESCE(SUM(nilai),0) FROM approved)                      AS total_nilai_approved,
  (SELECT COALESCE(SUM(nilai),0) FROM projects)                      AS total_nilai_projects;

CREATE OR REPLACE VIEW v_project_aktif AS
SELECT
  p.id, p.nama, p.jenis_riset, p.klien, p.pm,
  p.tgl_mulai, p.deadline, p.progress, p.fase, p.status, p.nilai,
  m.g1, m.g2, m.g3, m.g4, m.keputusan AS keputusan_gate,
  (CASE WHEN m.g1='✅ Approved' THEN 1 ELSE 0 END +
   CASE WHEN m.g2='✅ Approved' THEN 1 ELSE 0 END +
   CASE WHEN m.g3='✅ Approved' THEN 1 ELSE 0 END +
   CASE WHEN m.g4='✅ Approved' THEN 1 ELSE 0 END) AS gate_approved_count,
  pr.status AS status_laporan,
  p.created_at
FROM projects p
LEFT JOIN monev          m  ON m.project_id  = p.id
LEFT JOIN project_report pr ON pr.project_id = p.id
WHERE p.status NOT IN ('✅ Selesai','⏸ Ditunda')
ORDER BY p.deadline ASC NULLS LAST;

CREATE OR REPLACE VIEW v_funnel_konversi AS
SELECT 'Inquiry Masuk'      AS stage, COUNT(*) AS jumlah, 1 AS urut FROM rfi
UNION ALL SELECT 'Qualified',        COUNT(*), 2 FROM rfi WHERE status='Qualified'
UNION ALL SELECT 'Converted',        COUNT(*), 3 FROM rfi WHERE status='Converted to Proposal'
UNION ALL SELECT 'Request Form',     COUNT(*), 4 FROM rfp
UNION ALL SELECT 'Proposal Approved',COUNT(*), 5 FROM status_tracker WHERE status='Disetujui'
UNION ALL SELECT 'Project Aktif',    COUNT(*), 6 FROM projects WHERE status NOT IN ('✅ Selesai','⏸ Ditunda')
UNION ALL SELECT 'Selesai',          COUNT(*), 7 FROM projects WHERE status='✅ Selesai'
ORDER BY urut;

CREATE OR REPLACE VIEW v_weekly_terbaru AS
SELECT DISTINCT ON (project_id)
  id, project_id, nama_proyek, pm, minggu,
  progress, tgl_update, sudah, rencana, kendala
FROM weekly
ORDER BY project_id, tgl_update DESC, minggu DESC;


-- ============================================================
--  SAMPLE DATA (hapus jika tidak diperlukan)
-- ============================================================

INSERT INTO rfi (perusahaan, industri, pic, jabatan, kontak, sumber, kebutuhan, lokasi, status, potensi, next_action) VALUES
  ('PT Semen Nusantara','Manufaktur','Budi Santoso','CSR Manager','budi@semen.co.id','Referral','Pemetaan Sosial area tambang Tuban','Tuban, Jawa Timur','Qualified','High','Kirim proposal minggu ini'),
  ('PLN Persero','Energi','Ratna Dewi','Head of Sustainability','ratna@pln.co.id','LinkedIn','SLH untuk PLTU Suralaya','Cilegon, Banten','Diskusi Awal','High','Follow up 3 hari lagi'),
  ('PT Freeport Indonesia','Pertambangan','James Tanaka','Community Relations','james@freeport.com','Conference / Exhibition','PROPER & Stakeholder Engagement','Timika, Papua','Converted to Proposal','High',NULL);

INSERT INTO projects (nama, jenis_riset, klien, pm, tgl_mulai, deadline, lokasi, nilai, progress, fase, status) VALUES
  ('Pemetaan Sosial Tuban 2026','Pemetaan Sosial','PT Semen Nusantara','Andi Prasetyo','2026-01-15','2026-04-30','Tuban, Jawa Timur',180000000,60,'Penulisan','🟢 On Track'),
  ('SLH PLTU Suralaya','SLH','PLN Persero','Sari Wulandari','2026-02-01','2026-06-30','Cilegon, Banten',250000000,25,'Fieldwork','🟡 Perhatian');


-- ============================================================
--  SELESAI ✅
--  10 Tabel · 4 Views · 12 Triggers · 19 Index · RLS aktif
-- ============================================================
