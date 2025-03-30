*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_run DEFINITION INHERITING FROM cl_abap_parallel.
  PUBLIC SECTION.
    METHODS do REDEFINITION.

    CLASS-METHODS serialize
      IMPORTING data_to_serialize TYPE any
      RETURNING VALUE(result)     TYPE xstring.

    CLASS-METHODS deserialize
      IMPORTING data_to_deserialize TYPE xstring
      RETURNING VALUE(result)       TYPE i.
ENDCLASS.


CLASS lcl_run_inst DEFINITION INHERITING FROM cl_abap_parallel.
  PUBLIC SECTION.
    INTERFACES if_abap_parallel.

    METHODS constructor
      IMPORTING input_number TYPE i.

    DATA input_number  TYPE i READ-ONLY.
    DATA square_result TYPE i READ-ONLY.
ENDCLASS.


CLASS lcl_run IMPLEMENTATION.
  METHOD do.
    DATA(data_common_to_all_tasks) = VALUE string( ).
    IMPORT data = data_common_to_all_tasks FROM DATA BUFFER p_in_all.
    ASSERT data_common_to_all_tasks = `any type of data you want, will be passed by parameter for each task (to RFC and then method DO)`.
    DATA(input) = deserialize( p_in ).
    DATA(square) = input * input.
    p_out = serialize( square ).
  ENDMETHOD.

  METHOD serialize.
    EXPORT data = data_to_serialize TO DATA BUFFER result.
  ENDMETHOD.

  METHOD deserialize.
    IMPORT data = result FROM DATA BUFFER data_to_deserialize.
  ENDMETHOD.
ENDCLASS.


CLASS lcl_run_inst IMPLEMENTATION.
  METHOD if_abap_parallel~do.
*    DATA(data_common_to_all_tasks) = VALUE string( ).
*    IMPORT data = data_common_to_all_tasks FROM DATA BUFFER p_in_all.
*    ASSERT data_common_to_all_tasks = `any type of data you want, will be passed by parameter for each task (to RFC and then method DO)`.
    square_result = input_number * input_number.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ). " p_num_tasks = p_num_tasks p_timeout = p_timeout p_percentage = p_percentage p_num_processes = p_num_processes p_local_server = p_local_server p_abort_on_error = p_abort_on_error p_keeping_tasks = p_keeping_tasks ).
    me->input_number = input_number.
  ENDMETHOD.
ENDCLASS.
