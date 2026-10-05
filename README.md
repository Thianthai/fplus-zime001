# ZIME001 — Automatic Batch Creation

| Item | Value |
|------|-------|
| RICEFW ID | **ZIME001** |
| Description | Automatic Batch Creation |
| Type | Enhancement |
| Platform | SAP S/4HANA Cloud **Public Edition** |
| Development model | **ABAP Cloud** (Developer Extensibility) + Key User Custom Logic |
| BAdI | `LOBM_AFTER_BATCH_NUMBER_INT` — After internal batch number assignment |
| Custom Logic | `YY1_AFTER_BATCH_NUMBER_INT` (สร้างแล้ว 2026-10-02 ยังไม่ publish) |
| Repo sync | abapGit (local ⇄ GitHub ⇄ S/4HANA Cloud) |
| Package | **`ZIME001`** — package เดียว ไม่มี sub-package |

## Scope

ตรวจ format ของเลข batch ที่ระบบเตรียมให้ตอน internal batch number assignment
แล้วให้ Custom Logic ตัดสินใจเลข batch ที่จะใช้จริง

```
สร้าง batch (internal numbering)
        │
        ▼
BAdI LOBM_AFTER_BATCH_NUMBER_INT
Custom Logic YY1_AFTER_BATCH_NUMBER_INT   (key user · ไม่ขึ้น git)
        │  batch_in
        ▼
ZCL_ZIME001                               (developer extensibility · repo นี้)
  validate format YYMMDDNNNN -> abap_true / abap_false
        │
        ▼
batch_out
```

## เอกสาร

| ไฟล์ | เนื้อหา |
|---|---|
| [docs/01_design.md](docs/01_design.md) | design และ phase |
| [docs/02_object_list.md](docs/02_object_list.md) | รายชื่อ object และ status |
| [docs/03_open_questions.md](docs/03_open_questions.md) | ข้อสงสัยที่รอคำตอบ |
| [docs/04_custom_logic.md](docs/04_custom_logic.md) | สำเนา code ของ Custom Logic และผลทดสอบ |
