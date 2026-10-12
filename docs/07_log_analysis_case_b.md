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
| 10:41:45 | 0000000157 | **2610090001** | 2110000127 / 00010 | ไม่ได้ Post (ผู้ใช้ยืนยัน) |
| 10:42:52 | 0000000158 | **2610090001** | 2110000127 / 00010 | Post สำเร็จ ✅ |

- format ถูก · YYMMDD = วันที่ปัจจุบัน local
- ทั้งสองรอบได้เลขเดียวกันถูกต้อง เพราะรอบแรกไม่ได้ Post (I-02 ปิดแล้ว)
- รอทดสอบ GR ใบถัดไปของ material เดียวกัน ต้องได้ `2610090002`

## Constant parameter หลัง R-08 (2026-10-09)

| Parameter | Additional Parameter | Low | ใช้ที่ |
|---|---|---|---|
| `MOVEMENT_TYPE` | `GOODS_RECEIPT` | 101 | CASE_B |
| `REF_DOC_TYPE` | (ว่าง) | B | CASE_B · CASE_C |
| `REF_DOC_TYPE` | (ว่าง) | F | CASE_B (MIGO R08 production order) |

## ผลทดสอบ MIGO A01 + R08 (2026-10-09)

| เวลา (UTC) | material | `goodsmovementtype` | `goodsmovementrefdoctype` | `manufacturingorder` | `ordercategory` | `batch_out_after` |
|---|---|---|---|---|---|---|
| 11:23:54 | 320000000 (ZSFG) | 101 | **F** | 000013000027 | **00** | 0000000161 ❌ ไม่ได้เลขใหม่ |

- ยืนยันว่า MIGO R08 ส่ง `goodsmovementrefdoctype = F` และเลข production order มา โดย `ordercategory = 00` (ไม่ใช่ 10) -> `determine_case` ได้ CASE_B ถูกต้อง
- ไม่ได้เลข -> `get_batch_case_b` ข้ามที่ขั้นใดขั้นหนึ่ง (I-03)
| 11:44:17 | 320000000 (ZSFG) | 101 | F | 000013000028 | 00 | **2610090001** ✅ ทดสอบซ้ำหลัง maintain F |

## วิเคราะห์: หา Posting Date จาก BAdI อื่นแล้วเก็บใน static attribute (2026-10-12)

แนวคิดจากผู้ใช้: ใช้ BAdI อื่นใน MIGO ที่เห็น Posting Date เก็บค่าใส่ static attribute ก่อน `LOBM_AFTER_BATCH_NUMBER_INT` ถูกเรียก แบบเดียวกับ `gt_delivery_batch` ของ CASE_C

เงื่อนไขที่ต้องครบทั้ง 3 ข้อ
1. มี cloud BAdI ที่ถูกเรียกใน **MIGO** และส่ง Posting Date มา
2. BAdI นั้นถูกเรียก **ก่อน** ระบบจองเลข batch (ตอนกด Check หรือตอนใส่ item)
3. static attribute อยู่ข้าม BAdI ทั้งสองตัวใน session เดียวกัน

ที่หาได้
- cloud BAdI ของ goods receipt ที่มี header คือ `MMIM_GR4XY_PROVIDE_DATA` / `MMIM_GR4XY_CHECK_DATA` แต่ทำงานกับ Fiori app **Post Goods Receipt for Purchasing Document** ไม่ถูกเรียกใน MIGO (SAP Community)
- `MB_MIGO_BADI` / `MB_DOCUMENT_BADI` เป็น classic BAdI ของ ECC ไม่พบว่า release บน Public Cloud
- SAP KBA 3459964 รวบรวม feature gap ของ Inventory Management ใน Public Cloud

สรุปเบื้องต้น: น่าจะทำไม่ได้ใน MIGO · ต้องให้ผู้ใช้ยืนยันในแอป Custom Logic ว่าไม่มี BAdI ของ MIGO ที่มี posting date

### Business Context ของ Inventory Management บน tenant (ผู้ใช้ส่งมา 2026-10-12)

| Business Context | ใช้กับ MIGO ได้ไหม |
|---|---|
| Inventory Management: Fiori Apps Manage Stock, Transfer Stock in Plant and cross Plant | ไม่ใช่ · Fiori app |
| Inventory Management: Goods Receipt for Fiori apps PurOrd, ProdnOrd, NoRef, InbDeliv | ไม่ใช่ · `MMIM_GR4XY_*` ของ Fiori GR app |
| **Inventory Management: Material Document** | น่าจะใช่ · ระดับเอกสาร ใช้ได้กับทุก app ที่สร้าง material document · รอดูรายชื่อ BAdI |
| **Inventory Management: Material Document Item** | น่าจะใช่ · ระดับ item · รอดูรายชื่อ BAdI |

