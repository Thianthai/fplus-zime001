"! ZIME001 Automatic Batch Creation
"! logic ที่ Custom Logic YY1_AFTER_BATCH_NUMBER_INT เรียกใช้
"! Custom Logic เป็นของ BAdI LOBM_AFTER_BATCH_NUMBER_INT
"! class นี้ต้อง release C1 และเปิด Use in Key User Apps ไม่งั้น Custom Logic มองไม่เห็น
"! ดูสรุปแต่ละ case ว่าเช็คอะไรและรองรับ app ไหนที่ constant gc_case
CLASS zcl_zime001 DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

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
      "! case ของธุรกรรมที่เรียก BAdI ตัวนี้
      "! BAdI ไม่ส่งชื่อ app มา จึงแยก case จากค่าใน BATCH_ALLOCATION
      "! ทุก case ต้องผ่านเงื่อนไขของตัวเองก่อน
      "! ไม่ผ่านเงื่อนไขจะคืนค่าว่างและไม่แตะ BATCH_OUT
      "! NNNN ของทุก case คือ running number ของ material ใน I_Batch ที่ขึ้นต้นด้วย YYMMDD เดียวกันบวก 1
      BEGIN OF gc_case,
        "! CASE_A production order
        "! app: Create Production Order (CO01)
        "! app: Change Production Order (CO02)
        "! app: Mass Processing of Production Orders
        "! BAdI ถูกเรียกตอน release เพราะ order type ตั้งให้สร้าง batch ตอน release
        "! order ที่ยังไม่ save มีเลขขึ้นต้นด้วย % จะข้าม
        "! ต้องสร้าง order ก่อน แล้วค่อย release ทีหลัง
        "! order type ต้องอยู่ใน constant parameter PRODUCTION_ORDER_TYPE
        "! YYMMDD มาจากวันเริ่มตามแผนของ order ใน I_ManufacturingOrder
        a TYPE ty_case VALUE 'CASE_A',
        "! CASE_B goods receipt อ้างอิง purchase order หรือ production order
        "! app: Goods Receipt (MIGO) action Goods Receipt คู่กับ reference document Purchase Order
        "! app: Goods Receipt (MIGO) action Goods Receipt คู่กับ reference document Order
        "! ต้องมี movement type และไม่มี inbound delivery
        "! movement type ต้องอยู่ใน constant parameter MOVEMENT_TYPE ของ GOODS_RECEIPT
        "! ประเภทเอกสารอ้างอิงต้องอยู่ใน constant parameter REF_DOC_TYPE
        "! material ต้องเปิดใช้ batch management ใน I_Product
        "! BAdI ถูกเรียกตอน Check และใช้เลขเดิมตอน Post
        "! YYMMDD ใช้วันที่ปัจจุบันตามเวลา local เพราะ BAdI ไม่ส่ง posting date มา
        "! GR จาก app อื่นที่ส่งค่าเหมือนกันจะเข้า case นี้ด้วย
        b TYPE ty_case VALUE 'CASE_B',
        "! CASE_C inbound delivery อ้างอิง purchase order
        "! app: Create Inbound Delivery (VL31)
        "! Change Inbound Delivery (VL32) ไม่เรียก BAdI ตัวนี้
        "! ต้องมี inbound delivery และ purchase order
        "! ประเภทเอกสารอ้างอิงต้องอยู่ใน constant parameter REF_DOC_TYPE
        "! PO type ที่ถูก exclude ใน constant parameter PO_DOCTYPE_STO ไม่สร้างเลข batch
        "! material ต้องเปิดใช้ batch management ใน I_Product
        "! material เดียวกันใน delivery เดียวกันได้ batch เดียวกับ item แรก
        "! YYMMDD มาจาก delivery date ของ schedule line บรรทัดแรกของ PO item
        c TYPE ty_case VALUE 'CASE_C',
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

    "! แยก case ของธุรกรรมจากค่าใน BATCH_ALLOCATION
    "! กฎของแต่ละ case ได้จาก log ของ BAdI ที่ทดสอบจริง
    "! ไม่เข้า case ไหนจะคืนค่าว่าง
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_case             | case จาก gc_case หรือค่าว่าง
    CLASS-METHODS determine_case
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
      RETURNING VALUE(rv_case)      TYPE ty_case.

  PRIVATE SECTION.

    TYPES:
      "! รายการเลข batch
      tt_batch          TYPE STANDARD TABLE OF charg_d WITH EMPTY KEY,
      "! order type ของ production order
      ty_order_type     TYPE c LENGTH 4,
      "! movement type ของ goods movement
      ty_movement_type  TYPE c LENGTH 3,
      "! ประเภทเอกสารที่ goods movement อ้างอิง
      ty_ref_doc_type   TYPE c LENGTH 1,
      "! document type ของ purchase order
      ty_po_type        TYPE c LENGTH 4,

      "! เลข batch ที่จำไว้ของ material ใน inbound delivery ที่กำลัง save
      BEGIN OF ty_delivery_batch,
        delivery_document TYPE c LENGTH 10,
        material          TYPE c LENGTH 40,
        delivery_item     TYPE n LENGTH 6,
        batch             TYPE charg_d,
      END OF ty_delivery_batch,

      "! รายการเลข batch ที่จำไว้ 1 บรรทัดต่อ delivery และ material
      tt_delivery_batch TYPE SORTED TABLE OF ty_delivery_batch
                        WITH UNIQUE KEY delivery_document material.

    CONSTANTS:
      "! ความยาวของเลข batch ตาม format YYMMDDNNNN
      gc_batch_length     TYPE i VALUE 10,
      "! ตัวอักษรที่ยอมให้อยู่ในเลข batch
      gc_digits           TYPE string VALUE `0123456789`,
      "! running number ที่ไม่ยอมให้ใช้
      gc_running_zero     TYPE n LENGTH 4 VALUE '0000',
      "! running number สูงสุดที่ยอมให้ใช้
      gc_running_max      TYPE i VALUE 9999,
      "! ตัวแรกของเลข order ชั่วคราวที่ระบบให้ระหว่างสร้าง order ที่ยังไม่ save
      gc_temporary_order  TYPE c LENGTH 1 VALUE '%',
      "! order category ของ production order
      gc_order_category_production TYPE n LENGTH 2 VALUE '10',
      "! user เดียวที่ logic ทำงานให้ระหว่างทดสอบ
      "! ชั่วคราว ลบก่อน transport
      gc_test_user        TYPE c LENGTH 12 VALUE 'CB9980000010'.

    CONSTANTS:
      "! key ของ constant parameter ใน ZTBC_PARAM
      BEGIN OF gc_param,
        "! module ของ parameter
        module_id             TYPE ztbc_param-module_id  VALUE 'MM',
        "! application ของ parameter
        app_id                TYPE ztbc_param-app_id     VALUE 'IME001',
        "! order type ของ production order ที่ต้องสร้างเลข batch
        production_order_type TYPE ztbc_param-param_name VALUE 'PRODUCTION_ORDER_TYPE',
        "! movement type ที่ต้องสร้างเลข batch
        movement_type         TYPE ztbc_param-param_name VALUE 'MOVEMENT_TYPE',
        "! ประเภทเอกสารอ้างอิงที่ต้องสร้างเลข batch
        ref_doc_type          TYPE ztbc_param-param_name VALUE 'REF_DOC_TYPE',
        "! PO type ของ stock transport order ที่ไม่ต้องสร้างเลข batch
        po_doctype_sto        TYPE ztbc_param-param_name VALUE 'PO_DOCTYPE_STO',
        "! additional parameter ของ goods receipt
        ext_goods_receipt     TYPE ztbc_param-param_ext  VALUE 'GOODS_RECEIPT',
      END OF gc_param.

    "! เลข batch ที่จำไว้ข้าม item ใน save เดียวกันของ inbound delivery
    "! ให้ material เดียวกันใน delivery เดียวกันได้ batch เดียวกับ item แรก
    CLASS-DATA gt_delivery_batch TYPE tt_delivery_batch.

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
    "! BAdI ถูกเรียกตอน release ของ order เพราะ order type ตั้งให้สร้าง batch ตอน release
    "! order type ต้องอยู่ใน constant parameter
    "! YYMMDD มาจากวันเริ่มตามแผนของ order
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_batch            | เลข batch ใหม่ หรือค่าว่างเมื่อไม่เข้าเงื่อนไข
    CLASS-METHODS get_batch_case_a
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
      RETURNING VALUE(rv_batch)     TYPE charg_d.

    "! เลข batch ของ goods receipt อ้างอิง purchase order หรือ production order
    "! movement type และประเภทเอกสารอ้างอิงต้องอยู่ใน constant parameter
    "! material ต้องเปิดใช้ batch management
    "! YYMMDD ใช้วันที่ปัจจุบันตามเวลา local เพราะ BAdI ไม่ส่ง posting date มา
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_batch            | เลข batch ใหม่ หรือค่าว่างเมื่อไม่เข้าเงื่อนไข
    CLASS-METHODS get_batch_case_b
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
      RETURNING VALUE(rv_batch)     TYPE charg_d.

    "! เลข batch ของ inbound delivery อ้างอิง purchase order
    "! ประเภทเอกสารอ้างอิงต้องอยู่ใน constant parameter
    "! PO type ที่ถูก exclude ใน constant parameter ไม่ต้องสร้างเลข batch
    "! material ต้องเปิดใช้ batch management
    "! material เดียวกันใน delivery เดียวกันได้ batch เดียวกับ item แรก
    "! YYMMDD มาจาก delivery date ของ schedule line บรรทัดแรกของ PO item
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_batch            | เลข batch ใหม่ หรือค่าว่างเมื่อไม่เข้าเงื่อนไข
    CLASS-METHODS get_batch_case_c
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
      RETURNING VALUE(rv_batch)     TYPE charg_d.

    "! เลข batch ที่จำไว้ของ material เดียวกันใน delivery เดียวกัน
    "! เลขที่จำไว้เป็นของ delivery อื่นจะถูกลบทิ้งแล้วคืนค่าว่าง
    "! @parameter is_batch_allocation | parameter BATCH_ALLOCATION ของ BAdI
    "! @parameter rv_batch            | เลข batch ที่จำไว้ หรือค่าว่างเมื่อไม่มีหรือใช้ไม่ได้
    CLASS-METHODS get_remembered_batch
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

    " ชั่วคราวระหว่างทดสอบ ทำงานเฉพาะ user ทดสอบ
    " user อื่นได้เลข batch ปกติจาก number range
    " ลบเงื่อนไขนี้ก่อน transport
    IF cl_abap_context_info=>get_user_technical_name( ) <> gc_test_user.
      RETURN.
    ENDIF.

    " case ที่ยังไม่รู้จัก -> คืนค่าว่าง ไม่แตะ BATCH_OUT
    CASE iv_case.
      WHEN gc_case-a.
        rv_batch = get_batch_case_a( is_batch_allocation ).
      WHEN gc_case-b.
        rv_batch = get_batch_case_b( is_batch_allocation ).
      WHEN gc_case-c.
        rv_batch = get_batch_case_c( is_batch_allocation ).
    ENDCASE.

  ENDMETHOD.


  METHOD determine_case.

    " production order ส่ง order category และเลข order มา โดยไม่มี movement type
    IF is_batch_allocation-ordercategory = gc_order_category_production
    AND is_batch_allocation-manufacturingorder IS NOT INITIAL
    AND is_batch_allocation-goodsmovementtype IS INITIAL.
      rv_case = gc_case-a.

    " goods receipt ส่ง movement type มา โดยไม่มีเลข delivery
    " เอกสารอ้างอิงที่รองรับไปเช็คจาก constant parameter ใน get_batch_case_b
    ELSEIF is_batch_allocation-goodsmovementtype IS NOT INITIAL
    AND is_batch_allocation-deliverydocument IS INITIAL.
      rv_case = gc_case-b.

    " inbound delivery ส่งเลข delivery และ purchase order มา
    ELSEIF is_batch_allocation-deliverydocument IS NOT INITIAL
    AND is_batch_allocation-purchaseorder IS NOT INITIAL.
      rv_case = gc_case-c.

    ENDIF.

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

    " ปิดการเช็ค order type ชั่วคราว
    " config ของ order type มีตัวอักษรที่มองไม่เห็นติดอยู่ ทำให้เทียบกับ constant parameter ไม่ตรง
    " เปิดกลับหลังแก้ config ของ order type แล้ว
