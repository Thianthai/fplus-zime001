CLASS ltc_batch_format DEFINITION DEFERRED.
CLASS ltc_batch_number DEFINITION DEFERRED.
CLASS zcl_zime001 DEFINITION LOCAL FRIENDS ltc_batch_format ltc_batch_number.

"! ทดสอบการตรวจ format ของเลข batch YYMMDDNNNN
"! กำหนดวันที่ปัจจุบันเองผ่าน check_batch_format จึงไม่ขึ้นกับวันที่รัน test
CLASS ltc_batch_format DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS:
      "! วันที่ปัจจุบันสมมติในปีปกติ
      gc_today      TYPE d VALUE '20260315',
      "! วันที่ปัจจุบันสมมติในปีอธิกสุรทิน
      gc_today_leap TYPE d VALUE '20280101'.

    "! เรียก check_batch_format ด้วยวันที่สมมติ
    "! @parameter iv_batch | เลข batch ที่ต้องการตรวจ
    "! @parameter iv_today | วันที่ปัจจุบันสมมติ
    "! @parameter rv_valid | ผลการตรวจ
    METHODS check
      IMPORTING iv_batch        TYPE charg_d
                iv_today        TYPE d DEFAULT gc_today
      RETURNING VALUE(rv_valid) TYPE abap_boolean.

    "! เลขที่ถูกต้องทุกข้อต้องผ่าน
    METHODS valid_batch_passes        FOR TESTING.
    "! MMDD ไม่จำเป็นต้องตรงกับวันนี้ ขอแค่เป็นวันที่มีจริงในปีปัจจุบัน
    METHODS other_day_same_year_passes FOR TESTING.
    "! running number 9999 ยังอยู่ในช่วงที่ยอมรับ
    METHODS running_9999_passes       FOR TESTING.
    "! สั้นกว่า 10 ตัวหรือว่างต้องไม่ผ่าน
    METHODS short_or_blank_fails      FOR TESTING.
    "! มีตัวอักษรหรือช่องว่างต้องไม่ผ่าน
    METHODS non_digit_fails           FOR TESTING.
    "! YY ไม่ใช่ปีปัจจุบันต้องไม่ผ่าน
    METHODS other_year_fails          FOR TESTING.
    "! MM นอกช่วง 01-12 ต้องไม่ผ่าน
    METHODS invalid_month_fails       FOR TESTING.
    "! DD นอกช่วง 01-31 ต้องไม่ผ่าน
    METHODS invalid_day_fails         FOR TESTING.
    "! วันที่ที่ไม่มีจริงต้องไม่ผ่าน
    METHODS not_real_date_fails       FOR TESTING.
    "! 29 ก.พ. ผ่านเฉพาะปีอธิกสุรทิน
    METHODS leap_day_passes           FOR TESTING.
    "! running number 0000 ต้องไม่ผ่าน
    METHODS running_zero_fails        FOR TESTING.
    "! เลขที่สร้างจากวันที่ปัจจุบันจริงต้องผ่าน method public
    METHODS current_date_batch_passes FOR TESTING.

ENDCLASS.


"! ทดสอบการหาเลข batch ถัดไปจากรายการ batch ที่มีอยู่แล้ว
"! ส่งรายการ batch เองผ่าน next_batch_number จึงไม่อ่าน DB
CLASS ltc_batch_number DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS:
      "! วันที่ปัจจุบันสมมติ
      gc_today     TYPE d VALUE '20260315',
      "! วันที่ในปีหน้า แทนวันเริ่มตามแผนของ order ที่อยู่ข้ามปี
      gc_next_year TYPE d VALUE '20270105'.

    "! เรียก next_batch_number ด้วยวันที่สมมติ
    "! @parameter it_batches | batch ที่มีอยู่แล้วของ material
    "! @parameter iv_date    | วันที่ที่ใช้เป็น YYMMDD
    "! @parameter rv_batch   | เลข batch ถัดไป
    METHODS next
      IMPORTING it_batches      TYPE zcl_zime001=>tt_batch
                iv_date         TYPE d DEFAULT gc_today
      RETURNING VALUE(rv_batch) TYPE charg_d.

    "! ยังไม่มี batch ของวันนี้ต้องได้ 0001
    METHODS no_batch_gives_0001           FOR TESTING.
    "! มี batch แล้วต้องได้ค่าสูงสุดบวก 1 แม้รายการไม่เรียง
    METHODS max_plus_one                  FOR TESTING.
    "! running number ถึง 9999 แล้วต้องได้ค่าว่าง
    METHODS full_gives_blank              FOR TESTING.
    "! batch ที่ไม่ตรง format ต้องถูกข้าม
    METHODS invalid_format_skipped        FOR TESTING.
    "! batch ของวันอื่นต้องถูกข้าม
    METHODS other_day_skipped             FOR TESTING.
    "! วันที่ในปีหน้าต้องได้ YYMMDD ของวันนั้นและนับต่อจาก batch ของวันนั้น
    METHODS next_year_date                FOR TESTING.
    "! case ที่ยังไม่รู้จักต้องได้ค่าว่าง
    METHODS unknown_case_gives_blank      FOR TESTING.
    "! CASE_B ที่ไม่มี purchase order ต้องได้ค่าว่างโดยไม่อ่าน DB
    METHODS case_b_without_po_blank       FOR TESTING.
    "! CASE_C ที่ไม่มี inbound delivery ต้องได้ค่าว่างโดยไม่อ่าน DB
    METHODS case_c_without_delivery_blank FOR TESTING.

