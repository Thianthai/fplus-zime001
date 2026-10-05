"! ZIME001 log ชั่วคราวของ BAdI LOBM_AFTER_BATCH_NUMBER_INT
"! เก็บค่าที่ Custom Logic YY1_AFTER_BATCH_NUMBER_INT ได้รับลง table ZIME001_LOG
"! ใช้ดูว่าแต่ละ app ส่งค่าอะไรเข้ามา เพื่อแยก logic ตาม app
"! class นี้และ table ZIME001_LOG เป็นของชั่วคราว ต้องลบก่อน transport
"! class นี้ต้อง release C1 และเปิด Use in Key User Apps ไม่งั้น Custom Logic มองไม่เห็น
CLASS zcl_zime001_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! โครงสร้างเดียวกับ parameter BATCH_ALLOCATION ของ BAdI
      "! ชื่อ component ตรงกับ BAdI ให้ Custom Logic ส่งด้วย CORRESPONDING ได้
      "! ใช้ predefined type ทั้งหมดเพื่อไม่ต้องพึ่ง type ที่ release
      BEGIN OF ty_batch_allocation,
        material                     TYPE c LENGTH 40,
        plant                        TYPE c LENGTH 4,
        storagelocation              TYPE c LENGTH 4,
        materialgroup                TYPE c LENGTH 9,
        materialtype                 TYPE c LENGTH 4,
        supplier                     TYPE c LENGTH 10,
        batchbysupplier              TYPE c LENGTH 15,
        purchasingorganization       TYPE c LENGTH 4,
        issgorrcvgmaterial           TYPE c LENGTH 40,
        issuingorreceivingplant      TYPE c LENGTH 4,
        issgorrcvgbatch              TYPE c LENGTH 10,
        issuingorreceivingstorageloc TYPE c LENGTH 4,
        issgorrcvgspclstockind       TYPE c LENGTH 1,
        inventoryvaluationcategory   TYPE c LENGTH 1,
        goodsmovementtype            TYPE c LENGTH 3,
        inventoryspecialstocktype    TYPE c LENGTH 1,
        ordertype                    TYPE c LENGTH 4,
        ordercategory                TYPE n LENGTH 2,
        warehousenumber              TYPE c LENGTH 3,
        planningplant                TYPE c LENGTH 4,
        salesorder                   TYPE c LENGTH 10,
        salesorderitem               TYPE n LENGTH 6,
        salesorderscheduleline       TYPE n LENGTH 4,
        pricingreferencematerial     TYPE c LENGTH 40,
        purchaseorder                TYPE c LENGTH 10,
        purchaseorderitem            TYPE n LENGTH 5,
        purchasingdocumentcategory   TYPE c LENGTH 1,
        purchaseordertype            TYPE c LENGTH 4,
        manufacturingorder           TYPE c LENGTH 12,
        manufacturingorderitem       TYPE n LENGTH 4,
        goodsmovementrefdoctype      TYPE c LENGTH 1,
        productionplant              TYPE c LENGTH 4,
        deliverydocument             TYPE c LENGTH 10,
        deliverydocumentitem         TYPE n LENGTH 6,
        wbselementinternalid         TYPE n LENGTH 24,
      END OF ty_batch_allocation.

    "! บันทึกค่าที่ BAdI ได้รับ 1 row ต่อการเรียก 1 ครั้ง
    "! row ถูก commit พร้อมการ save ของ app
    "! ถ้า app ยกเลิกหรือ error row นี้จะหายไปด้วย
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter iv_batch_in         | parameter BATCH_IN ของ BAdI
    "! @parameter iv_batch_out_before | BATCH_OUT ก่อน Custom Logic แก้
    "! @parameter iv_batch_out_after  | BATCH_OUT หลัง Custom Logic แก้
    CLASS-METHODS write
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
                iv_batch_in         TYPE charg_d
                iv_batch_out_before TYPE charg_d
                iv_batch_out_after  TYPE charg_d.

  PRIVATE SECTION.

    "! เปิดหรือปิดการเก็บ log
    "! เปลี่ยนเป็น abap_false แล้ว activate เมื่อต้องการหยุดเก็บทันที
    CONSTANTS gc_active TYPE abap_boolean VALUE abap_true.

ENDCLASS.


CLASS zcl_zime001_log IMPLEMENTATION.

  METHOD write.
    IF gc_active = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_log) = CORRESPONDING zime001_log( is_batch_allocation ).

    " สร้าง uuid ไม่ได้ก็ไม่เก็บ log
    " ห้ามทำให้การสร้าง batch ล้มเพราะ log
    TRY.
        ls_log-log_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    ls_log-created_at       = utclong_current( ).
    ls_log-created_by       = cl_abap_context_info=>get_user_technical_name( ).
    ls_log-batch_in         = iv_batch_in.
    ls_log-batch_out_before = iv_batch_out_before.
    ls_log-batch_out_after  = iv_batch_out_after.
    ls_log-is_valid_format  = zcl_zime001=>is_valid_batch_format( iv_batch_in ).

    INSERT zime001_log FROM @ls_log.
  ENDMETHOD.

ENDCLASS.
