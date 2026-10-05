# 05 — Issue และ Requirement เพิ่มเติม

งานของเราจบที่ Phase 3 (2026-10-05)
ฟังก์ชันนอลทดสอบ end-to-end เอง แล้วส่ง issue กลับมา
ผู้ใช้อาจเพิ่ม requirement ก่อนนั้น

แต่ละรายการยังใช้จังหวะเดิม: สรุปชื่อ object ให้รีวิว -> ถามก่อนส่ง code -> ผู้ใช้ push -> Claude ตรวจ repo

## Issue จากการทดสอบ

| # | วันที่ | อาการ | สาเหตุ | แก้ที่ | สถานะ |
|---|---|---|---|---|---|

## Requirement เพิ่มเติม

| # | วันที่ | Requirement | กระทบ object | สถานะ |
|---|---|---|---|---|
| R-01 | 2026-10-05 | logic ต่างกันตามที่มาของ transaction: (1) Create/Change Production Order CO01/CO02 (2) Mass Processing of Production Orders (3) Goods Receipt MIGO (4) Create/Change Inbound Delivery VL31/VL32 | `ZCL_ZIME001` · Custom Logic | 🔍 วิเคราะห์ — แยกจาก field ใน `BATCH_ALLOCATION` (ไม่มี tcode / app id ให้ใช้) · เก็บค่าจริงด้วยแอป Custom Logic Tracing ก่อน (Q-17) · ข้อ 1 กับ 2 ใช้ logic เดียวกัน -> 3 กลุ่ม: Production Order · Goods Receipt · Inbound Delivery |
| R-02 | 2026-10-05 | **ชั่วคราว** เก็บ import/changing ของ BAdI ทุก call ลง custom table เพื่อ investigate R-01 · ทุก field เป็น predefined type ยาวตามรูป parameter | table `ZIME001_LOG` · class `ZCL_ZIME001_LOG` · Custom Logic | 🟨 ส่ง code 2026-10-05 · **ลบก่อน transport** |
