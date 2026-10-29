# 01 — Design

> สถานะ: **draft รอผู้ใช้รีวิว** (2026-10-02 · อัปเดตตามคำตอบ Q-01 ถึง Q-05 2026-10-05)

## BAdI `LOBM_AFTER_BATCH_NUMBER_INT`

ถูกเรียกหลังระบบกำหนดเลข batch แบบ internal

| Parameter | ทิศทาง | ใช้ทำอะไร |
|---|---|---|
| `BATCH_ALLOCATION` | Importing structure | ข้อมูลธุรกิจ เช่น `MATERIAL` `PLANT` `STORAGELOCATION` `SUPPLIER` `BATCHBYSUPPLIER` (15) `GOODSMOVEMENTTYPE` ฯลฯ |
| `BATCH_IN` | Importing | เลข batch ที่ระบบดึงจาก number range |
| `BATCH_OUT` | Changing | เลข batch ที่จะใช้จริง |

## แนวทาง

- logic ทั้งหมดอยู่ใน **`ZCL_ZIME001`** (developer extensibility) เพื่อให้ทดสอบด้วย ABAP Unit ได้และขึ้น git
- Custom Logic เหลือแค่ตัวเรียก class แล้วใส่ผลลง `batch_out`
- class ต้อง release **C1 + Use in Key User Apps** ไม่งั้น Custom Logic มองไม่เห็น

## กฎ format `YYMMDDNNNN`

| ข้อ | กฎ |
|---|---|
| 4.1 | ยาว 10 ตัวพอดี ค่าที่สั้นกว่าหรือมีช่องว่างไม่ผ่าน (Q-03) |
| 4.2 | เป็นตัวเลข 0-9 ทั้งหมด |
| 4.3 | `YY` = 2 หลักท้ายของ **ปีปัจจุบัน** ตามเวลา **UTC+7** (Q-01 · Q-06) |
| 4.4 | `MM` = 01-12 |
| 4.5 | `DD` = 01-31 และ `YYMMDD` ต้องเป็น **วันที่มีจริง** รวมปีอธิกสุรทิน (Q-02) |
| 4.6 | `NNNN` = 0001-9999 (0000 ไม่ผ่าน) |

ผลลัพธ์: `abap_true` เมื่อผ่านทุกข้อ ไม่งั้น `abap_false`

## Generate batch number (Phase 2)

| เคส | `batch_out` |
|---|---|
| `batch_in` ไม่ผ่าน format | ไม่แตะ (Q-11) |
| ผ่าน และยังไม่มี batch ของ material ที่ขึ้นต้นด้วย `YYMMDD` ของวันนี้ | `YYMMDD0001` |
| ผ่าน และมีแล้ว | `YYMMDD` + (`NNNN` สูงสุด + 1) (Q-08) |
| `NNNN` สูงสุดเป็น 9999 แล้ว | ไม่แตะ (Q-10) |

- `YYMMDD` = วันที่ปัจจุบัน UTC+7 (Q-07)
- อ่านจาก `I_Batch` `WITH PRIVILEGED ACCESS` (Q-09 · Q-15) · ไม่กรอง plant (Q-13)
- batch ที่สร้างพร้อมกันยังไม่ commit อาจได้เลขซ้ำ ผู้ใช้ยอมรับความเสี่ยง (Q-12)

## Phase

| Phase | เนื้อหา | สถานะ |
|---|---|---|
| 0 | Repo + เอกสาร | ✅ |
| 1 | `ZCL_ZIME001=>is_valid_batch_format( )` + ABAP Unit + release C1 (Use in Key User Apps) | ✅ `aa5f697` (2026-10-05) |
| 2 | `ZCL_ZIME001=>generate_batch_number( )` อ่าน batch ล่าสุดจาก CDS แล้ว +1 | ✅ `38be34d` (2026-10-05) |
| 3 | Custom Logic `YY1_AFTER_BATCH_NUMBER_INT` เรียก 2 method แล้วกำหนด `batch_out` | 🟨 ส่ง code แล้ว 2026-10-05 |
| 4 | ~~ทดสอบ end-to-end + transport~~ | ⏸️ ไม่อยู่ในขอบเขตของเรา (ผู้ใช้สั่ง 2026-10-05) ฟังก์ชันนอลทดสอบเอง แล้วเราแก้ตาม issue ใน `05_issue_log.md` |

## Constant parameter (Module `MM` · Application ID `IME001`)

ค่าบน tenant พัฒนา 2026-10-29 (9 แถว) · ระบบปลายทางต้อง maintain ให้ครบก่อนใช้งาน

| Parameter Name | Additional Parameter | Seq | Sign | Option | Low | ใช้ที่ | สถานะใน code |
|---|---|---|---|---|---|---|---|
| `INBOUND_DOCTYPE` | | 1 | I | EQ | EL | CASE_C และ validate VL31 / VL32 | ✅ (Q-58 `6c9e179`) |
| `MOVEMENT_TYPE` | `GOODS_RECEIPT` | 1 | I | EQ | 101 | CASE_B และ validate MIGO | ✅ |
| `PLANT_EWM` | | 1 | I | EQ | 1000 | validate VL31 (R-16) | ✅ |
| `PO_DOCTYPE_STO` | | 1 | E | EQ | ZP25 | CASE_C และ validate VL31 / VL32 | ✅ |
| `PO_DOCTYPE_STO` | | 2 | E | EQ | NBF2 | CASE_C และ validate VL31 / VL32 | ✅ |
| `PRODUCTION_ORDER_TYPE` | | 1 | I | EQ | ZFG | CASE_A (เทียบ 3 ตัวแรก R-14) | ✅ |
| `REF_DOC_TYPE` | | 1 | I | EQ | B | CASE_B · CASE_C | ✅ |
| `REF_DOC_TYPE` | | 2 | I | EQ | F | CASE_B | ✅ |
| `SLOC_EWM` | | 1 | I | EQ | 1000 | validate VL31 (R-16) | ✅ |

- code อ่านทุกแถวเป็น range · maintain แถวเพิ่มไม่ต้องแก้ code
- ไม่เจอ parameter -> case / การเช็คนั้นไม่ทำงาน (ระบบทำงานแบบ standard)
