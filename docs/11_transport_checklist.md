# 11 — Transport Checklist

อัปเดต 2026-10-29 · ใช้ทุกครั้งที่ transport ZIME001 ขึ้นระบบปลายทาง (test / production)

Tenant ต้นทาง: **IA5/080** (developer extensibility: ADT) · **IA5/100** (key user extensibility: Custom Logic)

---

## A. ก่อน release transport (ระบบต้นทาง)

| # | เช็ค | ที่ไหน | สถานะ |
|---|---|---|---|
| A1 | ATC ของ package `ZIME001` ผ่าน ไม่มี priority 1 และ 2 | ADT · 080 | ✅ 2026-10-29 |
| A2 | ABAP Unit ของ `ZCL_ZIME001` ผ่านครบ 46 ตัว | ADT · 080 | ✅ 2026-10-29 |
| A3 | repo ตรงกับ tenant (push ล่าสุดตรวจแล้ว `c085503`) | git | ✅ |
| A4 | `ZCL_ZIME001` API state = C1 · Released · Use in Key User Apps | ADT · 080 | ✅ |
| A5 | `ZCL_ZIME001_LOG` API state = C1 · Released · Use in Key User Apps (**ห้ามลบ** ดู `CLAUDE.md`) | ADT · 080 | ✅ |
| A6 | Custom Logic ทั้ง 4 ตัว Published (ตาราง C) | Custom Logic · 100 | ✅ 2026-10-29 |
| A7 | `YY1_AFTER_BATCH_NUMBER_INT` เป็น version ที่ไม่มี log (ตรงกับ `docs/04_custom_logic.md`) | Custom Logic · 100 | ✅ 2026-10-29 |
| A8 | ไม่มี Custom Logic อื่นของ BAdI เดียวกันที่จะทำงานซ้อน (เอา filter Created By ออกแล้วค้นด้วย BAdI ทั้ง 4 ตัว) | Custom Logic · 100 | ⬜ |
| A9 | `ZBCPARAM` และ `ZBCUTILITY` พร้อม transport หรือมีอยู่ที่ระบบปลายทางแล้ว | ADT · 080 | ⬜ |
| A10 | ผลทดสอบของฟังก์ชันนอลผ่าน: R-14 · R-15 · R-16 · Q-58 | tenant | ⬜ |

---

## B. Developer transport (ADT · tenant 080)

| Object | ชนิด | หมายเหตุ |
|---|---|---|
| `DEVC ZIME001` | Package | ถ้ายังไม่เคย transport |
| `CLAS ZCL_ZIME001` | Class | logic หลักทั้งหมด |
| `APIS ZCL_ZIME001` | API state | C1 · Use in Key User Apps · **ต้องไปด้วย** ไม่งั้น Custom Logic ที่ปลายทางเรียก class ไม่ได้ |
| `CLAS ZCL_ZIME001_LOG` | Class | class ว่างเพื่อความ compatible ของ API |
| `APIS ZCL_ZIME001_LOG` | API state | C1 · Use in Key User Apps |

- ไม่มี table · `ZIME001_LOG` ถูกลบไปแล้วและไม่เคยถูก transport
- ถ้า transport มี entry ของ `TABL ZIME001_LOG` ที่ถูกลบค้างอยู่ ให้เช็คว่า release ได้โดยไม่มี error

---

## C. Key user transport (Export Software Collection · tenant 100)

| # | Custom Logic | BAdI | เรียก |
|---|---|---|---|
| 1 | `YY1_AFTER_BATCH_NUMBER_INT` | `LOBM_AFTER_BATCH_NUMBER_INT` | `determine_case` · `get_batch_number` |
| 2 | `YY1_CHECK_MATDOC_ITEM` | `BADI_MMIM_CHECK_MATDOC_ITEM` | `check_goods_receipt_item` |
| 3 | `YY1_CREATE_GM_POSTING_DATE` | `MMIM_CREATE_GM_POSTING_DATE` | `set_posting_date` |
| 4 | `YY1_SHP_DELIVERY_FINAL_CHECK` | `LE_SHP_DELIVERY_FINAL_CHECK` | `check_inbound_delivery` |

---

## D. ลำดับการ import ที่ระบบปลายทาง (สำคัญ)

