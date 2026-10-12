# 09 — R-06 Validate VL32 ด้วย BAdI `LE_SHP_DELIVERY_FINAL_CHECK`

ข้อมูล: signature ที่ผู้ใช้ส่งมา 2026-10-09 · Custom Logic `YY1_SHP_DELIVERY_FINAL_CHECK` สร้างแล้ว (ยังไม่มี logic)

## Signature

```abap
METHODS delivery_final_check
  IMPORTING
    documentprocessingmode     TYPE del_doc_processing_mode   " CHAR 7 domain LEPROCESSINGMODE
    delivery_document_in       TYPE tds_bd_delivery_head      " include delivery_head (LIKP)
    delivery_document_items_in TYPE tdt_bd_delivery_item      " standard table of tds_bd_delivery_item (LIPS)
  CHANGING
    message                    TYPE tds_bd_le_shp_message OPTIONAL  " messagetype + messagetext
  RAISING
    cx_ble_runtime_error.
```

## Field ที่ใช้ได้

| ที่ต้องการ | Field | หมายเหตุ |
|---|---|---|
| Delivery Date | header `deliverydate` | `LFDAT_V` |
| GR Actual Date | header `actualgoodsmovementdate` | `WADAT_IST` · น่าจะมีค่าเฉพาะตอน Post GR |
| ประเภทเอกสาร | header `sddocumentcategory` / `deliverydocumenttype` | inbound delivery = 7 |
| สถานะ GR | header `overallgoodsmovementstatus` · item `goodsmovementstatus` | |
| Batch | item `batch` | YYMMDD = 6 ตัวแรก |
| Material / batch managed | item `material` · `materialisbatchmanaged` | |
| PO | item `referencesddocument` / `referencesddocumentitem` · `referencesddocumentcategory` | PO type ต้องอ่าน `I_PurchaseOrderAPI01` เอง (ZP25 ไม่เช็ค) |
| Movement type | item `goodsmovementtype` | |

## ข้อสังเกต

- `message` เป็น **structure เดียว** ไม่ใช่ table -> ส่ง error ได้ทีละ 1 ข้อความ
- ยังไม่รู้ว่า BAdI ถูกเรียกตอน Post GR ใน VL32 หรือไม่ และ `actualgoodsmovementdate` มีค่าตอนนั้นหรือยัง
- `documentprocessingmode` (domain `LEPROCESSINGMODE`) มี 3 ค่า: `CREATE` · `CHANGE` · `DISPLAY` (ผู้ใช้ส่งมา 2026-10-09) -> VL31 น่าจะเป็น CREATE · VL32 น่าจะเป็น CHANGE · ไม่มีค่าแยก Post GR ต้องดูจาก `actualgoodsmovementdate` / สถานะ GR
- ยังไม่รู้ว่า `messagetype = 'E'` หยุด save ได้จริงหรือไม่ (มีรายงานว่า BAdI แบบ classic ไม่หยุด)
- ต้องเก็บค่าจริงก่อน (Q-47)

## คำถาม (Q-47 ถึง Q-50 ใน `03_open_questions.md`)

## Process ใหม่ของ VL31 / VL32 (ผู้ใช้แจ้ง 2026-10-12) — แทน R-06 เดิม

| App | เลข batch | validate ใน `YY1_SHP_DELIVERY_FINAL_CHECK` |
|---|---|---|
| VL31 | **ยังไม่ replace** ใช้เลข standard | `actualgoodsmovementdate` ต้องไม่ว่าง (บังคับกรอก) · `deliverydate` = `actualgoodsmovementdate` |
| VL32 | **replace เลข batch ที่นี่** | batch ต้องเป็น format YYMMDD · YYMMDD = `actualgoodsmovementdate` · `deliverydate` = `actualgoodsmovementdate` |

- validate เฉพาะเมื่อเข้าเงื่อนไขที่ต้อง replace batch เท่านั้น
- VL32 user อาจแก้ batch หรือ field อื่นบนหน้าจอได้ระหว่างทำงาน

## ผลกระทบกับ design เดิม

- CASE_C (VL31 ใน `LOBM_AFTER_BATCH_NUMBER_INT`) ต้องไม่ replace แล้ว
- เดิมทดสอบพบว่า VL32 ไม่เรียก `LOBM_AFTER_BATCH_NUMBER_INT` (เพราะ batch ถูกสร้างตั้งแต่ VL31) -> ต้องรู้ว่าใน process ใหม่ VL32 เรียก BAdI นี้หรือไม่ และตอนไหน (Q-53)
- YYMMDD ของ VL32 น่าจะมาจาก `actualgoodsmovementdate` ที่ถูกบันทึกไว้ตั้งแต่ VL31 (อ่านจาก DB ได้เพราะ delivery มีเลขจริงแล้ว)

## Custom Logic `YY1_SHP_DELIVERY_FINAL_CHECK` (ส่ง 2026-10-12 · R-10)

```abap
" ZIME001 Automatic Batch Creation
" ตรวจ inbound delivery ก่อน save
" logic ทั้งหมดอยู่ใน class ZCL_ZIME001
" ไม่ผ่าน -> แสดง error และไม่ให้ save
DATA(lv_message) = zcl_zime001=>check_inbound_delivery(
                     iv_processing_mode = documentprocessingmode
                     is_delivery_head   = CORRESPONDING #( delivery_document_in )
                     it_delivery_items  = CORRESPONDING #( delivery_document_items_in ) ).

IF lv_message IS NOT INITIAL.
  message-messagetype = 'E'.
  message-messagetext = lv_message.
ENDIF.
```

