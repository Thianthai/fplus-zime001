# 04 — Custom Logic `YY1_AFTER_BATCH_NUMBER_INT`

Key user object ไม่ขึ้น git — เก็บสำเนา code ไว้ที่นี่ ถ้าแก้บน tenant ต้องอัปเดตไฟล์นี้ด้วย

| Item | Value |
|---|---|
| App | Custom Logic |
| BAdI | `LOBM_AFTER_BATCH_NUMBER_INT` — After internal batch number assignment |
| Implementation | `YY1_AFTER_BATCH_NUMBER_INT` |
| Filter | ไม่จำกัด (Q-16 · 2026-10-05) |
| เรียก | `ZCL_ZIME001` (C1 · Use in Key User Apps) |

## Code ปัจจุบัน (ส่ง 2026-10-09 · R-07 เรียก ZCL_ZIME001 จริง + log)

เรียก `determine_case` แล้ว `get_batch_number` · ทำงานเฉพาะ user ทดสอบ (เช็คใน class) · log ยังอยู่ท้ายสุด
ก่อน transport: ลบส่วน log (`lv_batch_out_before` และ `zcl_zime001_log=>write`)

```abap
" ZIME001 Automatic Batch Creation
" logic ทั้งหมดอยู่ใน class ZCL_ZIME001
" สรุปแต่ละ case อยู่ที่ constant ZCL_ZIME001=>GC_CASE

" เก็บค่า batch_out ก่อนแก้ไว้ให้ log ชั่วคราว
DATA(lv_batch_out_before) = batch_out.

" แยก case จากค่าที่ BAdI ส่งมา
" ไม่เข้า case ไหน -> ไม่แตะ batch_out ระบบใช้เลขตามปกติ
DATA(ls_batch_allocation) = CORRESPONDING zcl_zime001=>ty_batch_allocation( batch_allocation ).
DATA(lv_case) = zcl_zime001=>determine_case( ls_batch_allocation ).

IF lv_case IS NOT INITIAL.

  " ได้ค่าว่าง -> ไม่เข้าเงื่อนไขของ case นั้น ไม่แตะ batch_out
  DATA(lv_batch) = zcl_zime001=>get_batch_number( iv_case             = lv_case
                                                 is_batch_allocation = ls_batch_allocation
                                                 iv_batch_in         = batch_in ).

  IF lv_batch IS NOT INITIAL.
    batch_out = lv_batch.
  ENDIF.

ENDIF.

" log ชั่วคราวสำหรับดูค่าที่แต่ละ app ส่งเข้ามา
" ลบส่วนนี้พร้อม class ZCL_ZIME001_LOG และ table ZIME001_LOG ก่อน transport
zcl_zime001_log=>write( is_batch_allocation = CORRESPONDING #( batch_allocation )
                        iv_batch_in         = batch_in
                        iv_batch_out        = lv_batch_out_before
                        iv_batch_out_after  = batch_out ).
```

## Code ช่วงเก็บข้อมูล (ใช้ 2026-10-05 ถึง R-07 · เก็บ log อย่างเดียว)


เก็บ log อย่างเดียว **ไม่ validate และไม่แก้ `batch_out`** จนกว่าจะออกแบบ R-01 เสร็จ

```abap
" ZIME001 Automatic Batch Creation
" ช่วงเก็บข้อมูล: บันทึกค่าที่ BAdI ได้รับลง table ZIME001_LOG อย่างเดียว
" ไม่ validate และไม่แก้ batch_out
" ลบส่วนนี้พร้อม class ZCL_ZIME001_LOG และ table ZIME001_LOG ก่อน transport
zcl_zime001_log=>write( is_batch_allocation = CORRESPONDING #( batch_allocation )
                        iv_batch_in         = batch_in
                        iv_batch_out        = batch_out
                        iv_batch_out_after  = batch_out ).
```

## Code ของ Phase 3 + log (ยังไม่ใช้ — เก็บไว้อ้างอิงหลังออกแบบ R-01)

ฉบับนี้ทั้ง validate และแก้ `batch_out` · ถูกแทนด้วยฉบับเก็บ log อย่างเดียวด้านบน (ผู้ใช้สั่ง 2026-10-05)

```abap
" ZIME001 Automatic Batch Creation
" logic ทั้งหมดอยู่ใน class ZCL_ZIME001

" เก็บค่า batch_out ก่อนแก้ไว้ให้ log ชั่วคราว
DATA(lv_batch_out_before) = batch_out.

" batch_in ไม่ตรง format YYMMDDNNNN -> ไม่แตะ batch_out ระบบใช้เลขตามปกติ
IF zcl_zime001=>is_valid_batch_format( batch_in ) = abap_true.

  " สร้างเลข batch ถัดไปของ material จากวันที่ปัจจุบันตามเวลา UTC+7
  DATA(lv_batch) = zcl_zime001=>generate_batch_number( batch_allocation-material ).

  " running number เต็มแล้วจะได้ค่าว่าง -> ไม่แตะ batch_out
  IF lv_batch IS NOT INITIAL.
    batch_out = lv_batch.
  ENDIF.

ENDIF.

" log ชั่วคราวสำหรับดูค่าที่แต่ละ app ส่งเข้ามา
" ลบส่วนนี้พร้อม class ZCL_ZIME001_LOG และ table ZIME001_LOG ก่อน transport
zcl_zime001_log=>write( is_batch_allocation = CORRESPONDING #( batch_allocation )
                        iv_batch_in         = batch_in
                        iv_batch_out_before = lv_batch_out_before
                        iv_batch_out_after  = batch_out ).
```

## ทดสอบในแท็บ Test

`<วันนี้>` = YYMMDD ของวันที่ปัจจุบันตามเวลาไทย

| # | Input | คาดหวัง `BATCH_OUT` |
|---|---|---|
| T1 | `MATERIAL` ที่ยังไม่มี batch ของวันนี้ · `BATCH_IN` = `<วันนี้>0001` | `<วันนี้>0001` |
| T2 | `MATERIAL` ที่มี batch ของวันนี้อยู่แล้ว · `BATCH_IN` = `<วันนี้>0001` | `<วันนี้>` + (NNNN สูงสุด + 1) |
| T3 | `BATCH_IN` ปีไม่ใช่ปีปัจจุบัน หรือมีตัวอักษร | ไม่เปลี่ยน |
| T4 | `BATCH_IN` วันที่ไม่มีจริง เช่น 31 เมษายน | ไม่เปลี่ยน |

## ผลทดสอบ

| # | ผล | วันที่ |
|---|---|---|
| T1 | ⬜ | |
| T2 | ⬜ | |
| T3 | ⬜ | |
| T4 | ⬜ | |
