# 02 — Object List

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001` | Package | `src/package.devc.xml` | ✅ baseline `aa44f7a` (`/src/` · FULL) |
| `ZCL_ZIME001` | Class — `is_valid_batch_format( )` ตรวจ format batch `YYMMDDNNNN` เทียบปีปัจจุบัน UTC+7 · `generate_batch_number( )` หาเลขถัดไปของ material จาก `I_Batch` | `src/zcl_zime001.clas.abap` | ✅ `aa5f697` (2026-10-05) |
| `ZCL_ZIME001` method `generate_batch_number` | สร้างเลข batch `YYMMDDNNNN` ถัดไปของ material (`I_Batch` privileged access · ไม่กรอง plant) | `src/zcl_zime001.clas.abap` | ✅ `38be34d` (2026-10-05) |
| `ZCL_ZIME001` API state | APIS — C1 · Released · Use in Key User Apps · release กลับแล้ว 2026-10-09 หลังเปลี่ยนเป็น `CREATE PRIVATE` | `src/zcl_zime001                         clas.apis.xml` | ✅ `a0148d9` |
| `ZCL_ZIME001` R-03 draft | `gc_case` · `ty_batch_allocation` · `get_batch_number( )` · `get_batch_case_a( )` · `generate_batch_number( iv_date )` · `get_current_date( )` ใช้ `ZCL_UTILITY` · Custom Logic ยังไม่เรียก | `src/zcl_zime001.clas.abap` | ✅ `87c29f2` 2026-10-09 · CASE_C ใช้วันที่ปัจจุบัน (R-09) · **เช็ค user ทดสอบถูก comment ทุก user ได้ผล** · CASE_B รับ production order (R-08 `e463163`) · `REF_DOC_TYPE` ไม่ใช้ ext · **ปิดการเช็ค order type ใน CASE_A ชั่วคราว (I-01 `f32839d`)** · `CREATE PRIVATE` (`a0148d9`) · `determine_case` + เช็ค user ทดสอบ `gc_test_user` (ชั่วคราว) (`86a3064`) · ABAP Doc ของ `gc_case` (`fd850d9`) สรุปแต่ละ case ว่าเช็คอะไรและรองรับ app ไหน · CASE_C (`fc015ea`): inbound delivery อ้างอิง PO + `REF_DOC_TYPE` + `PO_DOCTYPE_STO` (exclude ZP25) จาก `I_PurchaseOrderAPI01` + `I_Product` + วันที่จาก schedule line บรรทัดแรก + จำเลข item แรกใน `gt_delivery_batch` · CASE_B (`b432fcc`): อ้างอิง PO + `MOVEMENT_TYPE`/`REF_DOC_TYPE` จาก constant parameter + `I_Product-IsBatchManagementRequired` + วันที่ปัจจุบัน · CASE_A ตาม log (`5628054`): ข้ามเลข order `%` · `zcl_utility=>remove_invisible_char( )` ล้าง order type · ไม่เช็ค REL |
| `ZCL_ZIME001` testclasses | ABAP Unit ของ method ตรวจ format | `src/zcl_zime001.clas.testclasses.abap` | ✅ 26 test เขียว (`ltc_batch_format` 12 · `ltc_batch_number` 14) `e463163` |
| `YY1_AFTER_BATCH_NUMBER_INT` | Custom Logic ของ BAdI `LOBM_AFTER_BATCH_NUMBER_INT` | — key user ไม่ขึ้น git · สำเนาใน `docs/04_custom_logic.md` | 🟨 ส่ง code รอบ 4 2026-10-05 รอยืนยัน publish — เก็บ log อย่างเดียว ไม่แก้ `batch_out` · parameter `iv_batch_out` |

## ชั่วคราว (R-02) — ลบก่อน transport

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001_LOG` | Database table — 1 row ต่อ 1 call ของ BAdI | `src/zime001_log.tabl.xml` | ✅ `220ac57` (2026-10-05) · `94dcdc1` SAP เติม `TDDAT` authorization group `CUS_DEV_SUP_DA` เอง · 43 field · `batch_in` `batch_out` `batch_out_after` `is_valid_format` + 35 field ของ BAdI · `invertedIndividualIndex` |
| `ZCL_ZIME001_LOG` | Class — `write( )` INSERT ลง `ZIME001_LOG` · release C1 + Use in Key User Apps | `src/zcl_zime001_log.clas.abap` | ✅ `220ac57` (2026-10-05) · parameter `iv_batch_out` |
| `ZCL_ZIME001_LOG` API state | APIS — C1 · Released · Use in Key User Apps · ลบก่อน transport (ต้องเปลี่ยนเป็น Not Released ก่อนลบ class) | `src/zcl_zime001_log                     clas.apis.xml` | ✅ `36cd138` |
