-module(ephp_class_mysqli).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-export([
    get_classes/0,

    mysqli_construct/4,
    mysqli_query/4,
    mysqli_destruct/4
]).

-include_lib("p1_mysql/include/p1_mysql.hrl").
-include_lib("ephp/include/ephp.hrl").
-include("ephp_mysql.hrl").

-import(ephp_class, [class_attr/2, class_attr/3]).

-spec get_classes() -> [class()].

get_classes() -> [
    #class{
        name = <<"mysqli">>,
        attrs = [
            class_attr(<<"affected_rows">>, public),
            class_attr(<<"connect_errno">>, public),
            class_attr(<<"connect_error">>, public),
            class_attr(<<"errno">>, public),
            class_attr(<<"error">>, public),
            class_attr(<<"error_list">>, public, ephp_array:new()),
            class_attr(<<"field_count">>, public),
            class_attr(<<"host_info">>, public),
            class_attr(<<"protocol_version">>, public),
            class_attr(<<"server_info">>, public),
            class_attr(<<"server_version">>, public),
            class_attr(<<"info">>, public),
            class_attr(<<"insert_id">>, public),
            class_attr(<<"sqlstate">>, public),
            class_attr(<<"thread_id">>, public),
            class_attr(<<"warning_count">>, public)
        ],
        methods = [
            #class_method{
                name = <<"__construct">>,
                code_type = builtin,
                args = [
                    #variable{name = <<"host">>},
                    #variable{name = <<"user">>},
                    #variable{name = <<"pass">>},
                    #variable{name = <<"db">>},
                    #variable{name = <<"port">>},
                    #variable{name = <<"socket">>}
                ],
                builtin = {?MODULE, mysqli_construct},
                pack_args = true
            },
            #class_method{
                name = <<"query">>,
                code_type = builtin,
                args = [
                    #variable{name = <<"query">>},
                    #variable{name = <<"result_mode">>,
                              default_value = ?MYSQLI_STORE_RESULT}
                ],
                builtin = {?MODULE, mysqli_query},
                pack_args = true
            },
            #class_method{
                name = <<"__destruct">>,
                code_type = builtin,
                args = [],
                builtin = {?MODULE, mysqli_destruct},
                pack_args = true
            }
        ]
    }
].

mysqli_construct(_Context, ObjRef, _Line,
                [{_, Host0}, {_, User0}, {_, Pass0}, {_, DB0},
                 {_, Port0}, {_, Socket0}]) ->
    Host = vget_str(Host0, <<"mysqli.default_host">>),
    User = vget_str(User0, <<"mysqli.default_user">>),
    %% FIXME: find a way to avoid passwords for MySQL.
    Pass = vget_pass(Pass0, <<"mysqli.default_pw">>),
    Port = vget_int(Port0, <<"mysqli.default_port">>),
    _Socket = vget_str(Socket0, <<"mysqli.default_socket">>),
    DB = binary_to_list(DB0),
    LogFun = fun(_Level, _Format, _Args) -> ok end,
    case p1_mysql_conn:start_link(Host, Port, User, Pass, DB, LogFun) of
        {ok, PID} ->
            %% FIXME: try to figure out how to connect using local socket
            HostInfo = <<(list_to_binary(Host))/binary, " via TCP/IP">>,
            ClassCtx = ephp_object:get_context(ObjRef),
            ephp_context:set_meta(ClassCtx, conn_id, PID),
            ephp_context:set(ClassCtx, #variable{name = <<"host_info">>}, HostInfo),
            ok;
        _ ->
            undefined
    end.

vget_pass(undefined, Key) ->
    case ephp_config:get(Key) of
        <<>> -> "";
        Value -> binary_to_list(ephp_data:to_bin(Value))
    end;
vget_pass(<<>>, _Key) -> "";
vget_pass(Value, _Key) -> binary_to_list(ephp_data:to_bin(Value)).

vget_int(undefined, Key) -> ephp_data:to_int(ephp_config:get(Key));
vget_int(Value, _Key) -> Value.

vget_str(undefined, Key) -> binary_to_list(ephp_config:get(Key));
vget_str(Value, _Key) -> binary_to_list(Value).

mysqli_query(Context, ObjRef, Line, [{_, Query}, {_, ResMode}]) ->
    ClassCtx = ephp_object:get_context(ObjRef),
    ConnId = ephp_context:get_meta(ClassCtx, conn_id),
    {data, Res} = p1_mysql_conn:squery(ConnId, Query, self(), []),

    Classes = ephp_context:get_classes(Context),
    Result = ephp_class:instance(Classes, Context, Context, <<"mysqli_result">>, Line),
    ResCtx = ephp_object:get_context(Result),
    Lengths = ephp_array:from_list([ L || {_, _Name, L, _Type} <- Res#p1_mysql_result.fieldinfo ]),
    FieldNames = [ fix_field_name(Name) || {_, Name, _Length, _Type} <- Res#p1_mysql_result.fieldinfo ],
    ephp_context:set_bulk(ResCtx, [{#variable{name = <<"current_field">>}, 0},
                                   {#variable{name = <<"field_count">>},
                                    length(Res#p1_mysql_result.fieldinfo)},
                                   {#variable{name = <<"num_rows">>},
                                    length(Res#p1_mysql_result.rows)},
                                   {#variable{name = <<"type">>}, ResMode},
                                   {#variable{name = <<"lengths">>}, Lengths}]),
    Rows = [ [ fix_field(Field) || Field <- Row ] || Row <- Res#p1_mysql_result.rows ],
    ephp_context:set_meta(ResCtx, rows, Rows),
    ephp_context:set_meta(ResCtx, current_row, 0),
    ephp_context:set_meta(ResCtx, field_names, FieldNames),

    ephp_context:set_bulk(ClassCtx, [{#variable{name = <<"affected_rows">>},
                                      Res#p1_mysql_result.affectedrows},
                                     {#variable{name = <<"errno">>},
                                      Res#p1_mysql_result.error},
                                     {#variable{name = <<"error">>},
                                      Res#p1_mysql_result.error}]),
    Result.

fix_field_name(Name) ->
    case ephp_data:bin_to_number(list_to_binary(Name)) of
        undefined -> Name;
        Number -> Number
    end.

fix_field(L) when is_list(L) -> list_to_binary(L);
fix_field(Other) -> Other.

mysqli_destruct(_Context, ObjRef, _Line, []) ->
    ClassCtx = ephp_object:get_context(ObjRef),
    ConnId = ephp_context:get_meta(ClassCtx, conn_id),
    p1_mysql_conn:stop(ConnId),
    ok.
