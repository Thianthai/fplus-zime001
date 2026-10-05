"! ZIME001 Automatic Batch Creation
"! logic ที่ Custom Logic YY1_AFTER_BATCH_NUMBER_INT เรียกใช้
"! Custom Logic เป็นของ BAdI LOBM_AFTER_BATCH_NUMBER_INT
"! class นี้ต้อง release C1 และเปิด Use in Key User Apps ไม่งั้น Custom Logic มองไม่เห็น
CLASS zcl_zime001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    "! ตรวจ format ของเลข batch YYMMDDNNNN เทียบกับวันที่ปัจจุบันตามเวลา UTC+7
    "! @parameter iv_batch | เลข batch ที่ต้องการตรวจ
    "! @parameter rv_valid | abap_true เมื่อผ่านทุกข้อ ไม่งั้น abap_false
    CLASS-METHODS is_valid_batch_format
      IMPORTING iv_batch        TYPE charg_d
      RETURNING VALUE(rv_valid) TYPE abap_boolean.

    "! สร้างเลข batch YYMMDDNNNN ถัดไปของ material ตามวันที่ปัจจุบัน UTC+7
    "! NNNN คือ running number สูงสุดของ material ที่ขึ้นต้นด้วย YYMMDD เดียวกันบวก 1
    "! ยังไม่เคยมี batch ของวันนี้จะได้ 0001
    "! running number ถึง 9999 แล้วจะคืนค่าว่าง ให้ผู้เรียกไม่แตะเลข batch
    "! @parameter iv_material | material ที่กำลังสร้าง batch
    "! @parameter rv_batch    | เลข batch ถัดไป หรือค่าว่างเมื่อ running number เต็ม
    CLASS-METHODS generate_batch_number
      IMPORTING iv_material     TYPE matnr
      RETURNING VALUE(rv_batch) TYPE charg_d.

  PRIVATE SECTION.

    TYPES:
      "! รายการเลข batch
      tt_batch TYPE STANDARD TABLE OF charg_d WITH EMPTY KEY.

    CONSTANTS:
      "! ความยาวของเลข batch ตาม format YYMMDDNNNN
      gc_batch_length   TYPE i VALUE 10,
      "! ตัวอักษรที่ยอมให้อยู่ในเลข batch
      gc_digits         TYPE string VALUE `0123456789`,
      "! running number ที่ไม่ยอมให้ใช้
      gc_running_zero   TYPE n LENGTH 4 VALUE '0000',
      "! running number สูงสุดที่ยอมให้ใช้
      gc_running_max    TYPE i VALUE 9999,
      "! เวลา UTC ที่เวลาไทย (UTC+7) ขึ้นวันใหม่
      gc_utc7_day_start TYPE t VALUE '170000'.

    "! วันที่ปัจจุบันตามเวลา UTC+7
    "! @parameter rv_date | วันที่ปัจจุบัน
    CLASS-METHODS get_current_date
      RETURNING VALUE(rv_date) TYPE d.

    "! ตรวจ format ของเลข batch YYMMDDNNNN เทียบกับวันที่ที่ส่งเข้ามา
    "! แยกวันที่เป็น parameter ไว้ให้ test กำหนดวันที่เองได้
    "! @parameter iv_batch        | เลข batch ที่ต้องการตรวจ
    "! @parameter iv_current_date | วันที่ปัจจุบันที่ใช้เทียบปี
    "! @parameter rv_valid        | abap_true เมื่อผ่านทุกข้อ ไม่งั้น abap_false
    CLASS-METHODS check_batch_format
      IMPORTING iv_batch        TYPE charg_d
                iv_current_date TYPE d
      RETURNING VALUE(rv_valid) TYPE abap_boolean.

    "! หาเลข batch ถัดไปจากรายการ batch ที่มีอยู่แล้ว โดยไม่อ่าน DB
    "! แยกออกมาไว้ให้ test ส่งรายการ batch เองได้
    "! @parameter iv_current_date | วันที่ปัจจุบันที่ใช้เป็น YYMMDD
    "! @parameter it_batches      | batch ที่มีอยู่แล้วของ material
    "! @parameter rv_batch        | เลข batch ถัดไป หรือค่าว่างเมื่อ running number เต็ม
    CLASS-METHODS next_batch_number
      IMPORTING iv_current_date TYPE d
                it_batches      TYPE tt_batch
      RETURNING VALUE(rv_batch) TYPE charg_d.