ENDCLASS.


CLASS ltc_batch_format IMPLEMENTATION.

  METHOD check.
    rv_valid = zcl_zime001=>check_batch_format( iv_batch        = iv_batch
                                                iv_current_date = iv_today ).
  ENDMETHOD.


  METHOD valid_batch_passes.
    cl_abap_unit_assert=>assert_true( act = check( '2603150001' ) msg = 'วันนี้ running 0001' ).
  ENDMETHOD.


  METHOD other_day_same_year_passes.
    cl_abap_unit_assert=>assert_true( act = check( '2601010001' ) msg = 'ต้นปี' ).
    cl_abap_unit_assert=>assert_true( act = check( '2612310001' ) msg = 'สิ้นปี' ).
  ENDMETHOD.


  METHOD running_9999_passes.
    cl_abap_unit_assert=>assert_true( act = check( '2603159999' ) msg = 'running 9999' ).
  ENDMETHOD.


  METHOD short_or_blank_fails.
    cl_abap_unit_assert=>assert_false( act = check( '260315001' ) msg = 'ยาว 9 ตัว' ).
    cl_abap_unit_assert=>assert_false( act = check( '' )          msg = 'ค่าว่าง' ).
  ENDMETHOD.


  METHOD non_digit_fails.
    cl_abap_unit_assert=>assert_false( act = check( '26031A0001' ) msg = 'มีตัวอักษร' ).
    cl_abap_unit_assert=>assert_false( act = check( ' 260315001' ) msg = 'ช่องว่างนำหน้า' ).
    cl_abap_unit_assert=>assert_false( act = check( '26031 0001' ) msg = 'ช่องว่างตรงกลาง' ).
  ENDMETHOD.


  METHOD other_year_fails.
    cl_abap_unit_assert=>assert_false( act = check( '2503150001' ) msg = 'ปีก่อน' ).
    cl_abap_unit_assert=>assert_false( act = check( '2703150001' ) msg = 'ปีหน้า' ).
  ENDMETHOD.


  METHOD invalid_month_fails.
    cl_abap_unit_assert=>assert_false( act = check( '2600150001' ) msg = 'เดือน 00' ).
    cl_abap_unit_assert=>assert_false( act = check( '2613150001' ) msg = 'เดือน 13' ).
  ENDMETHOD.


  METHOD invalid_day_fails.
    cl_abap_unit_assert=>assert_false( act = check( '2603000001' ) msg = 'วันที่ 00' ).
    cl_abap_unit_assert=>assert_false( act = check( '2603320001' ) msg = 'วันที่ 32' ).
  ENDMETHOD.


  METHOD not_real_date_fails.
    cl_abap_unit_assert=>assert_false( act = check( '2604310001' ) msg = '31 เมษายน' ).
    cl_abap_unit_assert=>assert_false( act = check( '2602290001' ) msg = '29 ก.พ. ปีปกติ' ).
    cl_abap_unit_assert=>assert_false( act = check( '2602300001' ) msg = '30 ก.พ.' ).
  ENDMETHOD.


  METHOD leap_day_passes.
    cl_abap_unit_assert=>assert_true( act = check( iv_batch = '2802290001'
                                                   iv_today = gc_today_leap )
                                      msg = '29 ก.พ. ปีอธิกสุรทิน' ).
  ENDMETHOD.


  METHOD running_zero_fails.
    cl_abap_unit_assert=>assert_false( act = check( '2603150000' ) msg = 'running 0000' ).
  ENDMETHOD.


  METHOD current_date_batch_passes.
    DATA(lv_today) = zcl_zime001=>get_current_date( ).
    DATA(lv_batch) = CONV charg_d( |{ substring( val = lv_today off = 2 len = 6 ) }0001| ).

    cl_abap_unit_assert=>assert_true( act = zcl_zime001=>is_valid_batch_format( lv_batch )
                                      msg = 'เลขของวันนี้ตามเวลา local' ).
  ENDMETHOD.

