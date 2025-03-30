*"* use this source file for your ABAP unit test classes

CLASS ltc_run DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_calculate_square FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_run_inst DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS test_calculate_square FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_run IMPLEMENTATION.
  METHOD test_calculate_square.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " GIVEN tasks to calculate square (** 2) of integer
    "       Task 1 is to calculate 2 ** 2
    "       Task 2 is to calculate 3 ** 2
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA(parallelizer) = NEW lcl_run( " Maximum number of tasks processed in parallel at any time.
                                      " 0 = according to P_PERCENTAGE (50% of dialog tasks if P_PERCENTAGE = 0).
                                      p_num_tasks      = 0
                                      p_timeout        = 0
                                      p_percentage     = 0
                                      " Not used anymore (don't pass it or keep it zero).
                                      p_num_processes  = 0
                                      p_local_server   = abap_false
                                      p_abort_on_error = abap_false
                                      " See RECEIVE RESULTS FROM FUNCTION func KEEPING TASK ...
                                      p_keeping_tasks  = abap_false ).
    DATA(in_tab) = VALUE cl_abap_parallel=>t_in_tab( " Input data for task 1
                                                     ( lcl_run=>serialize( 2 ) )
                                                     " Input data for task 2
                                                     ( lcl_run=>serialize( 3 ) ) ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " WHEN it's run (RFC RS_ABAP_PARALLEL -> method DO)
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Debug = 'X' --> sequential execution, not parallel, for debug purpose.
    DATA(debug) = abap_false.
    " P_OUT_TAB contient le résultat, MESSAGE contient le message d'erreur correspondant à COMMUNICATION_FAILURE ou SYSTEM_FAILURE.
    parallelizer->run(
      EXPORTING p_in_tab  = in_tab
                p_in_all  = lcl_run=>serialize(
                    `any type of data you want, will be passed by parameter for each task (to RFC and then method DO)` )
                p_debug   = debug
      IMPORTING p_out_tab = DATA(serialized_data_for_all_tasks) ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " THEN results are:
    "       Task 1 of 2 ** 2 ==> 4
    "       Task 2 of 3 ** 2 ==> 9
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT serialized_data_for_all_tasks REFERENCE INTO DATA(serialized_data_for_one_task).
      DATA(square) = lcl_run=>deserialize( serialized_data_for_one_task->result ).
      DATA(task_number) = serialized_data_for_one_task->index.
      CASE task_number.
        WHEN 1. cl_abap_unit_assert=>assert_equals( exp = 4
                                                    act = square ).
        WHEN 2. cl_abap_unit_assert=>assert_equals( exp = 9
                                                    act = square ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


CLASS ltc_run_inst IMPLEMENTATION.
  METHOD test_calculate_square.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " GIVEN tasks to calculate square (** 2) of integer
    "       Task 1 is to calculate 2 ** 2
    "       Task 2 is to calculate 3 ** 2
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    DATA(parallelizer) = NEW cl_abap_parallel( " Maximum number of tasks processed in parallel at any time.
                                               " 0 = according to P_PERCENTAGE (50% of dialog tasks if P_PERCENTAGE = 0).
                                               p_num_tasks      = 0
                                               p_timeout        = 0
                                               p_percentage     = 0
                                               " Not used anymore (don't pass it or keep it zero).
                                               p_num_processes  = 0
                                               p_local_server   = abap_false
                                               p_abort_on_error = abap_false
                                               " See RECEIVE RESULTS FROM FUNCTION func KEEPING TASK ...
                                               p_keeping_tasks  = abap_false ).
    DATA(in_tab) = VALUE cl_abap_parallel=>t_in_inst_tab( " Input data for task 1
                                                          ( NEW lcl_run_inst( 2 ) )
                                                          " Input data for task 2
                                                          ( NEW lcl_run_inst( 3 ) ) ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " WHEN it's run (RFC RS_ABAP_PARALLEL -> method DO)
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Debug = 'X' --> sequential execution, not parallel, for debug purpose.
    DATA(debug) = abap_false.
    " P_OUT_TAB contient le résultat, MESSAGE contient le message d'erreur correspondant à COMMUNICATION_FAILURE ou SYSTEM_FAILURE.
    parallelizer->run_inst( EXPORTING p_in_tab  = in_tab
                                      p_debug   = debug
                            IMPORTING p_out_tab = DATA(output_tasks) ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " THEN results are:
    "       Task 1 of 2 ** 2 ==> 4
    "       Task 2 of 3 ** 2 ==> 9
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    LOOP AT output_tasks REFERENCE INTO DATA(output_task).
      DATA(task_result_instance) = CAST lcl_run_inst( output_task->inst ).
      CASE output_task->index.
        WHEN 1. cl_abap_unit_assert=>assert_equals( exp = 4
                                                    act = task_result_instance->square_result ).
        WHEN 2. cl_abap_unit_assert=>assert_equals( exp = 9
                                                    act = task_result_instance->square_result ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
