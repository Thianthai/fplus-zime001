# 06 — วิเคราะห์ log CASE_A (Production Order)

ข้อมูล: export `ZIME001_LOG` จากฟังก์ชันนอล 2026-10-06 · 5 row · user ทดสอบคนเดียว · client 100

## ข้อมูลดิบ (เฉพาะ field ที่มีค่า)

| App | เวลา (UTC) | `batch_in` | `manufacturingorder` | `ordertype` | `ordercategory` | `manufacturingorderitem` |
|---|---|---|---|---|---|---|
| CO01 | 03:51:53 | 0000000109 | `%00000000001` | `ZFG` + U+200B | 10 | 0001 |
| CO02 | 04:07:09 | 0000000110 | 000014000100 | `ZFG` + U+200B | 10 | 0001 |
| Mass Processing | 04:26:24 | 0000000111 | 000014000101 | `ZFG` + U+200B | 10 | 0001 |
| Mass Processing | 04:26:27 | 0000000112 | 000014000102 | `ZFG` + U+200B | 10 | 0001 |
| Mass Processing | 04:26:28 | 0000000113 | 000014000103 | `ZFG` + U+200B | 10 | 0001 |

ค่าที่เหมือนกันทุก row: `material` = `pricingreferencematerial` = 000000000100000316 · `plant` = `planningplant` = `productionplant` = 1000 · `storagelocation` 1000 · `materialgroup` A03063000 · `materialtype` ZFG
ค่าว่างทุก row: `goodsmovementtype` · `goodsmovementrefdoctype` · `purchaseorder` · `deliverydocument` · `supplier` · `salesorder`
`batch_out` = `batch_out_after` = `batch_in` ทุก row (Custom Logic ไม่แตะ ถูกต้อง) · `is_valid_format` ว่างทุก row

## ข้อค้นพบ

| # | เรื่อง | ผลต่อ draft CASE_A |
|---|---|---|
| F1 | BAdI ถูกเรียก **1 ครั้งต่อ 1 order** ทั้ง 3 app (Mass Processing 3 order = 3 row) | ไม่มีปัญหาเรียกซ้ำ |
| F2 | ตัวระบุ CASE_A: `ordercategory = 10` · `manufacturingorder` มีค่า · `goodsmovementtype` ว่าง | ใช้เป็นกฎแยก case ได้ (รอเทียบกับ log ของ MIGO ที่รับของจาก production order) |
| F3 | **`ordertype` มี zero-width space (U+200B) ต่อท้าย** `ZFG` ทุก row · field อื่นไม่มี | draft เทียบกับ constant parameter `ZFG` ตรง ๆ -> **ไม่ตรงเลย ข้ามทุกครั้ง** |
| F4 | **CO01 ได้เลข order ชั่วคราว `%00000000001`** order ยังไม่ถูกบันทึก | draft อ่าน `I_ManufacturingOrder` ไม่เจอ -> **ข้ามเสมอ** · ไม่มี ScheduledStartDate ให้ใช้ |
| F5 | CO02 และ Mass Processing ได้เลข order จริง | อ่าน `I_ManufacturingOrder` ได้ · แต่ถ้า BAdI ถูกเรียกระหว่างกด Release status `I0002` ยังไม่อยู่ใน DB -> **ข้าม** |
| F6 | `batch_in` เป็นเลขเรียงจาก number range (109 ถึง 113) ไม่ใช่ format YYMMDDNNNN | CASE_A ไม่ใช้ `batch_in` อยู่แล้ว ไม่กระทบ |
| F7 | `material` เป็น internal format 18 หลักเติมศูนย์ | ตรงกับ `I_Batch-Material` ไม่ต้องแปลง |

## คำถามที่ต้องตอบก่อนแก้ (Q-30 ถึง Q-33 ใน `03_open_questions.md`)

## ข้อมูลเพิ่มจากฟังก์ชันนอล (2026-10-06)

| App | ทำอะไร | status หลังทำ | batch ที่ได้ |
|---|---|---|---|
| CO01 | สร้างพร้อมกด Release · ข้อความ `Release carried out` | REL MSPT BASC BCRQ | 0000000109 |
| CO02 | แก้ Stock Type แล้วกด Release · ข้อความ `Release carried out` | REL MSPT PRC BASC BCRQ | 0000000110 |
| Mass Processing | ยังไม่ทราบ action · ข้อความ `Mass processing executed - 3 log(s) created (0 / 0 / 3 / 0)` และไอคอน warning ทุกแถว | **CRTD** MSPT PRC BC... (ยังไม่ released) | 0000000111 ถึง 0000000113 |

- CO01 และ CO02: BAdI ถูกเรียก **ตอนกด Release** ก่อน save -> status REL ยังไม่อยู่ใน DB ตอนนั้น
- Mass Processing: batch ถูกสร้างทั้งที่หน้าจอยังแสดง CRTD -> ต้องรู้ action และ status จริงหลัง save ก่อนสรุปว่า "BAdI ถูกเรียก = กำลัง release"
- ผู้ใช้เลือกแก้ U+200B ด้วย `zcl_param=>sanitize( )` ในโค้ด (Q-32)

## แหล่ง YYMMDD สำหรับ CO01 (Q-31)

ตอน BAdI ถูกเรียกใน CO01 order ยังไม่ถูกบันทึก ไม่มี released API ไหนอ่านค่าระหว่างทำรายการได้
- parameter ของ BAdI ไม่มีวันที่
- `I_ManufacturingOrder` ยังไม่มี row
- ABAP Cloud อ่าน memory ของ transaction ไม่ได้
ทางเลือก: (ก) ใช้วันที่ปัจจุบัน local เฉพาะ order ที่เลขขึ้นต้นด้วย `%` (ข) ข้าม ใช้เลขปกติ (ค) ปรับ process ให้สร้างก่อนแล้วค่อย release ใน CO02 หรือ Mass Processing

## Logic ใหม่ของ CASE_A (เสนอ 2026-10-06)

1. ล้าง `ordertype` ด้วย `zcl_param=>sanitize( )` แล้วเช็คกับ constant parameter `PRODUCTION_ORDER_TYPE`
2. **ไม่เช็ค status REL** เพราะ `ZFG` สร้าง batch ตอน release อยู่แล้ว (Q-33)
3. YYMMDD
   - เลข order ขึ้นต้นด้วย `%` (CO01 ยังไม่ save) -> รอผู้ใช้เลือกทางใน Q-31
   - เลข order จริง (CO02 · Mass Processing) -> `MfgOrderScheduledStartDate` จาก `I_ManufacturingOrder` · อ่านไม่เจอ -> ข้าม
4. NNNN ตาม logic เดิมจาก `I_Batch`

