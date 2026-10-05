# ZIME001 — Automatic Batch Creation

## Project constraints

1. **Platform**: SAP S/4HANA Cloud **Public Edition** — Developer Extensibility
2. **ABAP Language Version**: **ABAP for Cloud Development** เท่านั้น
3. ใช้ได้เฉพาะ object ที่อยู่ใน **Released APIs (C1 contract)**
4. Sync ผ่าน **abapGit** เท่านั้น
5. ทุก object ลง package **`ZIME001`** ตัวเดียว (ไม่มี sub-package)

## Naming convention

ใช้กฎกลางใน `~/.claude/CLAUDE.md` ทุกข้อ **แต่เปลี่ยน prefix จาก `Y*` เป็น `Z*`** (ผู้ใช้สั่ง 2026-10-02)

| ชนิด | ชื่อจริง | หมายเหตุ |
|------|---------|---------|
| Package | `ZIME001` | |
| Global class | `ZCL_ZIME001` | ผู้ใช้กำหนดชื่อเอง ไม่ใช้ pattern `ZCL_<APP>_<PURPOSE>` |
| Custom Logic | `YY1_AFTER_BATCH_NUMBER_INT` | key user object ชื่อ `YY1_` บังคับโดยระบบ ไม่ขึ้น git |

## Key user <-> developer extensibility

Custom Logic (key user) เรียก class ของ developer extensibility ได้ก็ต่อเมื่อ class นั้น
**release เป็น API state C1 และติ๊ก "Use in Key User Apps"** แล้วเท่านั้น
- ทุกครั้งที่เปลี่ยน signature ของ method ที่ Custom Logic ใช้ ต้องระวัง เพราะ C1 ห้ามเปลี่ยนแบบ incompatible
- SELECT ใน class ที่ Custom Logic เรียก ใช้ `WITH PRIVILEGED ACCESS` **เสมอ** (ผู้ใช้สั่ง 2026-10-05)
  เหตุผล: เป็น logic ของระบบ ถ้าติดสิทธิ์ของ user ที่สร้าง batch จะอ่านข้อมูลไม่ครบ
- code ของ Custom Logic ไม่ขึ้น git — เก็บสำเนาไว้ใน `docs/` เพื่ออ้างอิง

## Coding rules

ใช้กฎกลางทั้งหมด โดยเฉพาะ

- **Comment หนึ่งบรรทัดหนึ่งเรื่อง** ห้ามใช้ `·` คั่น ใช้ `->` ไม่ใช่ `→`
- **ห้ามใช้เลข phase / เลข Q ใน comment ของ ABAP**
- **Comment ห้ามอ้างเลขเอกสาร / เลข batch ของ test data**
- **ห้ามใส่ emoji ใน comment ของ ABAP object**
- **ABAP Doc (`"!`) ทุก class · method · constant group · type** รวม test class
- **ห้ามใส่ `CONV #( )` ที่ไม่จำเป็น**

## จังหวะการทำงาน

- ทำคู่กัน: Claude ทำบน folder ผู้ใช้ทำบน system จริง
- **สรุปชื่อ object ให้รีวิวก่อนทุกเฟส** แล้วหยุดรอ confirm
- **ถามก่อนส่ง code ทุกครั้ง** อย่าส่ง code ที่ผู้ใช้ยังไม่ได้ขอ
- Claude **เตรียม commit message** ให้ผู้ใช้ใช้ตอน push จาก ADT
- หลังผู้ใช้ push ทุกครั้ง Claude `git pull` แล้ว **ตรวจความถูกต้องของ repo**
  (ชื่อไฟล์ · object ครบ · ไม่มี object เกิน · code ตรงกับที่ตกลง) แล้วอัปเดต `docs/02_object_list.md`

## Git — การแบ่งงาน

| สิ่งที่ทำ | ใคร commit/push |
|---|---|
| **ABAP object ทุกชนิด** | **ผู้ใช้** ผ่าน abapGit จาก ADT |
| **เอกสาร** (`docs/`, `README.md`, `CLAUDE.md`) | **Claude** |

- Claude **ห้ามสร้างไฟล์ ABAP ลง repo** — ส่งเป็น code block ใน chat
- `.abapgit.xml` และ `package.devc.xml` เป็นของที่ **SAP serialize เอง** (`/src/` · FULL)
- Remote: https://github.com/Thianthai/fplus-zime001.git
