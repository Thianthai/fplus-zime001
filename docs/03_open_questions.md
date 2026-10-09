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
| Q-39 | **CASE_C ไม่มี Delivery Date** — **ชั่วคราว: ใช้ delivery date ของ PO schedule line บรรทัดแรก** จาก `I_PurOrdScheduleLineAPI01` · ไม่ตรงกับ requirement ที่ต้องการ Delivery Date ของ inbound delivery | ผู้ใช้ | ⬜ OQ ค้าง (2026-10-08) |
| Q-40 | **PO type ไม่มีใน BAdI** | ✅ **ปิด 2026-10-08** — `I_PurchaseOrderAPI01-PurchaseOrderType` (release C1) |
| Q-41 | **2 item ใช้ batch ใหม่เลขเดียวกันใน save เดียว** | ✅ **ปิด 2026-10-08** — ผู้ใช้ทดสอบแล้ว ระบบยอมให้ save |
| Q-42 | **ขอบเขตของ "material เดียวกัน = batch เดียวกัน"** | ✅ **ปิด 2026-10-08** — เฉพาะใน delivery เดียวกัน · คนละ PO item วันที่ต่างกันก็ต้องได้เลขเดียวกัน ยึดเลขของ item แรก |
| Q-43 | **log ของ VL32** | ✅ **ปิด 2026-10-08** — VL32 ไม่เรียก BAdI ตัวนี้ · CASE_C = VL31 เท่านั้น |
| Q-44 | **field ของ `I_PurOrdScheduleLineAPI01`** | ✅ **ปิด 2026-10-08** — key `PurchaseOrder` + `PurchaseOrderItem` + `PurchaseOrderScheduleLine` · ใช้ `ScheduleLineDeliveryDate` ของ schedule line เลขน้อยสุด (`ORDER BY` + `UP TO 1 ROWS`) |
| Q-45 | **กันเลขค้างจาก delivery ก่อนหน้า** | ✅ **ปิด 2026-10-08** — ทิ้งเลขที่จำไว้แล้วสร้างใหม่ เมื่อ batch นั้นอยู่ใน `I_Batch` แล้ว หรือเลข item ไม่เพิ่มขึ้น |
| Q-46 | **ตัวแปรเปิดปิด logic** | ✅ **ปิด 2026-10-09** — ไม่ใช้ true/false · เช็คแค่ user: ทำงานเฉพาะ `CB9980000010` (ค่าเดียวกับ `created_by` ใน log) · ชั่วคราว ลบก่อน go-live |
| Q-47 | **เก็บค่าจริงของ `LE_SHP_DELIVERY_FINAL_CHECK` ก่อนออกแบบ** | ✅ **ปิด 2026-10-09** — ไม่ trace · เขียน logic draft แล้วทดสอบจริงเลย |
| Q-48 | **เช็คเมื่อไร** | ✅ **ปิด 2026-10-09** — ทุกครั้งที่ save (CREATE · CHANGE) |
| Q-49 | **เช็ค item ไหน** | ✅ **ปิด 2026-10-09** — item ที่มี batch + material batch managed + อ้างอิง PO ที่ PO type ไม่ใช่ ZP25 |
| Q-50 | **ข้อความ error** | ✅ **ปิด 2026-10-09** — ภาษาอังกฤษ ข้อความกลาง ไม่ระบุ item / batch / วันที่ · (จำกัด user ทดสอบ: ยังไม่ได้ตอบ ถามซ้ำใน Q-51) |
| Q-51 | **R-06 รายละเอียดก่อนเขียน code** — (1) ยังไม่ Post GR (`actualgoodsmovementdate` ว่าง) เช็คแค่ Delivery Date = YYMMDD (2) จำกัดเฉพาะ user ทดสอบ `CB9980000010` เหมือน `ZCL_ZIME001` (3) วาง logic ใน `ZCL_ZIME001` | ผู้ใช้ | ⬜ |
| Q-52 | **CASE_B รับ `REF_DOC_TYPE` ทั้ง B และ F** | ✅ **ปิด 2026-10-09** — (1) MIGO R08 รับของจาก production order เข้า CASE_B (2) YYMMDD = วันที่ปัจจุบัน (3) `REF_DOC_TYPE` maintain 2 แถว ext ว่าง: B และ F · CASE_B และ CASE_C ใช้ range เดียวกัน ไม่ส่ง `iv_param_ext` (4) ยังไม่มี log ของ MIGO R08 ทำ draft ไปก่อน |
