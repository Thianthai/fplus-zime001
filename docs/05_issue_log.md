# 05 — Issue และ Requirement เพิ่มเติม

งานของเราจบที่ Phase 3 (2026-10-05)
ฟังก์ชันนอลทดสอบ end-to-end เอง แล้วส่ง issue กลับมา
ผู้ใช้อาจเพิ่ม requirement ก่อนนั้น

แต่ละรายการยังใช้จังหวะเดิม: สรุปชื่อ object ให้รีวิว -> ถามก่อนส่ง code -> ผู้ใช้ push -> Claude ตรวจ repo

## Issue จากการทดสอบ

| # | วันที่ | อาการ | สาเหตุ | แก้ที่ | สถานะ |
|---|---|---|---|---|---|
| I-01 | 2026-10-09 | CO02 release order ด้วย user `CB9980000010` แต่ไม่ได้เลข YYMMDDNNNN · log มี 1 row `batch_out_after` = `batch_in` | **ค่า Low ของ constant parameter `PRODUCTION_ORDER_TYPE` เป็น `ZFG` + U+200B** (ตรวจจาก export xlsx) · code ล้าง `ordertype` จาก BAdI เหลือ `ZFG` แล้วเทียบกับ range ที่มี U+200B -> ไม่ตรง · `ZCL_PARAM` ล้างแค่ key ไม่ล้าง Low / High · parameter อื่น (101 · B · ZP25) สะอาด | ฟังก์ชันนอลยืนยันว่า config order type ผิด (มี U+200B) · **ชั่วคราว**: constant parameter `PRODUCTION_ORDER_TYPE` เปลี่ยนเป็น Option `CP` Low `ZFG*` (พิมพ์มือ) ไม่แก้ code · หลังแก้ config ให้เปลี่ยนกลับเป็น `EQ` `ZFG` | 🟨 2026-10-09 แก้ parameter รอบแรกได้ `ZFG` + U+200B + `*` · ~~`remove_invisible_char_in_range( )`~~ ยกเลิก · ผู้ใช้เลือก **comment การเช็ค order type ใน CASE_A ชั่วคราว** ทุก order type ผ่าน · อยู่ใน repo `f32839d` · ✅ ทดสอบซ้ำ 2026-10-09: order 000014000118 ได้ `2610090003` · เหลือเปิดการเช็คกลับหลังแก้ config |
| I-02 | 2026-10-09 | MIGO 2 รอบได้ `2610090001` ซ้ำกัน (PO 2110000127 item 00010) | ไม่ใช่ปัญหา · ผู้ใช้ยืนยันรอบ 1 ไม่ได้ Post batch จึงไม่ถูกบันทึก · รอบ 2 Post สำเร็จด้วย `2610090001` | — | ✅ ปิด 2026-10-09 · รอทดสอบใบถัดไปต้องได้ `2610090002` |
| I-03 | 2026-10-09 | MIGO A01 + R08 (`goodsmovementrefdoctype = F` · material 320000000 ZSFG) ไม่ได้เลข YYMMDDNNNN ตอน 11:23 UTC | ช่วงเวลา: ทดสอบก่อน maintain `REF_DOC_TYPE` F เสร็จ · ไม่ใช่ปัญหาของ code | — | ✅ ปิด 2026-10-09 · ทดสอบซ้ำ 11:44 UTC order 000013000028 ได้ `2610090001` |

## Requirement เพิ่มเติม