ENDCLASS.


CLASS ltc_batch_number IMPLEMENTATION.

  METHOD next.
    rv_batch = zcl_zime001=>next_batch_number( iv_current_date = iv_date
                                               it_batches      = it_batches ).
  ENDMETHOD.


  METHOD no_batch_gives_0001.
    cl_abap_unit_assert=>assert_equals( act = next( VALUE #( ) )
                                        exp = '2603150001'
                                        msg = 'ยังไม่มี batch' ).
  ENDMETHOD.


  METHOD max_plus_one.
    cl_abap_unit_assert=>assert_equals( act = next( VALUE #( ( '2603150003' )
                                                             ( '2603150010' )
                                                             ( '2603150002' ) ) )
                                        exp = '2603150011'
                                        msg = 'สูงสุด 0010' ).
  ENDMETHOD.


  METHOD full_gives_blank.
    cl_abap_unit_assert=>assert_initial( act = next( VALUE #( ( '2603150001' )
                                                              ( '2603159999' ) ) )
                                         msg = 'running 9999 แล้ว' ).
  ENDMETHOD.


  METHOD invalid_format_skipped.
    cl_abap_unit_assert=>assert_equals( act = next( VALUE #( ( '260315AB99' )
                                                             ( '26031599' )
                                                             ( '2603150005' ) ) )
                                        exp = '2603150006'
                                        msg = 'ข้าม batch ที่ไม่ตรง format' ).
  ENDMETHOD.


  METHOD other_day_skipped.
    cl_abap_unit_assert=>assert_equals( act = next( VALUE #( ( '2603149999' )
                                                             ( '2603160500' )
                                                             ( '2603150004' ) ) )
                                        exp = '2603150005'
                                        msg = 'ข้าม batch ของวันอื่น' ).
  ENDMETHOD.


  METHOD next_year_date.
    cl_abap_unit_assert=>assert_equals( act = next( it_batches = VALUE #( ( '2603150009' )
                                                                          ( '2701050003' ) )
                                                    iv_date    = gc_next_year )
                                        exp = '2701050004'
                                        msg = 'วันเริ่มตามแผนในปีหน้า' ).
  ENDMETHOD.


  METHOD unknown_case_gives_blank.
    cl_abap_unit_assert=>assert_initial( act = zcl_zime001=>get_batch_number(
                                                 iv_case             = 'CASE_Z'
                                                 is_batch_allocation = VALUE #( ) )
                                         msg = 'case ที่ยังไม่รู้จัก' ).
  ENDMETHOD.


  METHOD case_b_without_po_blank.
    cl_abap_unit_assert=>assert_initial( act = zcl_zime001=>get_batch_number(
                                                 iv_case             = zcl_zime001=>gc_case-b
                                                 is_batch_allocation = VALUE #( goodsmovementtype       = '101'
                                                                                goodsmovementrefdoctype = 'B' ) )
                                         msg = 'CASE_B ไม่มี purchase order' ).
  ENDMETHOD.


  METHOD case_c_without_delivery_blank.
    cl_abap_unit_assert=>assert_initial( act = zcl_zime001=>get_batch_number(
                                                 iv_case             = zcl_zime001=>gc_case-c
                                                 is_batch_allocation = VALUE #( purchaseorder           = '1'
                                                                                goodsmovementrefdoctype = 'B' ) )
                                         msg = 'CASE_C ไม่มี inbound delivery' ).
  ENDMETHOD.

ENDCLASS.
