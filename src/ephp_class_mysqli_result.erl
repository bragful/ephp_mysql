-module(ephp_class_mysqli_result).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-export([
    get_classes/0,

    mysqli_data_seek/4,
    mysqli_fetch_all/4
]).

-include_lib("ephp/include/ephp.hrl").
-include("ephp_mysql.hrl").

-import(ephp_class, [class_attr/2, class_attr/3]).

-spec get_classes() -> [class()].

get_classes() -> [
    #class{
        name = <<"mysqli_result">>,
        attrs = [
            class_attr(<<"current_field">>, public),
            class_attr(<<"field_count">>, public),
            class_attr(<<"lengths">>, public),
            class_attr(<<"num_rows">>, public),
            class_attr(<<"type">>, public)
        ],
        methods = [
            #class_method{
                name = <<"data_seek">>,
                code_type = builtin,
                args = [
                    #variable{name = <<"offset">>}
                ],
                builtin = {?MODULE, mysqli_data_seek},
                pack_args = true
            },
            #class_method{
                name = <<"fetch_all">>,
                code_type = builtin,
                args = [
                    #variable{name = <<"result_mode">>,
                              default_value = ?MYSQLI_NUM}
                ],
                builtin = {?MODULE, mysqli_fetch_all},
                pack_args = true
            }
        ],
        implements = [<<"Traversable">>]
    }
].

mysqli_data_seek(_Context, ObjRef, _Line, [{_, Offset}]) ->
    ObjCtx = ephp_object:get_context(ObjRef),
    case ephp_context:get(ObjCtx, #variable{name = <<"num_rows">>}) of
        Num when is_integer(Num) andalso Num > Offset ->
            ephp_context:set_meta(ObjCtx, current_row, Offset),
            true;
        _ ->
            false
    end.

mysqli_fetch_all(_Context, ObjRef, _Line, [{_, ResMode}]) ->
    ObjCtx = ephp_object:get_context(ObjRef),
    Rows = ephp_context:get_meta(ObjCtx, rows),
    Fields = ephp_context:get_meta(ObjCtx, field_names),
    ephp_array:from_list([ row2array(Row, Fields, ResMode) || Row <- Rows ]).

row2array(Row, _Fields, ?MYSQLI_NUM) -> ephp_array:from_list(Row);
row2array(Row, Fields, ?MYSQLI_ASSOC) ->
    ephp_array:from_list(lists:zip(Fields, Row));
row2array(Row, Fields, ?MYSQLI_BOTH) ->
    ephp_array:from_list(Row ++ lists:zip(Fields, Row)).
