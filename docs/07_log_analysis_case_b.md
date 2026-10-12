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

### BAdI ใต้ Material Document / Material Document Item (ผู้ใช้ส่งมา 2026-10-12)

| BAdI | คำอธิบาย | ความน่าสนใจ |
|---|---|---|
| **`MMIM_CREATE_GM_POSTING_DATE`** | Change Posting Date of Material Document Before First Validation | ⭐ สูงสุด · เห็น posting date และถูกเรียก **ก่อน validation แรก** -> น่าจะก่อนจองเลข batch |
| `MMIM_HEAD_PROVIDE_DATA` | Change Header in Material Documents | สูง · header มี posting date · ต้องรู้จังหวะ |
| `MMIM_HEAD_CHECK_DATA` | Check Header in Material Documents | กลาง · check น่าจะตอน Post (ช้าเกินไป) |
| **`MMIM_ITEM_PROVIDE_DATA`** | Change Item Data in Material Documents | ⭐ สูง · ถ้าแก้ batch ของ item ได้และเห็น posting date อาจกำหนดเลข batch ที่นี่เลยแทน `LOBM_AFTER_BATCH_NUMBER_INT` |
| `MMIM_BATCH_MASTER` | Maintenance of Batch Master Data for Goods Movements | กลาง · ดูว่ามีอะไรให้แก้ |
| `MMIM_ITEM_CHECK_DATA` / `BADI_MMIM_CHECK_MATDOC_ITEM` | Check Item Data | ต่ำ · check |
| `FIRU_*` · `IM_M11_*` · `MMKZ_*` · `RV_M4_*` | form / report ของรัสเซีย ยูเครน คาซัคสถาน | ไม่เกี่ยว |

### `MMIM_CREATE_GM_POSTING_DATE` (ผู้ใช้ส่ง doc + parameter 2026-10-12)

- Enhancement spot `MMIM_CREATE_GOODS_MOVEMENT` · interface `IF_MMIM_CREATE_GM_POSTING_DATE` · Released ทั้ง key user และ developer extensibility
- ใช้แก้ posting date ที่ระบุมาแล้ว ให้อยู่ในช่วง `minimalopenpostingdate` ถึง `maximalopenpostingdate`
- Importing: `CTRLPOSTGFOREXTWHSEMGMTSYST` · `MAXIMALOPENPOSTINGDATE` · `MINIMALOPENPOSTINGDATE` · `OPENPOSTINGPERIODS` (table: company code · min/max date · from/to fiscal period · fiscal year variant) · `VALUECHAINCATEGORY` · `VALUECHAINSTEPTYPE` · `VALUECHAINTYPE`
- Changing: **`POSTINGDATE`**

ข้อสังเกต
- เห็น posting date ✅ · ไม่ต้องแก้ค่า แค่อ่านแล้วเก็บ
- **ไม่มีเลขเอกสาร / item / material** -> ผูกกับการเรียก `LOBM_AFTER_BATCH_NUMBER_INT` ได้ทาง session เท่านั้น (ค่าล่าสุดที่เก็บไว้)
- ชื่อ enhancement spot และ field value chain บอกว่าเป็นของ framework สร้าง goods movement ใหม่ (Fiori / API) -> **ยังไม่รู้ว่า MIGO เรียกหรือไม่** และเรียกก่อนจองเลข batch หรือไม่ -> ต้องทดสอบ

### ผลทดสอบจังหวะด้วย Custom Logic Tracing (2026-10-12)

MIGO A01 + R08 · order 13000028 · กด Check · trace 13:36:27
1. `YY1_CREATE_GM_POSTING_DATE` ถูกเรียก **ก่อน** (43 ms) · `POSTINGDATE` = 20261012 · `MINIMALOPENPOSTINGDATE` 20260901 · `MAXIMALOPENPOSTINGDATE` 20261031
2. `YY1_AFTER_BATCH_NUMBER_INT` ถูกเรียก **หลัง** (225 ms) ใน trace เดียวกัน -> batch `2610120001`

สรุป: ✅ MIGO เรียก `MMIM_CREATE_GM_POSTING_DATE` และเรียกก่อนจองเลข batch -> แนวคิดเก็บ posting date ใน static attribute ทำได้
ยังต้องทดสอบ: posting date ที่ไม่ใช่วันนี้ · หลาย item · แก้ posting date หลัง Check แล้ว

### ทดสอบแก้ posting date หลัง Check แล้ว (2026-10-12 13:42)

- แก้ Posting Date เป็น 08.10.2026 แล้วกด Check อีกครั้ง
- `YY1_CREATE_GM_POSTING_DATE` ถูกเรียกใหม่ · `POSTINGDATE` = 20261008 ✅ (ยืนยันว่าได้ค่าที่ user แก้)
- `YY1_AFTER_BATCH_NUMBER_INT` **ไม่ถูกเรียกซ้ำ** เพราะ item มี batch แล้ว -> batch ยังเป็น `2610120001` · ระบบขึ้น "Document is O.K."
- ผล: ถ้าแก้ posting date หลังได้เลข batch แล้ว YYMMDD จะไม่ตรงกับ posting date -> ต้องมี validate หรือ business rule

### `BADI_MMIM_CHECK_MATDOC_ITEM` (ผู้ใช้ส่ง doc + parameter 2026-10-12)

