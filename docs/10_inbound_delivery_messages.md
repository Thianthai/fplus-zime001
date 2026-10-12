# 10 — Error message ของ VL31 / VL32 (สำหรับฟังก์ชันนอล update spec)

อัปเดต 2026-10-12 · code `ZCL_ZIME001=>check_inbound_delivery` (`2b976b1`) · Custom Logic `YY1_SHP_DELIVERY_FINAL_CHECK` (BAdI `LE_SHP_DELIVERY_FINAL_CHECK`)

## เมื่อไรระบบตรวจ

ตรวจตอนกด Save เฉพาะเมื่อครบทุกข้อ
- เป็น inbound delivery
- โหมดสร้าง (VL31) หรือแก้ (VL32) · โหมดแสดง (VL33) ไม่ตรวจ
- มีอย่างน้อย 1 item ที่ต้อง replace เลข batch: อ้างอิง purchase order · material เป็น batch managed · PO type ไม่อยู่ใน constant parameter `PO_DOCTYPE_STO` (ตอนนี้ exclude ZP25)

แสดงทีละ 1 error (ข้อแรกที่เจอตามลำดับในตาราง) · message type E

## การ replace เลข batch

| App | เลข batch |
|---|---|
| VL31 | ใช้เลข standard จาก number range ยังไม่ replace |
| VL32 | กดปุ่ม **Batch Creation** -> ได้เลข YYMMDDNNNN · YYMMDD = Actual GM Date ที่ save ไว้ · NNNN = running number ต่อ material · material เดียวกันใน delivery เดียวกันได้เลขเดียวกัน |

## Error message

| # | App | ตรวจอะไร | ติด error เมื่อ | Message | วิธีแก้ของ user |
|---|---|---|---|---|---|
| 1 | VL31 · VL32 | Actual GM Date ต้องกรอก | ไม่ได้กรอก Actual GM Date | `Actual goods movement date is required.` | กรอก Actual GM Date |
| 2 | VL31 · VL32 | Delivery Date ต้องเท่ากับ Actual GM Date | Delivery Date กับ Actual GM Date ไม่ใช่วันเดียวกัน | `Delivery date must be the same as the actual goods movement date.` | แก้ให้เป็นวันเดียวกัน |
| 3 | VL32 | item ต้องมี batch | item ที่ต้อง replace ยังไม่มี batch | `Batch is missing. Choose Batch Creation before saving.` | กด Batch Creation แล้ว save |
| 4 | VL32 | batch ต้องเป็น format YYMMDDNNNN | batch ไม่ใช่ตัวเลข 10 หลัก หรือ YYMMDD ไม่ใช่วันที่มีจริง หรือ NNNN เป็น 0000 · เช่นยังเป็นเลข standard จาก VL31 (ยังไม่กด Batch Creation) หรือ user แก้ batch เองผิด | `Batch must be in the format YYMMDDNNNN.` | กด Batch Creation หรือแก้ batch ให้ถูก format |
| 5 | VL32 | YYMMDD ของ batch ต้องเท่ากับ Actual GM Date | 6 ตัวแรกของ batch ไม่ตรงกับ Actual GM Date | `Batch date must be the same as the actual goods movement date.` | แก้ Actual GM Date หรือ batch ให้ตรงกัน |

## ข้อควรรู้

- Batch Creation อ่าน Actual GM Date ที่ **save ไว้แล้ว** ถ้าแก้ Actual GM Date ใน VL32 แล้วกด Batch Creation ก่อน save batch จะได้วันที่เดิม และติด error 5 ตอน save -> ต้องแก้ 6 ตัวแรกของ batch ให้ตรงวันที่ใหม่เอง
- ทุก save ใน VL32 ต้องผ่านครบ 5 ข้อ รวมถึง save ที่ไม่ได้แก้ batch
- ยังไม่ได้ทดสอบว่า error หยุด save ได้จริง (รอผลทดสอบ)
