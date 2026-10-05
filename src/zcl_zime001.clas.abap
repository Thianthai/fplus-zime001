"! ZIME001 Automatic Batch Creation
"! logic ที่ Custom Logic YY1_AFTER_BATCH_NUMBER_INT เรียกใช้
"! Custom Logic เป็นของ BAdI LOBM_AFTER_BATCH_NUMBER_INT
"! class นี้ต้อง release C1 และเปิด Use in Key User Apps ไม่งั้น Custom Logic มองไม่เห็น
CLASS zcl_zime001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! case ของธุรกรรมที่เรียก BAdI
      ty_case TYPE c LENGTH 10,

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

    CONSTANTS:
      "! case ของธุรกรรมที่เรียก BAdI
      "! ยังเป็นค่า draft รอ map กับข้อมูลจริงจาก log ของ BAdI
      BEGIN OF gc_case,
        "! production order จาก Create, Change และ Mass Processing
        a TYPE ty_case VALUE 'CASE_A',
      END OF gc_case.

    "! ตรวจ format ของเลข batch YYMMDDNNNN เทียบกับวันที่ปัจจุบันตามเวลา local
    "! @parameter iv_batch | เลข batch ที่ต้องการตรวจ
    "! @parameter rv_valid | abap_true เมื่อผ่านทุกข้อ ไม่งั้น abap_false
    CLASS-METHODS is_valid_batch_format
      IMPORTING iv_batch        TYPE charg_d
      RETURNING VALUE(rv_valid) TYPE abap_boolean.

    "! สร้างเลข batch YYMMDDNNNN ถัดไปของ material
    "! YYMMDD มาจาก iv_date ถ้าไม่ส่งมาจะใช้วันที่ปัจจุบันตามเวลา local
    "! NNNN คือ running number สูงสุดของ material ที่ขึ้นต้นด้วย YYMMDD เดียวกันบวก 1
    "! ยังไม่เคยมี batch ของวันนั้นจะได้ 0001
    "! running number ถึง 9999 แล้วจะคืนค่าว่าง ให้ผู้เรียกไม่แตะเลข batch
    "! @parameter iv_material | material ที่กำลังสร้าง batch
    "! @parameter iv_date     | วันที่ที่ใช้เป็น YYMMDD
    "! @parameter rv_batch    | เลข batch ถัดไป หรือค่าว่างเมื่อสร้างไม่ได้
    CLASS-METHODS generate_batch_number
      IMPORTING iv_material     TYPE matnr
                iv_date         TYPE d OPTIONAL
      RETURNING VALUE(rv_batch) TYPE charg_d.

    "! หาเลข batch ตาม case ของธุรกรรม
    "! ค่าว่างหมายถึงไม่ต้องแตะ BATCH_OUT
    "! @parameter iv_case               | case ของธุรกรรม ค่าจาก gc_case
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter iv_batch_in           | parameter BATCH_IN ของ BAdI สำรองไว้ให้ case อื่น
    "! @parameter rv_batch              | เลข batch ใหม่ หรือค่าว่าง
    CLASS-METHODS get_batch_number
      IMPORTING iv_case               TYPE ty_case
                is_batch_allocation   TYPE ty_batch_allocation
                iv_batch_in           TYPE charg_d OPTIONAL
      RETURNING VALUE(rv_batch)       TYPE charg_d.

  PRIVATE SECTION.

    TYPES:
      "! รายการเลข batch
      tt_batch      TYPE STANDARD TABLE OF charg_d WITH EMPTY KEY,
      "! order type ของ production order
      ty_order_type TYPE c LENGTH 4.

    CONSTANTS:
      "! ความยาวของเลข batch ตาม format YYMMDDNNNN
      gc_batch_length     TYPE i VALUE 10,
      "! ตัวอักษรที่ยอมให้อยู่ในเลข batch
      gc_digits           TYPE string VALUE `0123456789`,
      "! running number ที่ไม่ยอมให้ใช้
      gc_running_zero     TYPE n LENGTH 4 VALUE '0000',
      "! running number สูงสุดที่ยอมให้ใช้
      gc_running_max      TYPE i VALUE 9999,
      "! system status REL ของ production order
      gc_status_released  TYPE c LENGTH 5 VALUE 'I0002'.

    CONSTANTS:
      "! key ของ constant parameter ใน ZTBC_PARAM
      BEGIN OF gc_param,
        "! module ของ parameter
        module_id             TYPE ztbc_param-module_id  VALUE 'MM',
        "! application ของ parameter
        app_id                TYPE ztbc_param-app_id     VALUE 'IME001',
        "! order type ของ production order ที่ต้องสร้างเลข batch
        production_order_type TYPE ztbc_param-param_name VALUE 'PRODUCTION_ORDER_TYPE',
      END OF gc_param.

    "! วันที่ปัจจุบันตามเวลา local
    "! แปลงไม่สำเร็จจะได้ค่าว่าง
    "! @parameter rv_date | วันที่ปัจจุบัน
    CLASS-METHODS get_current_date
      RETURNING VALUE(rv_date) TYPE d.

    "! ตรวจ format ของเลข batch YYMMDDNNNN เทียบกับวันที่ที่ส่งเข้ามา
    "! แยกวันที่เป็น parameter ไว้ให้ test กำหนดวันที่เองได้
    "! @parameter iv_batch        | เลข batch ที่ต้องการตรวจ
    "! @parameter iv_current_date | วันที่ที่ใช้เทียบปี
    "! @parameter rv_valid        | abap_true เมื่อผ่านทุกข้อ ไม่งั้น abap_false
    CLASS-METHODS check_batch_format
      IMPORTING iv_batch        TYPE charg_d
                iv_current_date TYPE d
      RETURNING VALUE(rv_valid) TYPE abap_boolean.

    "! หาเลข batch ถัดไปจากรายการ batch ที่มีอยู่แล้ว โดยไม่อ่าน DB
    "! แยกออกมาไว้ให้ test ส่งรายการ batch เองได้
    "! @parameter iv_current_date | วันที่ที่ใช้เป็น YYMMDD
    "! @parameter it_batches      | batch ที่มีอยู่แล้วของ material
    "! @parameter rv_batch        | เลข batch ถัดไป หรือค่าว่างเมื่อ running number เต็ม
    CLASS-METHODS next_batch_number
      IMPORTING iv_current_date TYPE d
                it_batches      TYPE tt_batch
      RETURNING VALUE(rv_batch) TYPE charg_d.

    "! เลข batch ของ production order
    "! order type ต้องอยู่ใน constant parameter
    "! order ต้อง released อยู่
    "! YYMMDD มาจากวันเริ่มตามแผนของ order
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_batch            | เลข batch ใหม่ หรือค่าว่างเมื่อไม่เข้าเงื่อนไข
    CLASS-METHODS get_batch_case_a
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
      RETURNING VALUE(rv_batch)     TYPE charg_d.

