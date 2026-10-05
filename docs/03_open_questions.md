# 03 — ทะเบียนข้อสงสัย

| # | เรื่อง | ใครตอบ | สถานะ |
|---|---|---|---|
| Q-01 | **`YY` ต้องเท่ากับปีปัจจุบัน หรือ 00-99** | ✅ **ปิด 2026-10-05** — ต้องเท่ากับปีปัจจุบัน (timezone แยกไป Q-06) |
| Q-02 | **`DD` เช็คแค่ 01-31 หรือต้องเป็นวันที่มีจริง** | ✅ **ปิด 2026-10-05** — ต้องเป็นวันที่มีจริง |
| Q-03 | **ค่าที่สั้นกว่า 10 หรือมีช่องว่าง** | ✅ **ปิด 2026-10-05** — ไม่ผ่าน |
| Q-04 | **logic ของ Custom Logic** | ✅ **ปิด 2026-10-05** — Incoming = `batch_in` · ผ่านแล้ว `batch_out` = batch ล่าสุดของ material +1 จาก CDS · ไม่เคยมี `NNNN = 0001` · ทำ method generate เพิ่ม (รายละเอียด Q-07 ถึง Q-12) |
| Q-05 | **type ของ parameter** | ✅ **ปิด 2026-10-05** — `CHARG_D` release C1 แล้ว (ผู้ใช้เช็คใน ADT) |
| Q-06 | **"ปีปัจจุบัน" ใช้วันที่ timezone ไหน** | ✅ **ปิด 2026-10-05** — fix `UTC+7` ตายตัว (system time UTC ตั้งแต่ 17:00 ถือเป็นวันถัดไป) |
| Q-07 | **`YYMMDD` ของ `batch_out` มาจากไหน** | ✅ **ปิด 2026-10-05** — วันที่ปัจจุบัน (UTC+7) |
| Q-08 | **running number นับแยกอย่างไร** | ✅ **ปิด 2026-10-05** — หา `NNNN` สูงสุดของ material ที่ขึ้นต้นด้วย `YYMMDD` เดียวกัน แล้ว +1 |
| Q-09 | **CDS ที่ใช้** | ✅ **ปิด 2026-10-05** — `I_Batch` (release C1 ผู้ใช้เช็คแล้ว) · การกรอง plant แยกไป Q-13 |
| Q-10 | **`NNNN` ถึง 9999 แล้ว** | ✅ **ปิด 2026-10-05** — skip ไม่แตะ `batch_out` (business จริงไม่เกิน 9999) |
| Q-11 | **`batch_in` ไม่ผ่าน format** | ✅ **ปิด 2026-10-05** — ไม่แตะ `batch_out` |
| Q-12 | **เลขชนกัน** (batch ที่ยังไม่ commit ไม่เห็นใน CDS) | ✅ **ปิด 2026-10-05** — ผู้ใช้ยอมรับความเสี่ยง |
| Q-13 | **กรอง plant ตอนหา batch ล่าสุดหรือไม่** | ✅ **ปิด 2026-10-05** — ไม่กรอง (batch level ระดับ material) |
| Q-14 | **type ของ `iv_material`** | ✅ **ปิด 2026-10-05** — `MATNR` release C1 (ผู้ใช้เช็คใน ADT) |
| Q-15 | **`I_Batch` มี access control** | ✅ **ปิด 2026-10-05** — ใช้ `WITH PRIVILEGED ACCESS` เสมอ เพราะเรียกจาก Custom Logic |
| Q-16 | **จำกัด Custom Logic เฉพาะบาง plant / material type / movement type หรือไม่** | ✅ **ปิด 2026-10-05** — ยังไม่จำกัด |
| Q-17 | **ค่า `BATCH_ALLOCATION` จริงของแต่ละ app ใน R-01** — trace ด้วยแอป Custom Logic Tracing แล้วส่งค่ามาวิเคราะห์ · ✅ CO01/CO02 กับ Mass Processing ใช้ logic เดียวกัน (2026-10-05) เหลือแยก 3 กลุ่ม | ผู้ใช้ | ⬜ รอ trace |
| Q-18 | **ชื่อ field ของ `ZIME001_LOG`** | ✅ **ปิด 2026-10-05** — ใช้ชื่อเดียวกับ BAdI ตรง ๆ (ยกเว้นกฎ snake_case เพราะเป็น table ชั่วคราว) |
| Q-19 | **แยก class log** | ✅ **ปิด 2026-10-05** — แยกเป็น `ZCL_ZIME001_LOG` ไม่แตะ `ZCL_ZIME001` |
| Q-20 | **สวิตช์ปิด log** | ✅ **ปิด 2026-10-05** — constant `gc_active` ใน `ZCL_ZIME001_LOG` |
| Q-21 | **ใครเป็นคนกำหนด case** | ✅ **ปิด 2026-10-05** — draft ไว้ก่อน ค่อยแก้ทีหลังเมื่อได้ log · ตอนนี้ fix `CASE_A` |
| Q-22 | **อ่านสถานะ release + ScheduledStartDate จาก CDS ไหน** | ✅ **ปิด 2026-10-05 (draft)** — `I_ManufacturingOrder`: วันที่ = `MfgOrderScheduledStartDate` · ไม่มี field `OrderIsReleased` -> ใช้ `MfgOrderActualReleaseDate IS NOT INITIAL` แทน (ทางเลือก: status `I0002` ผ่าน `_MfgOrderStatus`) |
| Q-23 | **จังหวะเวลา** | ✅ **ปิด 2026-10-05 (draft)** — อ่านไม่เจอหรือยังไม่ released -> ข้าม ไม่แตะ `batch_out` · ของจริงค่อยแก้ |
| Q-24 | **order type เช็คจากไหน** | ✅ **ปิด 2026-10-05** — `batch_allocation-ordertype` |
| Q-25 | **CASE_A validate `batch_in` หรือไม่** | ✅ **ปิด 2026-10-05** — ไม่ใช้กฎเดิม ใช้วันที่จาก ScheduledStartDate |
| Q-26 | **ส่งวันที่เข้า `generate_batch_number`** | ✅ **ปิด 2026-10-05** — เพิ่ม optional `iv_date` ใน method เดิม · วันที่ปัจจุบันใช้ `zcl_utility=>get_local_datetime( )` (package `ZBCUTILITY`) แทนการบวก 7 ชม. เอง |
| Q-27 | **constant parameter** | ✅ **ปิด 2026-10-05** — `zcl_param=>create_instance( iv_company_code = '' iv_module_id = 'MM' )` · app `IME001` · param `PRODUCTION_ORDER_TYPE` · ไม่เจอ -> ข้าม |
