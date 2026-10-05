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
| 4.3 | `YY` = 2 หลักท้ายของ **ปีปัจจุบัน** (Q-01) · ใช้วันที่ timezone ไหน ดู Q-06 |
| 4.4 | `MM` = 01-12 |
| 4.5 | `DD` = 01-31 และ `YYMMDD` ต้องเป็น **วันที่มีจริง** รวมปีอธิกสุรทิน (Q-02) |
| 4.6 | `NNNN` = 0001-9999 (0000 ไม่ผ่าน) |

ผลลัพธ์: `abap_true` เมื่อผ่านทุกข้อ ไม่งั้น `abap_false`

## Generate batch number (Phase 2)

ตามคำตอบ Q-04: ถ้า `batch_in` ผ่าน format แล้ว `batch_out` = batch ล่าสุดของ material นั้น **+1**
อ่านจาก CDS ที่มีทั้ง material และ batch · ถ้าไม่เคยมีมาก่อน `NNNN = 0001`
ยังรอคำตอบ Q-07 ถึง Q-12

## Phase

| Phase | เนื้อหา | สถานะ |
|---|---|---|
| 0 | Repo + เอกสาร | 🟨 |
| 1 | `ZCL_ZIME001=>is_valid_batch_format( )` + ABAP Unit + release C1 (Use in Key User Apps) | ⬜ รอ confirm ชื่อ + Q-06 |
| 2 | `ZCL_ZIME001=>generate_batch_number( )` อ่าน batch ล่าสุดจาก CDS แล้ว +1 | ⬜ รอ Q-07 ถึง Q-12 |
| 3 | Custom Logic `YY1_AFTER_BATCH_NUMBER_INT` เรียก 2 method แล้วกำหนด `batch_out` | ⬜ |
| 4 | ทดสอบ end-to-end + transport | ⬜ |
