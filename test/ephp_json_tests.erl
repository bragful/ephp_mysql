-module(ephp_json_tests).

-include_lib("eunit/include/eunit.hrl").

main_test() ->
    ?assertEqual(0, ephp_json:main(["test/code/01_json_encode.php"])).

main_file_not_found_test() ->
    ?assertEqual(2, ephp_json:main(["test/code/file_not_found"])).

main_error_test() ->
    ?assertEqual(1, ephp_json:main(["test/code/error.php"])).

main_other_error_test() ->
    ?assertEqual(3, ephp_json:main(["test/"])).

main_empty_test() ->
    ?assertEqual(1, ephp_json:main([])).
