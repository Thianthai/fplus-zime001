# 02 — Object List

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001` | Package | `src/package.devc.xml` | ✅ baseline `aa44f7a` (`/src/` · FULL) |
| `ZCL_ZIME001` | Class — `is_valid_batch_format( )` ตรวจ format batch `YYMMDDNNNN` เทียบปีปัจจุบัน UTC+7 · release C1 + Use in Key User Apps (abapGit ไม่ serialize API state · ผู้ใช้ยืนยันใน ADT แล้ว 2026-10-05) | `src/zcl_zime001.clas.abap` | ✅ `aa5f697` (2026-10-05) |
| `ZCL_ZIME001` method `generate_batch_number` | สร้างเลข batch `YYMMDDNNNN` ถัดไปของ material | `src/zcl_zime001.clas.abap` | ⬜ Phase 2 |
| `ZCL_ZIME001` testclasses | ABAP Unit ของ method ตรวจ format | `src/zcl_zime001.clas.testclasses.abap` | ✅ 12 test เขียว `aa5f697` |
| `YY1_AFTER_BATCH_NUMBER_INT` | Custom Logic ของ BAdI `LOBM_AFTER_BATCH_NUMBER_INT` | — key user ไม่ขึ้น git | 🟦 สร้างแล้ว ยังไม่ publish |
