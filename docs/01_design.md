# 01 — Design

> สถานะ: **draft รอผู้ใช้รีวิว** (2026-10-02)

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
| 4.1 | ยาว 10 ตัวพอดี (ไม่นับช่องว่างท้าย?) — ดู Q-03 |
| 4.2 | เป็นตัวเลข 0-9 ทั้งหมด |
| 4.3 | `YY` = 2 หลักท้ายของปี — ดู Q-01 |
| 4.4 | `MM` = 01-12 |
| 4.5 | `DD` = 01-31 — ดู Q-02 |
| 4.6 | `NNNN` = 0001-9999 (0000 ไม่ผ่าน) |

ผลลัพธ์: `abap_true` เมื่อผ่านทุกข้อ ไม่งั้น `abap_false`

## Phase

| Phase | เนื้อหา | สถานะ |
|---|---|---|
| 0 | Repo + เอกสาร | 🟨 |
| 1 | `ZCL_ZIME001` method ตรวจ format + ABAP Unit + release C1 (Use in Key User Apps) | ⬜ รอรีวิวชื่อ |
| 2 | Custom Logic `YY1_AFTER_BATCH_NUMBER_INT` เรียก class แล้วกำหนด `batch_out` | ⬜ รอ requirement (Q-04) |
| 3 | ทดสอบ end-to-end + transport | ⬜ |
