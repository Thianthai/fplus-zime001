# 08 — วิเคราะห์ log CASE_C (Inbound Delivery · VL31 / VL32)

ข้อมูล: export `ZIME001_LOG` จากฟังก์ชันนอล 2026-10-08 · VL31 เท่านั้น (ยังไม่มี VL32)
- Single item: 1 row · 04:24:39 UTC
- Multiple items: 2 row · 04:28:09.037 และ 04:28:09.068 UTC (ห่างกัน 31 ms -> save ครั้งเดียวกัน)

## ข้อมูลดิบ (เฉพาะ field ที่มีค่า)

| | Single | Multi item 1 | Multi item 2 |
|---|---|---|---|
| `batch_in` | 0000000125 | 0000000126 | 0000000127 |
| `material` | 500000212 | 500000212 | 500000212 |
| `purchaseorder` / item | 2110000117 / 00010 | 2110000121 / 00010 | 2110000121 / 00020 |
| `deliverydocument` | `$       1` | `$       1` | `$       1` |
| `deliverydocumentitem` | 000010 | 000010 | 000020 |
| `goodsmovementtype` | 101 | 101 | 101 |
| `goodsmovementrefdoctype` | B | B | B |
| `manufacturingorderitem` | 0010 | 0010 | 0020 |

ค่าเดียวกันทุก row: `plant` 1000 · `materialgroup` 50AE02060 · `materialtype` ZPK · `supplier` 1000000019
ว่างทุก row: `storagelocation` · `purchasingorganization` · `planningplant` · **`purchasingdocumentcategory`** · **`purchaseordertype`** · `ordertype` · ไม่มี non-ASCII
`batch_out` = `batch_out_after` = `batch_in` ทุก row (Custom Logic ไม่แตะ ถูกต้อง)

## ข้อค้นพบ

| # | เรื่อง | ผล |
|---|---|---|
| H1 | **เลข delivery ชั่วคราว `$` + ช่องว่าง 7 ตัว + `1`** ตอน VL31 · delivery ยังไม่ถูกบันทึก | อ่าน header ของ delivery จาก DB ไม่ได้ |
| H2 | **ไม่มี Delivery Date ใน BAdI** | ต้องหาแหล่งอื่น (Q-39) |
| H3 | **`purchaseordertype` ว่าง** | ต้องอ่าน PO type เองจาก view ของ PO เพื่อเช็ค `PO_DOCTYPE_STO` (Q-40) |
| H4 | BAdI ถูกเรียก **1 ครั้งต่อ item** · ระบบดึงเลข number range ใหม่ทุก item (126 · 127) | ต้องทำให้ item ที่ material เดียวกันได้เลขเดียวกันเอง (Q-41) |
| H5 | ทั้ง 2 item ถูกเรียกใน save เดียวกัน ก่อน commit | batch ของ item แรกยังไม่อยู่ใน `I_Batch` ตอน item ที่ 2 -> ถ้า YYMMDD เท่ากัน `next_batch_number` จะได้ NNNN เดียวกันเองโดยธรรมชาติ |
| H6 | แยกจาก CASE_B ได้ | CASE_B: `deliverydocument` ว่าง · CASE_C: `deliverydocument` มีค่า (รวมเลขชั่วคราว `$`) |
| H7 | `manufacturingorderitem` มีค่า 0010 / 0020 ทั้งที่ไม่ใช่ production order | ไม่ใช้ field นี้ใน CASE_C |

## คำถาม (Q-39 ถึง Q-43 ใน `03_open_questions.md`)
