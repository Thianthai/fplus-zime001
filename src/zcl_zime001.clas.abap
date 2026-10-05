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

  PRIVATE SECTION.

    CONSTANTS:
      "! ความยาวของเลข batch ตาม format YYMMDDNNNN
      gc_batch_length   TYPE i VALUE 10,
      "! ตัวอักษรที่ยอมให้อยู่ในเลข batch
      gc_digits         TYPE string VALUE `0123456789`,
      "! running number ที่ไม่ยอมให้ใช้
      gc_running_zero   TYPE n LENGTH 4 VALUE '0000',
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

ENDCLASS.


CLASS zcl_zime001 IMPLEMENTATION.

  METHOD is_valid_batch_format.
    rv_valid = check_batch_format( iv_batch        = iv_batch
                                   iv_current_date = get_current_date( ) ).
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

ENDCLASS.