1. `ZBCPARAM` (`ZCL_PARAM` · `ZCX_PARAM` · table `ZTBC_PARAM` · app Constant Parameter)
2. `ZBCUTILITY` (`ZCL_UTILITY`)
3. ZIME001 developer transport (ตาราง B)
4. Software Collection ของ Custom Logic (ตาราง C)

Custom Logic เรียก `ZCL_ZIME001` และ `ZCL_ZIME001` เรียก `ZCL_PARAM` / `ZCL_UTILITY`
-> ถ้า import ข้ามลำดับ Custom Logic จะ activate ไม่ได้ หรือ class จะ activate ไม่ได้

---

## E. หลัง import (ระบบปลายทาง)

### E1. Constant parameter (Module `MM` · Application ID `IME001`)

| Parameter Name | Additional Parameter | Seq | Sign | Option | Low |
|---|---|---|---|---|---|
| `INBOUND_DOCTYPE` | | 1 | I | EQ | EL |
| `MOVEMENT_TYPE` | `GOODS_RECEIPT` | 1 | I | EQ | 101 |
| `PLANT_EWM` | | 1 | I | EQ | 1000 |
| `PO_DOCTYPE_STO` | | 1 | E | EQ | ZP25 |
| `PO_DOCTYPE_STO` | | 2 | E | EQ | NBF2 |
| `PRODUCTION_ORDER_TYPE` | | 1 | I | EQ | ZFG |
| `REF_DOC_TYPE` | | 1 | I | EQ | B |
| `REF_DOC_TYPE` | | 2 | I | EQ | F |
| `SLOC_EWM` | | 1 | I | EQ | 1000 |

- ไม่มี parameter -> case / การเช็คนั้นไม่ทำงาน (ระบบทำงานแบบ standard โดยไม่มี error เตือน)
- พิมพ์ค่าด้วยมือ ห้าม copy มาจากที่อื่น (เคยเจอ U+200B ติดมากับค่า `ZFG` · I-01)
- ค่าอาจต่างกันในแต่ละระบบ (เช่น plant / storage location ของ EWM) ให้ฟังก์ชันนอลยืนยัน

### E2. Config ที่ต้องมี (ฟังก์ชันนอล)

- order type `ZFG` ตั้ง automatic batch creation ตอน release
- material ที่ต้องได้เลข YYMMDDNNNN เปิด batch management

### E3. Smoke test

| # | App | ทำอะไร | ผลที่ต้องได้ |
|---|---|---|---|
| 1 | CO02 | release production order `ZFG` | batch = YYMMDD ของ Basic Start + NNNN |
| 2 | MIGO | GR อ้างอิง PO (101 · B) แล้วกด Check และ Post | batch = YYMMDD ของ posting date + NNNN · post ได้ |
| 3 | MIGO | แก้ posting date หลังได้เลข batch แล้ว | error `Batch date must be the same as the posting date.` |
| 4 | VL31 | inbound delivery type `EL` ใส่ Plant / Storage Location ของ EWM | error EWM · save ไม่ได้ |
| 5 | VL31 | ไม่กรอก Actual GM Date | error `Actual goods movement date is required.` |
| 6 | VL32 | กด Batch Creation แล้ว save | batch = YYMMDD ของ Actual GM Date + NNNN · save ได้ |
| 7 | VL32 | delivery type อื่นที่ไม่อยู่ใน `INBOUND_DOCTYPE` | ไม่มี error จาก ZIME001 · ได้เลข standard |

error message ทั้งหมดดู `docs/10_inbound_delivery_messages.md`

---

## F. หลังส่งมอบงาน

- ⚠️ `ZCL_ZIME001_LOG` ยังไม่ได้ตั้ง Deprecated (ผู้ใช้ตัดสินใจ 2026-10-29 เผื่อใช้เก็บ log อีก)
  -> ถ้ายังไม่ได้ใช้ ให้ตั้ง API state เป็น Deprecated ที่ 080 แล้ว transport `APIS ZCL_ZIME001_LOG` ตามขึ้นไป
- ห้ามลบ `ZCL_ZIME001_LOG` และห้ามเปลี่ยน public interface ของ `ZCL_ZIME001` แบบ incompatible ในทุกระบบ
