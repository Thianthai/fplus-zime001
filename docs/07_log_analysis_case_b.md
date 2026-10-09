# 07 — วิเคราะห์ log CASE_B (Goods Receipt · MIGO)

ข้อมูล: export `ZIME001_LOG` จากฟังก์ชันนอล 2026-10-06 · 1 row · ฟังก์ชันนอลกด Check แล้ว Post · MIGO A01 Goods Receipt + R01 Purchase Order

## ข้อมูลดิบ (เฉพาะ field ที่มีค่า)

| Field | ค่า | ความหมาย |
|---|---|---|
| `created_at` | 2026-10-06 10:30:31 UTC | |
| `batch_in` = `batch_out` = `batch_out_after` | 0000000115 | Custom Logic ไม่แตะ ถูกต้อง |
| `material` | 000000000500000212 | internal format |
| `plant` / `planningplant` | 1000 | |
| `storagelocation` | 2001 | |
| `materialgroup` / `materialtype` | 50AE02060 / ZPK | |
| `supplier` | 1000000019 | |
| `purchasingorganization` | 1000 | |
| `goodsmovementtype` | **101** | GR goods receipt |
| `goodsmovementrefdoctype` | **B** | movement อ้างอิง purchase order |
| `purchaseorder` / `purchaseorderitem` | **2110000122** / 00010 | |
| `purchasingdocumentcategory` | F | purchase order |
| `ordercategory` | 00 | ไม่ใช่ production order |

ว่าง: `manufacturingorder` · `ordertype` · `deliverydocument` · `salesorder` · `batchbysupplier` · ไม่มี non-ASCII

## ข้อค้นพบ

| # | เรื่อง | ผล |
|---|---|---|
| G1 | กด Check แล้ว Post แต่ได้ **1 row** | BAdI ถูกเรียกครั้งเดียว น่าจะตอน Check (ระบบจองเลข batch ตอนนั้น แล้วใช้เลขเดิมตอน Post) |
| G2 | **A01 + R01 ไม่มีใน parameter ตรง ๆ** | อนุมานได้จาก `goodsmovementtype = 101` + `goodsmovementrefdoctype = B` + `purchaseorder` มีค่า + `deliverydocument` ว่าง |
| G3 | **ไม่มี Posting Date ใน parameter** · เอกสารยังไม่ post จึงอ่านจาก DB ไม่ได้ | ต้องใช้แหล่งอื่น (Q-34) |
| G4 | แยกจาก CASE_A ได้ชัด | CASE_A: `ordercategory = 10` + `goodsmovementtype` ว่าง · CASE_B: `goodsmovementtype` มีค่า + `goodsmovementrefdoctype = B` |
| G5 | BAdI ไม่รู้ว่ามาจาก app ไหน | GR อ้างอิง PO จาก app อื่น (ถ้ามี) จะมีหน้าตาเดียวกันและเข้า CASE_B ด้วย (Q-36) |

## คำถาม (Q-34 ถึง Q-37 ใน `03_open_questions.md`)

## Constant parameter บน tenant (ผู้ใช้ maintain 2026-10-06)

| Parameter | Additional Parameter | Sign | Option | Low | ใช้ที่ |
|---|---|---|---|---|---|
| `MOVEMENT_TYPE` | `GOODS_RECEIPT` | I | EQ | 101 | CASE_B |
| `REF_DOC_TYPE` | `PURCHASE_ORDER` | I | EQ | B | CASE_B |
| `PRODUCTION_ORDER_TYPE` | | I | EQ | ZFG | CASE_A |
| `PO_DOCTYPE_STO` | | E | EQ | ZP25 | ยังไม่ได้ใช้ใน code |

code ส่ง `iv_param_ext` ทุกครั้งที่ parameter มี Additional Parameter เพื่อไม่ให้ไปปนกับ row ของ case อื่นที่จะเพิ่มทีหลัง

## ผลทดสอบหลังเรียก `ZCL_ZIME001` จริง (2026-10-09)

| เวลา (UTC) | `batch_in` | `batch_out_after` | PO / item | หมายเหตุ |
|---|---|---|---|---|
| 10:41:45 | 0000000157 | **2610090001** | 2110000127 / 00010 | ทดสอบรอบแรก (ผู้ใช้: ยังไม่กด Post) |
| 10:42:52 | 0000000158 | **2610090001** | 2110000127 / 00010 | รอบที่สอง |

- format ถูก · YYMMDD = วันที่ปัจจุบัน local
- ทั้งสองรอบได้เลขเดียวกัน -> ถ้ารอบแรกไม่ได้ post ถือว่าถูก (batch ไม่ถูกบันทึก) · ถ้ารอบแรก post แล้วถือว่าผิด (I-02 รอผู้ใช้ยืนยันลำดับการทดสอบ)

