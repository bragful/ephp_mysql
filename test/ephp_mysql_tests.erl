-module(ephp_mysql_tests).

-include_lib("eunit/include/eunit.hrl").

main_test() ->
    ?assertEqual(0, ephp_mysql:main(["test/code/01_mysql_connect.php"])).

main_file_not_found_test() ->
    ?assertEqual(2, ephp_mysql:main(["test/code/file_not_found"])).

main_error_test() ->
    ?assertEqual(1, ephp_mysql:main(["test/code/error.php"])).

main_other_error_test() ->
    ?assertEqual(3, ephp_mysql:main(["test/"])).

main_empty_test() ->
    ?assertEqual(1, ephp_mysql:main([])).
