-module(ephp_lib_mysqli).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,
    get_classes/0,

    mysqli_connect/8,
    mysqli_get_host_info/3,
    mysqli_close/3,

    mysqli_construct/4,
    mysqli_destruct/4
]).

-import(ephp_class, [class_attr/2, class_attr/3]).

-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    % mysqli_connect ([ string $host = ini_get("mysqli.default_host")
    %                 [, string $username = ini_get("mysqli.default_user")
    %                 [, string $passwd = ini_get("mysqli.default_pw")
    %                 [, string $dbname = ""
    %                 [, int $port = ini_get("mysqli.default_port")
    %                 [, string $socket = ini_get("mysqli.default_socket") ]]]]]] )
    {mysqli_connect, [{args, {0, 6, undefined, [{string, undefined},
                                                {string, undefined},
                                                {string, undefined},
                                                {string, <<>>},
                                                {integer, undefined},
                                                {string, undefined}]}}]},
    {mysqli_get_host_info, [object]},
    {mysqli_close, [object]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [
    {<<"mysqli.default_host">>, <<"localhost">>},
    {<<"mysqli.default_user">>, <<"root">>},
    {<<"mysqli.default_pw">>, <<>>},
    {<<"mysqli.default_port">>, 3306},
    %% FIXME: find the default socket to put it here
    {<<"mysqli.default_socket">>, <<>>}
].

-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

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
            class_attr(<<"warning_count">>, public),
            class_attr(<<"conn_id">>, private)
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
    Pass = vget_pass(Pass0, <<"mysqli.default_pw">>),
    Port = vget_int(Port0, <<"mysqli.default_port">>),
    _Socket = vget_str(Socket0, <<"mysqli.default_socket">>),
    DB = binary_to_list(DB0),
    LogFun = fun(_Level, _Format, _Args) -> ok end,
    case p1_mysql_conn:start_link(Host, Port, User, Pass, DB, LogFun) of
        {ok, PID} ->
            HostInfo = <<(list_to_binary(Host))/binary, " via TCP/IP">>,
            ClassCtx = ephp_object:get_context(ObjRef),
            ephp_context:set(ClassCtx, #variable{name = <<"conn_id">>}, PID),
            ephp_context:set(ClassCtx, #variable{name = <<"host_info">>}, HostInfo),
            ok;
        _ ->
            undefined
    end.

mysqli_destruct(_Context, ObjRef, _Line, []) ->
    ClassCtx = ephp_object:get_context(ObjRef),
    ConnId = ephp_context:get(ClassCtx, #variable{name = <<"conn_id">>}),
    p1_mysql_conn:stop(ConnId),
    ok.

-spec mysqli_connect(context(), line(), var_value(),
                                        var_value(),
                                        var_value(),
                                        var_value(),
                                        var_value(),
                                        var_value()) -> undefined | obj_ref().

mysqli_connect(Context, Line, {_, Host}, {_, User}, {_, Pass}, {_, DB},
                              {_, Port}, {_, Socket}) ->
    Classes = ephp_context:get_classes(Context),
    MySQLi = ephp_class:instance(Classes, Context, Context, <<"mysqli">>, Line),
    #ephp_object{class = Class} = ephp_object:get(MySQLi),
    #class_method{name = ConstructorName} =
        ephp_class:get_constructor(Classes, Class),
    Call = #call{type = object,
                 name = ConstructorName,
                 args = [Host, User, Pass, DB, Port, Socket],
                 line = Line},
    case ephp_context:call_method(Context, MySQLi, Call) of
        ok ->
            MySQLi;
        undefined ->
            ephp_object:destroy(Context, MySQLi),
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

% gen_id(Host, User, Pass, Port, Socket) ->
%     String = <<Host/binary, User/binary, Pass/binary, Port:16, Socket/binary>>,
%     <<A:128>> = crypto:hash(md5, String),
%     integer_to_binary(A, 16).

-spec mysqli_get_host_info(context(), line(), var_value()) -> binary().

mysqli_get_host_info(_Context, _Line, {_, ObjRef}) ->
    ClassCtx = ephp_object:get_context(ObjRef),
    ephp_context:get(ClassCtx, #variable{name = <<"host_info">>}).

-spec mysqli_close(context(), line(), var_value()) -> undefined.

mysqli_close(Context, _Line, {_, Id}) ->
    ok = ephp_object:remove(Context, Id),
    undefined.