- ใช้ check header และ item ของ material document แล้วส่ง message กลับ · **รองรับ MIGO** (และ SOAP API · OData API · GR without reference · GI / transfer posting)
- Importing `HEADER_MATDOC`: `MATERIALDOCUMENT` · `MATERIALDOCUMENTYEAR` · `MATERIALDOCUMENTHEADERTEXT` · **`POSTINGDATE`** · `DOCUMENTDATE` · `CREATIONTIME` · `CREATEDBYUSER` · `CREATIONDATE` · `VERSIONFORPRINTINGSLIP`
- Importing `ITEM_MATDOC` (ทีละ item): `MATERIAL` · `PLANT` · `STORAGELOCATION` · **`BATCH`** · **`GOODSMOVEMENTTYPE`** · `SUPPLIER` · `PURCHASEORDER` / item · `MANUFACTURINGORDER` / item · **`GOODSMOVEMENTREFDOCTYPE`** · `DELIVERYDOCUMENT` / item · `SHELFLIFEEXPIRATIONDATE` · `MANUFACTUREDATE` ฯลฯ
- Changing `MESSAGES` (table): `MESSAGETYPE` (S E W I A) · `MESSAGETEXT` (220 · ใช้ได้ 200 ตัว)
- doc: บาง process อาจไม่ได้เติมทุก field

สรุป: ✅ มี posting date + batch + เงื่อนไขของ CASE_B ครบใน BAdI เดียว · validate ได้โดยไม่ต้องพึ่ง static attribute · ส่ง error ได้หลายข้อความ
ยังต้องยืนยันด้วย trace: ถูกเรียกตอน Check · field `POSTINGDATE` และ `BATCH` มีค่าจริงใน MIGO

### เอกสารที่ post ระหว่างทดสอบโดยไม่ตั้งใจ (2026-10-12)

| Material document | ปี | หมายเหตุ |
|---|---|---|
| 5000000260 | 2026 | GR order 13000028 · batch `2610120001` · post โดยไม่ตั้งใจ |
| 5000000261 | 2026 | cancel ของ 5000000260 (movement 102) |

batch master `2610120001` ของ material 320000000 ยังอยู่ -> GR ถัดไปวันเดียวกันได้ `2610120002`

### Trace `BADI_MMIM_CHECK_MATDOC_ITEM` ใน MIGO (2026-10-12 14:03:53)

MIGO A01 + R08 · order 13000028 · กด Check · Custom Logic `YY1_CHECK_MATDOC_ITEM` ใส่ error ทดสอบทุกกรณี
ลำดับใน trace เดียวกัน
1. `YY1_CREATE_GM_POSTING_DATE` (15 ms)
2. `YY1_AFTER_BATCH_NUMBER_INT` (114 ms) -> batch **`2610120002`** (0001 ถูกใช้แล้วจาก GR ที่ reverse ไป · running number ถูกต้อง)
3. `YY1_CHECK_MATDOC_ITEM` (12 ms)
   - `HEADER_MATDOC-POSTINGDATE` = 20261012 ✅ · `MATERIALDOCUMENT` ว่าง (ยังไม่ post)
   - `ITEM_MATDOC-BATCH` = 2610120002 ✅ · `GOODSMOVEMENTTYPE` 101 · `GOODSMOVEMENTREFDOCTYPE` F · `MANUFACTURINGORDER` 000013000028 · `DELIVERYDOCUMENT` ว่าง · `MATERIAL` 000000000320000000
   - MESSAGES ออก E "Transaction not allowed." -> MIGO แสดงไฟแดงที่ item และ log error ✅

สรุป Q-60: ✅ ถูกเรียกตอน Check · หลัง BAdI สร้างเลข · field ครบ · error E แสดงใน MIGO และ item เป็นสีแดง

## Custom Logic ของ R-11 (ส่ง 2026-10-12)

`YY1_CREATE_GM_POSTING_DATE` (BAdI `MMIM_CREATE_GM_POSTING_DATE`)

```abap
" ZIME001 Automatic Batch Creation
" เก็บ posting date ไว้ให้การสร้างเลข batch ของ goods receipt ใช้เป็น YYMMDD
" ไม่แก้ posting date
zcl_zime001=>set_posting_date( postingdate ).
```

`YY1_CHECK_MATDOC_ITEM` (BAdI `BADI_MMIM_CHECK_MATDOC_ITEM`)

```abap
" ZIME001 Automatic Batch Creation
" ตรวจเลข batch ของ goods receipt ให้ตรงกับ posting date
" ไม่ผ่าน -> แสดง error และไม่ให้ post
DATA(lv_message) = zcl_zime001=>check_goods_receipt_item(
                     is_header = CORRESPONDING #( header_matdoc )
                     is_item   = CORRESPONDING #( item_matdoc ) ).

IF lv_message IS NOT INITIAL.
  APPEND VALUE #( messagetype = 'E'
                  messagetext = lv_message ) TO messages.
ENDIF.
```

## ผลทดสอบ R-11 (2026-10-12)

| # | ทดสอบ | ผล |
|---|---|---|
| 3 | posting date 12.10.2026 -> Check ได้ batch `2610120002` -> แก้ posting date เป็น 11.10.2026 -> Check | ✅ error `Batch date must be the same as the posting date.` · item ไฟแดง |
| 1 | posting date วันอื่นก่อน Check ครั้งแรก -> ได้ `YYMMDD` ตาม posting date | ⬜ |
| 2 | ข้อ 1 แล้ว Post | ⬜ |
| 4 | ข้อ 3 แล้วกด Post ต้อง post ไม่ได้ | ⬜ |
| 5 | GI / transfer posting ผ่านตามปกติ | ⬜ |

