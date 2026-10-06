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