| # | วันที่ | Requirement | กระทบ object | สถานะ |
|---|---|---|---|---|
| R-01 | 2026-10-05 | logic ต่างกันตามที่มาของ transaction: (1) Create/Change Production Order CO01/CO02 (2) Mass Processing of Production Orders (3) Goods Receipt MIGO (4) Create/Change Inbound Delivery VL31/VL32 | `ZCL_ZIME001` · Custom Logic | 🔍 วิเคราะห์ — แยกจาก field ใน `BATCH_ALLOCATION` (ไม่มี tcode / app id ให้ใช้) · เก็บค่าจริงด้วยแอป Custom Logic Tracing ก่อน (Q-17) · ข้อ 1 กับ 2 ใช้ logic เดียวกัน -> 3 กลุ่ม: Production Order · Goods Receipt · Inbound Delivery |
| R-02 | 2026-10-05 | **ชั่วคราว** เก็บ import/changing ของ BAdI ทุก call ลง custom table เพื่อ investigate R-01 · ทุก field เป็น predefined type ยาวตามรูป parameter | table `ZIME001_LOG` · class `ZCL_ZIME001_LOG` · Custom Logic | ✅ อยู่ใน repo `36cd138` รอเก็บข้อมูลจาก 3 กลุ่ม app · 2026-10-05 เปลี่ยน `batch_out_before` -> `batch_out` (table + parameter `iv_batch_out`) ตอน table ยังว่าง · table ต้องเพิ่ม `@AbapCatalog.primaryKey.invertedIndividualIndex : true` (warning Inverted Individual) · **ลบก่อน transport** |
| R-03 | 2026-10-05 | logic แยกตาม case โดย fix constant case ไว้ก่อน (`CASE_A` ...) แล้วค่อย map กับ data จาก log · **CASE_A = Production Order** (CO01 · CO02 · Mass Processing): order released + order type อยู่ใน constant `IME001` / `PRODUCTION_ORDER_TYPE` (ZCL_PARAM · module MM) -> YYMMDD จาก ScheduledStartDate · NNNN ต่อจาก `I_Batch` ของ material | `ZCL_ZIME001` · Custom Logic · ใช้ `ZCL_PARAM` (package `ZBCPARAM`) | ✅ 2026-10-06 ปรับตาม log อยู่ใน repo `5628054` (ล้าง order type ด้วย `ZCL_UTILITY` · ตัดเช็ค REL · ข้ามเลข order `%`) · constant parameter `IME001` / `PRODUCTION_ORDER_TYPE` maintain แล้ว (ผู้ใช้แจ้ง 2026-10-05) · `get_batch_case_a` ยังไม่ได้ทดสอบกับข้อมูลจริง · released = status `I0002` active · Custom Logic ยังเก็บ log อย่างเดียวจนกว่าได้ log ครบ |
| R-04 | 2026-10-06 | **CASE_B = Goods Receipt (MIGO A01 + R01)**: ถ้า `I_Product-IsBatchManagementRequired = X` -> YYMMDD จาก Posting Date · NNNN ต่อจาก `I_Batch` | `ZCL_ZIME001` | ✅ **draft** อยู่ใน repo `b432fcc` 2026-10-06 · constant parameter ตามที่ maintain บน tenant: `MOVEMENT_TYPE` ext `GOODS_RECEIPT` (101) และ `REF_DOC_TYPE` ext `PURCHASE_ORDER` (B) · module MM · Q-34 Q-36 ค้าง |
| R-05 | 2026-10-08 | **CASE_C = Inbound Delivery (VL31 เท่านั้น · VL32 ไม่เรียก BAdI)**: อ้างอิง PO เท่านั้น · PO type ไม่อยู่ใน `PO_DOCTYPE_STO` (E EQ ZP25) · `I_Product-IsBatchManagementRequired = X` · YYMMDD จาก Delivery Date · material เดียวกันหลาย item ต้องได้ batch เดียวกัน | `ZCL_ZIME001` | ✅ **draft** อยู่ใน repo `fc015ea` 2026-10-08 · PO type จาก `I_PurchaseOrderAPI01` · วันที่จาก `I_PurOrdScheduleLineAPI01` บรรทัดแรก (Q-39 ค้าง) · จำเลขของ item แรกใน `gt_delivery_batch` |
| R-07 | 2026-10-08 | กฎแยก case จาก `BATCH_ALLOCATION` + แก้ Custom Logic ให้เรียก `ZCL_ZIME001` จริง + ตัวแปรชั่วคราวเปิดปิด logic เพื่อไม่ให้กระทบ user อื่น | `ZCL_ZIME001` · Custom Logic | 🧪 2026-10-09 class release แล้ว (`a0148d9`) · Custom Logic publish แล้ว · เปิดเฉพาะ user `CB9980000010` (ชั่วคราว) · รอผลทดสอบจากฟังก์ชันนอล |
| R-06 | 2026-10-08 | **ทำท้ายสุด** · BAdI อีกตัวตอน VL32: validate ว่า Delivery Date = GR Actual Date และตรงกับ YYMMDD ของ batch ที่ gen ไว้ · ไม่ตรง -> error ห้าม Post · ยกเว้น PO type ZP25 (PO Intercom) ไม่เช็ค | ยังไม่ระบุ | ⏸️ รอทำหลัง CASE ทั้งหมด · 2026-10-09 ใช้ `LE_SHP_DELIVERY_FINAL_CHECK` · Custom Logic `YY1_SHP_DELIVERY_FINAL_CHECK` สร้างแล้ว · วิเคราะห์ signature ใน `09_vl32_final_check.md` · รอ Q-47 ถึง Q-50 |
| R-08 | 2026-10-09 | CASE_B รับ MIGO A01 + R08 (production order · `goodsmovementrefdoctype = F`) เพิ่มจาก R01 · `REF_DOC_TYPE` ไม่ใช้ Additional Parameter แล้ว (B และ F) ใช้ร่วมกับ CASE_C | `ZCL_ZIME001` | ✅ **draft** อยู่ใน repo `e463163` 2026-10-09 · รอ maintain `REF_DOC_TYPE` B และ F แบบ ext ว่าง แล้วทดสอบ MIGO R08 |
| R-09 | 2026-10-09 | CASE_C ใช้วันที่ปัจจุบัน local เป็น YYMMDD แทน delivery date ของ PO schedule line | `ZCL_ZIME001` | ✅ อยู่ใน repo `87c29f2` · ABAP Doc ของ method `get_batch_case_c` ยังเป็นข้อความเดิม (schedule line) · commit เดียวกัน comment `RETURN` ของเช็ค user ทดสอบใน `get_batch_number` -> **ผู้ใช้ยืนยันว่าตั้งใจ 2026-10-09** ให้ฟังก์ชันนอลทดสอบหลาย user · logic ทำงานกับทุก user บน DEV |