ENDCLASS.


CLASS zcl_zime001 IMPLEMENTATION.

  METHOD is_valid_batch_format.

    rv_valid = check_batch_format( iv_batch        = iv_batch
                                   iv_current_date = get_current_date( ) ).

  ENDMETHOD.


  METHOD generate_batch_number.

    DATA lt_batches TYPE tt_batch.

    " ไม่ส่งวันที่มา -> ใช้วันที่ปัจจุบันตามเวลา local
    DATA(lv_date) = COND d( WHEN iv_date IS NOT INITIAL THEN iv_date
                            ELSE get_current_date( ) ).

    " ไม่มีวันที่ให้ใช้ -> ไม่สร้างเลข batch
    IF lv_date IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lv_pattern) = |{ lv_date+2(6) }%|.

    " อ่าน batch ของ material ที่ขึ้นต้นด้วย YYMMDD เดียวกัน
    " ใช้ privileged access เพราะเป็น logic ของระบบ ไม่ขึ้นกับสิทธิ์ของ user ที่สร้าง batch
    " batch level เป็นระดับ material จึงไม่กรอง plant
    SELECT Batch
      FROM I_Batch WITH PRIVILEGED ACCESS
      WHERE Material = @iv_material
        AND Batch    LIKE @lv_pattern
      INTO TABLE @lt_batches.

    rv_batch = next_batch_number( iv_current_date = lv_date
                                  it_batches      = lt_batches ).

  ENDMETHOD.


  METHOD get_batch_number.

    " case ที่ยังไม่รู้จัก -> คืนค่าว่าง ไม่แตะ BATCH_OUT
    CASE iv_case.
      WHEN gc_case-a.
        rv_batch = get_batch_case_a( is_batch_allocation ).
    ENDCASE.

  ENDMETHOD.


  METHOD get_current_date.

    " วันที่ตามเวลา local
    " ZCL_UTILITY อ่าน timezone จาก constant parameter ถ้าไม่มีจะใช้ UTC+7
    zcl_utility=>get_local_datetime( IMPORTING ev_date = rv_date ).

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

    " YY ต้องเท่ากับ 2 หลักท้ายของปีที่ใช้เทียบ
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
      " นับเฉพาะ batch ของวันเดียวกันที่ตรง format
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

    " ยังไม่มี batch ของวันนั้น lv_max_running เป็น 0 จึงได้ 0001
    lv_next_running = lv_max_running + 1.
    rv_batch = |{ iv_current_date+2(6) }{ lv_next_running }|.

  ENDMETHOD.


  METHOD get_batch_case_a.

    DATA lr_order_type TYPE RANGE OF ty_order_type.

    " order type ต้องอยู่ใน constant parameter
    " ไม่เจอ parameter -> ไม่สร้างเลข batch
    DATA(lo_param) = zcl_param=>create_instance( iv_company_code = ''
                                                 iv_module_id    = gc_param-module_id ).

    TRY.
        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
                                       iv_param_name = gc_param-production_order_type
                             IMPORTING et_range      = lr_order_type ).
      CATCH zcx_param.
        RETURN.
    ENDTRY.

    IF is_batch_allocation-ordertype NOT IN lr_order_type.
      RETURN.
    ENDIF.

    " อ่านวันเริ่มตามแผนของ order
    " order ที่ยังไม่ถูกบันทึกลง DB จะอ่านไม่เจอ -> ไม่สร้างเลข batch
    SELECT SINGLE MfgOrderScheduledStartDate
      FROM I_ManufacturingOrder WITH PRIVILEGED ACCESS
      WHERE ManufacturingOrder = @is_batch_allocation-manufacturingorder
      INTO @DATA(lv_start_date).

    IF sy-subrc <> 0 OR lv_start_date IS INITIAL.
      RETURN.
    ENDIF.

    " order ต้องมี status REL ที่ยัง active อยู่
    " REL ที่ถูกยกเลิกไปแล้วไม่นับ
    " partially released ไม่นับ
    SELECT SINGLE @abap_true
      FROM I_ManufacturingOrderStatus WITH PRIVILEGED ACCESS
      WHERE ManufacturingOrder = @is_batch_allocation-manufacturingorder
        AND StatusCode         = @gc_status_released
        AND StatusIsInactive   = @abap_false
      INTO @DATA(lv_is_released).

    IF lv_is_released = abap_false.
      RETURN.
    ENDIF.

    rv_batch = generate_batch_number( iv_material = is_batch_allocation-material
                                      iv_date     = lv_start_date ).

  ENDMETHOD.

ENDCLASS.