ENDCLASS.


CLASS zcl_zime001 IMPLEMENTATION.

  METHOD is_valid_batch_format.
    rv_valid = check_batch_format( iv_batch        = iv_batch
                                   iv_current_date = get_current_date( ) ).
  ENDMETHOD.


  METHOD generate_batch_number.
    DATA lt_batches TYPE tt_batch.

    DATA(lv_current_date) = get_current_date( ).
    DATA(lv_pattern) = |{ lv_current_date+2(6) }%|.

    " อ่าน batch ของ material ที่ขึ้นต้นด้วย YYMMDD ของวันนี้
    " ใช้ privileged access เพราะเป็น logic ของระบบ ไม่ขึ้นกับสิทธิ์ของ user ที่สร้าง batch
    " batch level เป็นระดับ material จึงไม่กรอง plant
    SELECT Batch
      FROM I_Batch WITH PRIVILEGED ACCESS
      WHERE Material = @iv_material
        AND Batch    LIKE @lv_pattern
      INTO TABLE @lt_batches.

    rv_batch = next_batch_number( iv_current_date = lv_current_date
                                  it_batches      = lt_batches ).
  ENDMETHOD.


  METHOD get_current_date.
    " วันที่และเวลาของระบบเป็น UTC
    rv_date = cl_abap_context_info=>get_system_date( ).

    " ตั้งแต่ 17:00 UTC เป็นต้นไป เวลาไทยขึ้นวันใหม่แล้ว
    IF cl_abap_context_info=>get_system_time( ) >= gc_utc7_day_start.
      rv_date = rv_date + 1.
    ENDIF.
  ENDMETHOD.


  METHOD check_batch_format.
    rv_valid = abap_false.

    " ต้องยาว 10 ตัวพอดี
    " strlen ไม่นับช่องว่างท้าย ค่าที่สั้นกว่า 10 ตัวจึงไม่ผ่านที่นี่
    IF strlen( iv_batch ) <> gc_batch_length.
      RETURN.
    ENDIF.

    " ต้องเป็นตัวเลข 0-9 ทั้งหมด
    " ช่องว่างนำหน้าหรือตรงกลางก็ไม่ผ่านที่นี่
    IF iv_batch CN gc_digits.
      RETURN.
    ENDIF.

    " YY ต้องเท่ากับ 2 หลักท้ายของปีปัจจุบัน
    IF iv_batch(2) <> iv_current_date+2(2).
      RETURN.
    ENDIF.

    " YYMMDD ต้องเป็นวันที่มีจริง
    " ครอบคลุม MM 01-12 และ DD ตามจำนวนวันของเดือนนั้น รวมปีอธิกสุรทิน
    " วันที่ที่ไม่ถูกต้องเมื่อแปลงเป็นจำนวนวันจะได้ 0
    DATA(lv_date) = CONV d( |{ iv_current_date(2) }{ iv_batch(6) }| ).
    IF CONV i( lv_date ) = 0.
      RETURN.
    ENDIF.

    " NNNN ต้องอยู่ในช่วง 0001-9999
    IF iv_batch+6(4) = gc_running_zero.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.


  METHOD next_batch_number.
    DATA lv_running      TYPE i.
    DATA lv_max_running  TYPE i.
    DATA lv_next_running TYPE n LENGTH 4.

    LOOP AT it_batches INTO DATA(lv_batch).
      " นับเฉพาะ batch ของวันนี้ที่ตรง format
      " batch เก่าที่มีตัวอักษรหรือยาวไม่ครบจะถูกข้าม
      IF lv_batch(6) <> iv_current_date+2(6)
          OR check_batch_format( iv_batch        = lv_batch
                                 iv_current_date = iv_current_date ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_running = lv_batch+6(4).
      IF lv_running > lv_max_running.
        lv_max_running = lv_running.
      ENDIF.
    ENDLOOP.

    " running number เต็มแล้ว
    " คืนค่าว่างให้ผู้เรียกไม่แตะเลข batch
    IF lv_max_running >= gc_running_max.
      RETURN.
    ENDIF.

    " ยังไม่มี batch ของวันนี้ lv_max_running เป็น 0 จึงได้ 0001
    lv_next_running = lv_max_running + 1.
    rv_batch = |{ iv_current_date+2(6) }{ lv_next_running }|.
  ENDMETHOD.

ENDCLASS.
