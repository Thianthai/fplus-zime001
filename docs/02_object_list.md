# 02 — Object List

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001` | Package | `src/package.devc.xml` | ✅ baseline `aa44f7a` (`/src/` · FULL) |
| `ZCL_ZIME001` | Class — `is_valid_batch_format( )` ตรวจ format batch `YYMMDDNNNN` เทียบปีปัจจุบัน UTC+7 · `generate_batch_number( )` หาเลขถัดไปของ material จาก `I_Batch` | `src/zcl_zime001.clas.abap` | ✅ `aa5f697` (2026-10-05) |
| `ZCL_ZIME001` method `generate_batch_number` | สร้างเลข batch `YYMMDDNNNN` ถัดไปของ material (`I_Batch` privileged access · ไม่กรอง plant) | `src/zcl_zime001.clas.abap` | ✅ `38be34d` (2026-10-05) |
| `ZCL_ZIME001` API state | APIS — C1 · Released · Use in Key User Apps · ชื่อไฟล์มีช่องว่างคั่นเพราะ SAP serialize key แบบ padded **ห้าม rename** | `src/zcl_zime001                         clas.apis.xml` | ✅ `38be34d` |
| `ZCL_ZIME001` R-03 draft | `gc_case` · `ty_batch_allocation` · `get_batch_number( )` · `get_batch_case_a( )` · `generate_batch_number( iv_date )` · `get_current_date( )` ใช้ `ZCL_UTILITY` · Custom Logic ยังไม่เรียก | `src/zcl_zime001.clas.abap` | ✅ `94dcdc1` (2026-10-05) · draft |
| `ZCL_ZIME001` testclasses | ABAP Unit ของ method ตรวจ format | `src/zcl_zime001.clas.testclasses.abap` | ✅ 19 test เขียว (`ltc_batch_format` 12 · `ltc_batch_number` 7) `94dcdc1` |
| `YY1_AFTER_BATCH_NUMBER_INT` | Custom Logic ของ BAdI `LOBM_AFTER_BATCH_NUMBER_INT` | — key user ไม่ขึ้น git · สำเนาใน `docs/04_custom_logic.md` | 🟨 ส่ง code รอบ 4 2026-10-05 รอยืนยัน publish — เก็บ log อย่างเดียว ไม่แก้ `batch_out` · parameter `iv_batch_out` |

## ชั่วคราว (R-02) — ลบก่อน transport

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001_LOG` | Database table — 1 row ต่อ 1 call ของ BAdI | `src/zime001_log.tabl.xml` | ✅ `220ac57` (2026-10-05) · `94dcdc1` SAP เติม `TDDAT` authorization group `CUS_DEV_SUP_DA` เอง · 43 field · `batch_in` `batch_out` `batch_out_after` `is_valid_format` + 35 field ของ BAdI · `invertedIndividualIndex` |
| `ZCL_ZIME001_LOG` | Class — `write( )` INSERT ลง `ZIME001_LOG` · release C1 + Use in Key User Apps | `src/zcl_zime001_log.clas.abap` | ✅ `220ac57` (2026-10-05) · parameter `iv_batch_out` |
| `ZCL_ZIME001_LOG` API state | APIS — C1 · Released · Use in Key User Apps · ลบก่อน transport (ต้องเปลี่ยนเป็น Not Released ก่อนลบ class) | `src/zcl_zime001_log                     clas.apis.xml` | ✅ `36cd138` |