*    DATA lr_order_type TYPE RANGE OF ty_order_type.
*    DATA lv_order_type TYPE ty_order_type.

    " order ที่ยังไม่ save มีเลขชั่วคราว จึงอ่านวันเริ่มตามแผนจาก DB ไม่ได้
    " ข้ามไปใช้เลข batch ปกติ
    " process ที่ตกลงไว้คือสร้าง order ก่อน แล้วค่อย release ทีหลัง
    IF is_batch_allocation-manufacturingorder(1) = gc_temporary_order.
      RETURN.
    ENDIF.

    " order type ต้องอยู่ใน constant parameter
    " ไม่เจอ parameter -> ไม่สร้างเลข batch
*    DATA(lo_param) = zcl_param=>create_instance( iv_company_code = ''
*                                                 iv_module_id    = gc_param-module_id ).
*
*    TRY.
*        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
*                                       iv_param_name = gc_param-production_order_type
*                             IMPORTING et_range      = lr_order_type ).
*      CATCH zcx_param.
*        RETURN.
*    ENDTRY.
*
*    " order type ใน config มีตัวอักษรที่มองไม่เห็นติดมา
*    " ต้อง clear ออกก่อนเทียบกับ constant parameter
*    lv_order_type = zcl_utility=>remove_invisible_char( is_batch_allocation-ordertype ).
*
*    IF lv_order_type NOT IN lr_order_type.
*      RETURN.
*    ENDIF.

    " อ่านวันเริ่มตามแผนของ order
    " ไม่เช็ค status REL เพราะ BAdI ถูกเรียกตอน release ซึ่ง status ยังไม่ถูกบันทึก
    " อ่านไม่เจอ -> ไม่สร้างเลข batch
    SELECT SINGLE MfgOrderScheduledStartDate
      FROM I_ManufacturingOrder WITH PRIVILEGED ACCESS
      WHERE ManufacturingOrder = @is_batch_allocation-manufacturingorder
      INTO @DATA(lv_start_date).

    IF sy-subrc <> 0 OR lv_start_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_batch = generate_batch_number( iv_material = is_batch_allocation-material
                                      iv_date     = lv_start_date ).

  ENDMETHOD.


  METHOD get_batch_case_b.

    DATA lr_movement_type TYPE RANGE OF ty_movement_type.
    DATA lr_ref_doc_type  TYPE RANGE OF ty_ref_doc_type.

    " รับของผ่าน inbound delivery ไม่ใช่ case นี้
    IF is_batch_allocation-deliverydocument IS NOT INITIAL.
      RETURN.
    ENDIF.

    " movement type และประเภทเอกสารอ้างอิงต้องอยู่ใน constant parameter
    " ไม่เจอ parameter -> ไม่สร้างเลข batch
    DATA(lo_param) = zcl_param=>create_instance( iv_company_code = ''
                                                 iv_module_id    = gc_param-module_id ).

    TRY.
        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
                                       iv_param_name = gc_param-movement_type
                                       iv_param_ext  = gc_param-ext_goods_receipt
                             IMPORTING et_range      = lr_movement_type ).

        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
                                       iv_param_name = gc_param-ref_doc_type
                             IMPORTING et_range      = lr_ref_doc_type ).
      CATCH zcx_param.
        RETURN.
    ENDTRY.

    IF is_batch_allocation-goodsmovementtype       NOT IN lr_movement_type
    OR is_batch_allocation-goodsmovementrefdoctype NOT IN lr_ref_doc_type.
      RETURN.
    ENDIF.

    " material ต้องเปิดใช้ batch management
    " อ่านไม่เจอ -> ไม่สร้างเลข batch
    SELECT SINGLE IsBatchManagementRequired
      FROM I_Product WITH PRIVILEGED ACCESS
      WHERE Product = @is_batch_allocation-material
      INTO @DATA(lv_batch_required).

    IF lv_batch_required = abap_false.
      RETURN.
    ENDIF.

    " BAdI ไม่ส่ง posting date มา และเอกสารยังไม่ถูกบันทึก
    " ใช้วันที่ปัจจุบันตามเวลา local แทน
    " ถ้า user แก้ posting date เป็นวันอื่น YYMMDD จะไม่ตรงกับ posting date
    rv_batch = generate_batch_number( is_batch_allocation-material ).

  ENDMETHOD.


  METHOD get_batch_case_c.

    DATA lr_ref_doc_type  TYPE RANGE OF ty_ref_doc_type.
    DATA lr_po_type       TYPE RANGE OF ty_po_type.
    DATA lv_delivery_date TYPE d.

    " ต้องเป็น inbound delivery ที่อ้างอิง purchase order
    IF is_batch_allocation-deliverydocument IS INITIAL
    OR is_batch_allocation-purchaseorder    IS INITIAL.
      RETURN.
    ENDIF.

    " ประเภทเอกสารอ้างอิงและ PO type ต้องผ่าน constant parameter
    " ไม่เจอ parameter -> ไม่สร้างเลข batch
    DATA(lo_param) = zcl_param=>create_instance( iv_company_code = ''
                                                 iv_module_id    = gc_param-module_id ).

    TRY.
        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
                                       iv_param_name = gc_param-ref_doc_type
                             IMPORTING et_range      = lr_ref_doc_type ).

        lo_param->get_range( EXPORTING iv_app_id     = gc_param-app_id
                                       iv_param_name = gc_param-po_doctype_sto
                             IMPORTING et_range      = lr_po_type ).
      CATCH zcx_param.
        RETURN.
    ENDTRY.

    IF is_batch_allocation-goodsmovementrefdoctype NOT IN lr_ref_doc_type.
      RETURN.
    ENDIF.

    " BAdI ไม่ส่ง PO type มา จึงอ่านจาก purchase order เอง
    " range ของ PO type เป็นแบบ exclude
    " PO type ที่ถูก exclude จะไม่อยู่ใน range -> ไม่สร้างเลข batch
    SELECT SINGLE PurchaseOrderType
      FROM I_PurchaseOrderAPI01 WITH PRIVILEGED ACCESS
      WHERE PurchaseOrder = @is_batch_allocation-purchaseorder
      INTO @DATA(lv_po_type).

    IF sy-subrc <> 0 OR lv_po_type NOT IN lr_po_type.
      RETURN.
    ENDIF.

    " material ต้องเปิดใช้ batch management
    " อ่านไม่เจอ -> ไม่สร้างเลข batch
    SELECT SINGLE IsBatchManagementRequired
      FROM I_Product WITH PRIVILEGED ACCESS
      WHERE Product = @is_batch_allocation-material
      INTO @DATA(lv_batch_required).

    IF lv_batch_required = abap_false.
      RETURN.
    ENDIF.

    " material เดียวกันใน delivery เดียวกันใช้เลขของ item แรก
    rv_batch = get_remembered_batch( is_batch_allocation ).
    IF rv_batch IS NOT INITIAL.
      RETURN.
    ENDIF.

    " BAdI ไม่ส่ง delivery date มา และ delivery ยังไม่ถูกบันทึก
    " ใช้ delivery date ของ schedule line บรรทัดแรกของ PO item แทน
    " ถ้า user แก้ delivery date ของ inbound delivery เป็นวันอื่น YYMMDD จะไม่ตรงกัน
    SELECT ScheduleLineDeliveryDate
      FROM I_PurOrdScheduleLineAPI01 WITH PRIVILEGED ACCESS
      WHERE PurchaseOrder     = @is_batch_allocation-purchaseorder
        AND PurchaseOrderItem = @is_batch_allocation-purchaseorderitem
      ORDER BY PurchaseOrderScheduleLine
      INTO TABLE @DATA(lt_schedule_line)
      UP TO 1 ROWS.

    lv_delivery_date = VALUE #( lt_schedule_line[ 1 ]-schedulelinedeliverydate OPTIONAL ).

    IF lv_delivery_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_batch = generate_batch_number( iv_material = is_batch_allocation-material
                                      iv_date     = lv_delivery_date ).

    " จำเลขไว้ให้ item ถัดไปของ material เดียวกันใน delivery เดียวกัน
    IF rv_batch IS NOT INITIAL.
      INSERT VALUE #( delivery_document = is_batch_allocation-deliverydocument
                      material          = is_batch_allocation-material
                      delivery_item     = is_batch_allocation-deliverydocumentitem
                      batch             = rv_batch ) INTO TABLE gt_delivery_batch.
    ENDIF.

  ENDMETHOD.


  METHOD get_remembered_batch.

    READ TABLE gt_delivery_batch ASSIGNING FIELD-SYMBOL(<lfs_delivery_batch>)
      WITH TABLE KEY delivery_document = is_batch_allocation-deliverydocument
                     material          = is_batch_allocation-material.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " เลข delivery ชั่วคราวซ้ำกันได้ทุก delivery ที่สร้างใน session เดียวกัน
    " เลข item ไม่เพิ่มขึ้น -> เป็น delivery ใหม่ เลขที่จำไว้เป็นของ delivery ก่อนหน้า
    IF is_batch_allocation-deliverydocumentitem <= <lfs_delivery_batch>-delivery_item.
      DELETE TABLE gt_delivery_batch FROM <lfs_delivery_batch>.
      RETURN.
    ENDIF.

    " batch ใน save เดียวกันยังไม่ถูกบันทึก จึงยังไม่อยู่ใน I_Batch
    " เจอใน I_Batch แล้ว -> delivery ก่อนหน้า save ไปแล้ว เลขที่จำไว้ใช้ไม่ได้
    SELECT SINGLE @abap_true
      FROM I_Batch WITH PRIVILEGED ACCESS
      WHERE Material = @is_batch_allocation-material
        AND Batch    = @<lfs_delivery_batch>-batch
      INTO @DATA(lv_batch_exists).

    IF lv_batch_exists = abap_true.
      DELETE TABLE gt_delivery_batch FROM <lfs_delivery_batch>.
      RETURN.
    ENDIF.

    " ยังเป็น delivery เดียวกัน จำเลข item ล่าสุดไว้แล้วใช้เลขเดิม
    <lfs_delivery_batch>-delivery_item = is_batch_allocation-deliverydocumentitem.
    rv_batch = <lfs_delivery_batch>-batch.

  ENDMETHOD.

ENDCLASS.
