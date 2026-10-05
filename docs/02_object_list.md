# 02 — Object List

`⬜` ยังไม่สร้าง · `🟨` ส่ง code แล้วรอสร้าง · `🟦` activate แล้วรอ push · `✅` อยู่ใน repo

| Object | ชนิด | ไฟล์ | Status |
|---|---|---|---|
| `ZIME001` | Package | `src/package.devc.xml` | ✅ baseline `aa44f7a` (`/src/` · FULL) |
| `ZCL_ZIME001` | Class — `is_valid_batch_format( )` ตรวจ format batch `YYMMDDNNNN` เทียบปีปัจจุบัน UTC+7 · `generate_batch_number( )` หาเลขถัดไปของ material จาก `I_Batch` | `src/zcl_zime001.clas.abap` | ✅ `aa5f697` (2026-10-05) |
| `ZCL_ZIME001` method `generate_batch_number` | สร้างเลข batch `YYMMDDNNNN` ถัดไปของ material (`I_Batch` privileged access · ไม่กรอง plant) | `src/zcl_zime001.clas.abap` | ✅ `38be34d` (2026-10-05) |
| `ZCL_ZIME001` API state | APIS — C1 · Released · Use in Key User Apps · ชื่อไฟล์มีช่องว่างคั่นเพราะ SAP serialize key แบบ padded **ห้าม rename** | `src/zcl_zime001                         clas.apis.xml` | ✅ `38be34d` |
| `ZCL_ZIME001` testclasses | ABAP Unit ของ method ตรวจ format | `src/zcl_zime001.clas.testclasses.abap` | ✅ 17 test เขียว (`ltc_batch_format` 12 · `ltc_batch_number` 5) `38be34d` |
| `YY1_AFTER_BATCH_NUMBER_INT` | Custom Logic ของ BAdI `LOBM_AFTER_BATCH_NUMBER_INT` | — key user ไม่ขึ้น git | 🟦 สร้างแล้ว ยังไม่ publish |
