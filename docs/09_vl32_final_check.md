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