## จุดที่ค้าง (อัปเดต 2026-10-09)

- **รอฟังก์ชันนอลทดสอบ** ด้วย user `CB9980000010` แล้ว export `ZIME001_LOG` มาเทียบ
  - ✅ CASE_A: CO02 (`2610090003`) และ Mass Processing (`2610090004` `2610090005`) ผ่าน 2026-10-09
  - 🟨 CASE_B: MIGO A01 + R01 ได้ `2610090001` · รอ GR ใบถัดไปต้องได้ `0002`
  - ✅ CASE_B: MIGO A01 + R08 (F) ได้ `2610090001` (material 320000000)
  - CASE_C: VL31 หลาย item material เดียวกัน ต้องได้เลขเดียวกัน
  - user อื่นต้องได้เลขปกติ
- OQ ค้าง: Q-34 (Posting Date MIGO) · Q-36 (แยก app ไม่ได้) · Q-39 (Delivery Date VL31)
- **2026-10-09 ผู้ใช้แจ้งว่า process ของ VL31 / VL32 จะปรับ** รอรายละเอียด -> CASE_C (VL31) และ R-06 (VL32 validate) พักไว้ก่อน
- หลังฟังก์ชันนอลแก้ config order type `ZFG`: เปิดการเช็ค order type ใน `get_batch_case_a` กลับ และเปลี่ยน `PRODUCTION_ORDER_TYPE` กลับเป็น `EQ` `ZFG` (I-01)
- **ตั้งแต่ 2026-10-09 (`87c29f2`) เช็ค user ทดสอบถูกปิด logic ทำงานกับทุก user บน DEV** (ผู้ใช้ตั้งใจ)
- แก้ ABAP Doc ของ method `get_batch_case_c` ที่ยังพูดถึง schedule line (ไม่กระทบการทำงาน)
- ก่อน transport: ลบ `gc_test_user` และเงื่อนไขใน `get_batch_number` · ลบส่วน log ใน Custom Logic · `ZCL_ZIME001_LOG` เปลี่ยนเป็น Not Released แล้วลบ · ลบ `ZIME001_LOG`
