"! ZIME001 class ที่คงไว้เพื่อความ compatible ของ API ที่ release แล้วเท่านั้น
"! เดิมเป็น log ชั่วคราวของ BAdI LOBM_AFTER_BATCH_NUMBER_INT และถูกลบไปแล้ว
"! API ที่ release C1 ห้ามลบ จึงสร้างกลับมาโดยคง public interface เดิมไว้
"! ไม่มี logic และไม่มีที่เรียกใช้
"! ห้ามใช้ class นี้ใน code ใหม่
"! ห้ามแก้ public interface ทั้ง type และ parameter ของ method
CLASS zcl_zime001_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      "! โครงสร้างเดียวกับ parameter BATCH_ALLOCATION ของ BAdI
      "! คงไว้เพื่อความ compatible ของ API เท่านั้น
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

    "! ไม่ทำอะไร คงไว้เพื่อความ compatible ของ API เท่านั้น
    "! @parameter is_batch_allocation | ไม่ใช้
    "! @parameter iv_batch_in         | ไม่ใช้
    "! @parameter iv_batch_out_before | ไม่ใช้
    "! @parameter iv_batch_out_after  | ไม่ใช้
    CLASS-METHODS write
      IMPORTING is_batch_allocation TYPE ty_batch_allocation
                iv_batch_in         TYPE charg_d
                iv_batch_out_before TYPE charg_d
                iv_batch_out_after  TYPE charg_d.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_zime001_log IMPLEMENTATION.

  METHOD write.
    " ไม่มี logic
    " class นี้คงไว้เพื่อความ compatible ของ API ที่ release แล้วเท่านั้น
    RETURN.
  ENDMETHOD.

ENDCLASS.
