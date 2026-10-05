# 04 — Custom Logic `YY1_AFTER_BATCH_NUMBER_INT`

Key user object ไม่ขึ้น git — เก็บสำเนา code ไว้ที่นี่ ถ้าแก้บน tenant ต้องอัปเดตไฟล์นี้ด้วย

| Item | Value |
|---|---|
| App | Custom Logic |
| BAdI | `LOBM_AFTER_BATCH_NUMBER_INT` — After internal batch number assignment |
| Implementation | `YY1_AFTER_BATCH_NUMBER_INT` |
| Filter | ไม่จำกัด (Q-16 · 2026-10-05) |
| เรียก | `ZCL_ZIME001` (C1 · Use in Key User Apps) |

## Code (ส่ง 2026-10-05 · Phase 3)

```abap
" ZIME001 Automatic Batch Creation
" logic ทั้งหมดอยู่ใน class ZCL_ZIME001
" batch_in ไม่ตรง format YYMMDDNNNN -> ไม่แตะ batch_out ระบบใช้เลขตามปกติ
IF zcl_zime001=>is_valid_batch_format( batch_in ) = abap_true.

  " สร้างเลข batch ถัดไปของ material จากวันที่ปัจจุบันตามเวลา UTC+7
  DATA(lv_batch) = zcl_zime001=>generate_batch_number( batch_allocation-material ).

  " running number เต็มแล้วจะได้ค่าว่าง -> ไม่แตะ batch_out
  IF lv_batch IS NOT INITIAL.
    batch_out = lv_batch.
  ENDIF.

ENDIF.
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
