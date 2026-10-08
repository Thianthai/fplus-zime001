# 05 — Issue และ Requirement เพิ่มเติม

งานของเราจบที่ Phase 3 (2026-10-05)
ฟังก์ชันนอลทดสอบ end-to-end เอง แล้วส่ง issue กลับมา
ผู้ใช้อาจเพิ่ม requirement ก่อนนั้น

แต่ละรายการยังใช้จังหวะเดิม: สรุปชื่อ object ให้รีวิว -> ถามก่อนส่ง code -> ผู้ใช้ push -> Claude ตรวจ repo

## Issue จากการทดสอบ

| # | วันที่ | อาการ | สาเหตุ | แก้ที่ | สถานะ |
|---|---|---|---|---|---|

## Requirement เพิ่มเติม

| # | วันที่ | Requirement | กระทบ object | สถานะ |
|---|---|---|---|---|
| R-01 | 2026-10-05 | logic ต่างกันตามที่มาของ transaction: (1) Create/Change Production Order CO01/CO02 (2) Mass Processing of Production Orders (3) Goods Receipt MIGO (4) Create/Change Inbound Delivery VL31/VL32 | `ZCL_ZIME001` · Custom Logic | 🔍 วิเคราะห์ — แยกจาก field ใน `BATCH_ALLOCATION` (ไม่มี tcode / app id ให้ใช้) · เก็บค่าจริงด้วยแอป Custom Logic Tracing ก่อน (Q-17) · ข้อ 1 กับ 2 ใช้ logic เดียวกัน -> 3 กลุ่ม: Production Order · Goods Receipt · Inbound Delivery |
| R-02 | 2026-10-05 | **ชั่วคราว** เก็บ import/changing ของ BAdI ทุก call ลง custom table เพื่อ investigate R-01 · ทุก field เป็น predefined type ยาวตามรูป parameter | table `ZIME001_LOG` · class `ZCL_ZIME001_LOG` · Custom Logic | ✅ อยู่ใน repo `36cd138` รอเก็บข้อมูลจาก 3 กลุ่ม app · 2026-10-05 เปลี่ยน `batch_out_before` -> `batch_out` (table + parameter `iv_batch_out`) ตอน table ยังว่าง · table ต้องเพิ่ม `@AbapCatalog.primaryKey.invertedIndividualIndex : true` (warning Inverted Individual) · **ลบก่อน transport** |
| R-03 | 2026-10-05 | logic แยกตาม case โดย fix constant case ไว้ก่อน (`CASE_A` ...) แล้วค่อย map กับ data จาก log · **CASE_A = Production Order** (CO01 · CO02 · Mass Processing): order released + order type อยู่ใน constant `IME001` / `PRODUCTION_ORDER_TYPE` (ZCL_PARAM · module MM) -> YYMMDD จาก ScheduledStartDate · NNNN ต่อจาก `I_Batch` ของ material | `ZCL_ZIME001` · Custom Logic · ใช้ `ZCL_PARAM` (package `ZBCPARAM`) | ✅ 2026-10-06 ปรับตาม log อยู่ใน repo `5628054` (ล้าง order type ด้วย `ZCL_UTILITY` · ตัดเช็ค REL · ข้ามเลข order `%`) · constant parameter `IME001` / `PRODUCTION_ORDER_TYPE` maintain แล้ว (ผู้ใช้แจ้ง 2026-10-05) · `get_batch_case_a` ยังไม่ได้ทดสอบกับข้อมูลจริง · released = status `I0002` active · Custom Logic ยังเก็บ log อย่างเดียวจนกว่าได้ log ครบ |
| R-04 | 2026-10-06 | **CASE_B = Goods Receipt (MIGO A01 + R01)**: ถ้า `I_Product-IsBatchManagementRequired = X` -> YYMMDD จาก Posting Date · NNNN ต่อจาก `I_Batch` | `ZCL_ZIME001` | ✅ **draft** อยู่ใน repo `b432fcc` 2026-10-06 · constant parameter ตามที่ maintain บน tenant: `MOVEMENT_TYPE` ext `GOODS_RECEIPT` (101) และ `REF_DOC_TYPE` ext `PURCHASE_ORDER` (B) · module MM · Q-34 Q-36 ค้าง |
| R-05 | 2026-10-08 | **CASE_C = Inbound Delivery (VL31 / VL32)**: อ้างอิง PO เท่านั้น · PO type ไม่อยู่ใน `PO_DOCTYPE_STO` (E EQ ZP25) · `I_Product-IsBatchManagementRequired = X` · YYMMDD จาก Delivery Date · material เดียวกันหลาย item ต้องได้ batch เดียวกัน | `ZCL_ZIME001` | 🔍 วิเคราะห์ log แล้ว (`08_log_analysis_case_c.md`) รอตอบ Q-39 ถึง Q-43 |

## จุดที่ค้าง (อัปเดต 2026-10-05)

- Custom Logic เก็บ log อย่างเดียว รอฟังก์ชันนอลทำธุรกรรมครบ 3 กลุ่ม (Production Order · MIGO · Inbound Delivery)
- `ZCL_ZIME001` มี CASE_A แบบ draft แต่ยังไม่มีใครเรียก
- ครั้งหน้า: draft case ถัดไป (MIGO หรือ Inbound Delivery) ตาม requirement ที่ผู้ใช้จะส่งมา
- ก่อน transport: ลบ `ZIME001_LOG` · `ZCL_ZIME001_LOG` (Not Released ก่อนลบ) · ส่วน log ใน Custom Logic
