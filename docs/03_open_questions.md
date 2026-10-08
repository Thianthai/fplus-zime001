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
| Q-28 | **เช็ค released ด้วย status** | ✅ **ปิด 2026-10-05** — `I_ManufacturingOrderStatus` `StatusCode = 'I0002'` + `StatusIsInactive = abap_false` (release C1 ผู้ใช้เช็คแล้ว) |
| Q-29 | **PREL นับเป็น released หรือไม่** | ✅ **ปิด 2026-10-05** — ไม่นับ |
| Q-30 | **ฟังก์ชันนอลทำอะไรในแต่ละ app** | ✅ **ปิด 2026-10-06** — CO01 สร้างพร้อม Release · CO02 แก้ Stock Type แล้ว Release · config `ZFG` สร้าง batch ตอน release · Mass Processing ที่จอแสดง CRTD ไม่กระทบ logic (ถ้า release ไม่สำเร็จ batch ก็ไม่ถูก save) |
| Q-31 | **CO01 ไม่มี order ใน DB** | ✅ **ปิด 2026-10-06** — (ค) ปรับ process: สร้างใน CO01 โดยไม่ Release แล้วค่อย release ใน CO02 / Mass Processing · code ข้ามเลข order ที่ขึ้นต้นด้วย `%` |
| Q-32 | **`ordertype` มี U+200B ต่อท้าย** | ✅ **ปิด 2026-10-06** — ล้างในโค้ดด้วย `zcl_utility=>remove_invisible_char( )` (`5628054`) · เดิมใช้ `zcl_param=>sanitize( )` ซึ่งย้ายไป `ZCL_UTILITY` แล้ว (`fplus-zbcparam` `8cb234f` · `fplus-zbcutility` `6b260a1`) |
| Q-33 | **ตัดการเช็ค status `I0002` ใน DB หรือไม่** | ✅ **ปิด 2026-10-06** — order type `ZFG` ตั้ง automatic batch creation **ตอน release** (ฟังก์ชันนอลยืนยัน) BAdI ถูกเรียก = กำลัง release -> ตัดการเช็ค status ทิ้ง |
| Q-34 | **CASE_B ไม่มี Posting Date** ใน BAdI และเอกสารยังไม่ post · **ชั่วคราว: ใช้วันที่ปัจจุบัน local ผ่าน `ZCL_UTILITY=>get_local_datetime( )`** ผิดเมื่อ user แก้ Posting Date | ผู้ใช้ | ⬜ OQ ค้าง (2026-10-06) |
| Q-35 | **movement type ที่รองรับ** | ✅ **ปิด 2026-10-06** — ตอนนี้ `101` · เก็บใน constant parameter `IME001` / `GR_MOVEMENT_TYPE` (module MM) เพิ่มทีหลังได้ |
| Q-36 | **แยก app ไม่ได้** — ต้อง support เฉพาะ MIGO แต่ BAdI ไม่บอก app · GR อ้างอิง PO จาก app อื่นจะเข้า CASE_B ด้วย | ผู้ใช้ | ⬜ OQ ค้าง (2026-10-06) หาทางออกหลังทำครบทุก case |
| Q-37 | **BAdI ถูกเรียกตอน Check ไม่ใช่ Post** | ✅ **ปิด 2026-10-06** — ยอมรับ |
| Q-38 | **constant parameter `PO_DOCTYPE_STO` ใช้กับ case ไหน** | ✅ **ปิด 2026-10-08** — ใช้กับ CASE_C (Inbound Delivery) ไม่ใช้กับ CASE_B |
| Q-39 | **CASE_C ไม่มี Delivery Date** — VL31 เลข delivery ชั่วคราว `$` อ่าน DB ไม่ได้ · ทางเลือก: (ก) delivery date ของ PO schedule line จาก PO + item (ข) วันที่ปัจจุบัน local · VL32 เลข delivery จริงอ่าน header ได้ (ต้องหา view ที่ release) | ผู้ใช้ | ⬜ |
| Q-40 | **PO type ไม่มีใน BAdI** (`purchaseordertype` ว่าง) — อ่านจาก `I_PurchaseOrderAPI01-PurchaseOrderType` (ต้องเช็ค release C1) | ผู้ใช้เช็คใน ADT | ⬜ |
| Q-41 | **material เดียวกันหลาย item ต้องได้ batch เดียวกัน** — ใน save เดียวกัน `I_Batch` ยังไม่เห็น batch ของ item แรก จึงได้เลขเดียวกันเองถ้า YYMMDD เท่ากัน · ต้องทดสอบว่า standard ยอมให้ 2 item ใช้ batch ใหม่เลขเดียวกันใน save เดียวหรือไม่ | ผู้ใช้ทดสอบ | ⬜ |
| Q-42 | **ขอบเขตของ "material เดียวกัน = batch เดียวกัน"** — เฉพาะใน delivery เดียวกันหรือไม่ · ถ้าคนละ PO item แล้ว delivery date ต่างกันล่ะ · (VL32 เพิ่ม item ไม่ต้องคิดแล้ว เพราะ VL32 ไม่เรียก BAdI) | ผู้ใช้ | ⬜ |
| Q-43 | **log ของ VL32** | ✅ **ปิด 2026-10-08** — VL32 ไม่เรียก BAdI ตัวนี้ · CASE_C = VL31 เท่านั้น |
