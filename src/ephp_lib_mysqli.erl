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
    mysqli_query/5,
    mysqli_close/3,

    mysqli_fetch_lengths/3,
    mysqli_fetch_all/4,
    mysqli_data_seek/4
]).

-include_lib("ephp/include/ephp.hrl").
-include("ephp_mysql.hrl").

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
    {mysqli_query, [{args, {2, 3, undefined, [object,
                                              string,
                                              {integer, ?MYSQLI_STORE_RESULT}]}}]},
    {mysqli_close, [object]},
    {mysqli_fetch_lengths, [object]},
    {mysqli_fetch_all, [{args, {1, 2, undefined, [object,
                                                  {integer, ?MYSQLI_NUM}]}}]},
    {mysqli_data_seek, [object, integer]}
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

init_const() -> [
    {<<"MYSQLI_READ_DEFAULT_GROUP">>, ?MYSQLI_READ_DEFAULT_GROUP},
    {<<"MYSQLI_READ_DEFAULT_FILE">>, ?MYSQLI_READ_DEFAULT_FILE},
    {<<"MYSQLI_OPT_CONNECT_TIMEOUT">>, ?MYSQLI_OPT_CONNECT_TIMEOUT},
    {<<"MYSQLI_OPT_LOCAL_INFILE">>, ?MYSQLI_OPT_LOCAL_INFILE},
    {<<"MYSQLI_INIT_COMMAND">>, ?MYSQLI_INIT_COMMAND},
    {<<"MYSQLI_CLIENT_SSL">>, ?MYSQLI_CLIENT_SSL},
    {<<"MYSQLI_CLIENT_COMPRESS">>, ?MYSQLI_CLIENT_COMPRESS},
    {<<"MYSQLI_CLIENT_INTERACTIVE">>, ?MYSQLI_CLIENT_INTERACTIVE},
    {<<"MYSQLI_CLIENT_IGNORE_SPACE">>, ?MYSQLI_CLIENT_IGNORE_SPACE},
    {<<"MYSQLI_CLIENT_NO_SCHEMA">>, ?MYSQLI_CLIENT_NO_SCHEMA},
    {<<"MYSQLI_STORE_RESULT">>, ?MYSQLI_STORE_RESULT},
    {<<"MYSQLI_USE_RESULT">>, ?MYSQLI_USE_RESULT},
    {<<"MYSQLI_ASSOC">>, ?MYSQLI_ASSOC},
    {<<"MYSQLI_NUM">>, ?MYSQLI_NUM},
    {<<"MYSQLI_BOTH">>, ?MYSQLI_BOTH},
    {<<"MYSQLI_NOT_NULL_FLAG">>, ?MYSQLI_NOT_NULL_FLAG},
    {<<"MYSQLI_PRI_KEY_FLAG">>, ?MYSQLI_PRI_KEY_FLAG},
    {<<"MYSQLI_UNIQUE_KEY_FLAG">>, ?MYSQLI_UNIQUE_KEY_FLAG},
    {<<"MYSQLI_MULTIPLE_KEY_FLAG">>, ?MYSQLI_MULTIPLE_KEY_FLAG},
    {<<"MYSQLI_BLOB_FLAG">>, ?MYSQLI_BLOB_FLAG},
    {<<"MYSQLI_UNSIGNED_FLAG">>, ?MYSQLI_UNSIGNED_FLAG},
    {<<"MYSQLI_ZEROFILL_FLAG">>, ?MYSQLI_ZEROFILL_FLAG},
    {<<"MYSQLI_AUTO_INCREMENT_FLAG">>, ?MYSQLI_AUTO_INCREMENT_FLAG},
    {<<"MYSQLI_TIMESTAMP_FLAG">>, ?MYSQLI_TIMESTAMP_FLAG},
    {<<"MYSQLI_SET_FLAG">>, ?MYSQLI_SET_FLAG},
    {<<"MYSQLI_NUM_FLAG">>, ?MYSQLI_NUM_FLAG},
    {<<"MYSQLI_PART_KEY_FLAG">>, ?MYSQLI_PART_KEY_FLAG},
    {<<"MYSQLI_GROUP_FLAG">>, ?MYSQLI_GROUP_FLAG},
    {<<"MYSQLI_TYPE_DECIMAL">>, ?MYSQLI_TYPE_DECIMAL},
    {<<"MYSQLI_TYPE_NEWDECIMAL">>, ?MYSQLI_TYPE_NEWDECIMAL},
    {<<"MYSQLI_TYPE_BIT">>, ?MYSQLI_TYPE_BIT},
    {<<"MYSQLI_TYPE_TINY">>, ?MYSQLI_TYPE_TINY},
    {<<"MYSQLI_TYPE_SHORT">>, ?MYSQLI_TYPE_SHORT},
    {<<"MYSQLI_TYPE_LONG">>, ?MYSQLI_TYPE_LONG},
    {<<"MYSQLI_TYPE_FLOAT">>, ?MYSQLI_TYPE_FLOAT},
    {<<"MYSQLI_TYPE_DOUBLE">>, ?MYSQLI_TYPE_DOUBLE},
    {<<"MYSQLI_TYPE_NULL">>, ?MYSQLI_TYPE_NULL},
    {<<"MYSQLI_TYPE_TIMESTAMP">>, ?MYSQLI_TYPE_TIMESTAMP},
    {<<"MYSQLI_TYPE_LONGLONG">>, ?MYSQLI_TYPE_LONGLONG},
    {<<"MYSQLI_TYPE_INT24">>, ?MYSQLI_TYPE_INT24},
    {<<"MYSQLI_TYPE_DATE">>, ?MYSQLI_TYPE_DATE},
    {<<"MYSQLI_TYPE_TIME">>, ?MYSQLI_TYPE_TIME},
    {<<"MYSQLI_TYPE_DATETIME">>, ?MYSQLI_TYPE_DATETIME},
    {<<"MYSQLI_TYPE_YEAR">>, ?MYSQLI_TYPE_YEAR},
    {<<"MYSQLI_TYPE_NEWDATE">>, ?MYSQLI_TYPE_NEWDATE},
    {<<"MYSQLI_TYPE_INTERVAL">>, ?MYSQLI_TYPE_INTERVAL},
    {<<"MYSQLI_TYPE_ENUM">>, ?MYSQLI_TYPE_ENUM},
    {<<"MYSQLI_TYPE_SET">>, ?MYSQLI_TYPE_SET},
    {<<"MYSQLI_TYPE_TINY_BLOB">>, ?MYSQLI_TYPE_TINY_BLOB},
    {<<"MYSQLI_TYPE_MEDIUM_BLOB">>, ?MYSQLI_TYPE_MEDIUM_BLOB},
    {<<"MYSQLI_TYPE_LONG_BLOB">>, ?MYSQLI_TYPE_LONG_BLOB},
    {<<"MYSQLI_TYPE_BLOB">>, ?MYSQLI_TYPE_BLOB},
    {<<"MYSQLI_TYPE_VAR_STRING">>, ?MYSQLI_TYPE_VAR_STRING},
    {<<"MYSQLI_TYPE_STRING">>, ?MYSQLI_TYPE_STRING},
    {<<"MYSQLI_TYPE_CHAR">>, ?MYSQLI_TYPE_CHAR},
    {<<"MYSQLI_TYPE_GEOMETRY">>, ?MYSQLI_TYPE_GEOMETRY},
    {<<"MYSQLI_NO_DATA">>, ?MYSQLI_NO_DATA},
    {<<"MYSQLI_DATA_TRUNCATED">>, ?MYSQLI_DATA_TRUNCATED},
    {<<"MYSQLI_ENUM_FLAG">>, ?MYSQLI_ENUM_FLAG},
    {<<"MYSQLI_BINARY_FLAG">>, ?MYSQLI_BINARY_FLAG},
    {<<"MYSQLI_CURSOR_TYPE_FOR_UPDATE">>, ?MYSQLI_CURSOR_TYPE_FOR_UPDATE},
    {<<"MYSQLI_CURSOR_TYPE_NO_CURSOR">>, ?MYSQLI_CURSOR_TYPE_NO_CURSOR},
    {<<"MYSQLI_CURSOR_TYPE_READ_ONLY">>, ?MYSQLI_CURSOR_TYPE_READ_ONLY},
    {<<"MYSQLI_CURSOR_TYPE_SCROLLABLE">>, ?MYSQLI_CURSOR_TYPE_SCROLLABLE},
    {<<"MYSQLI_STMT_ATTR_CURSOR_TYPE">>, ?MYSQLI_STMT_ATTR_CURSOR_TYPE},
    {<<"MYSQLI_STMT_ATTR_PREFETCH_ROWS">>, ?MYSQLI_STMT_ATTR_PREFETCH_ROWS},
    {<<"MYSQLI_STMT_ATTR_UPDATE_MAX_LENGTH">>, ?MYSQLI_STMT_ATTR_UPDATE_MAX_LENGTH},
    {<<"MYSQLI_SET_CHARSET_NAME">>, ?MYSQLI_SET_CHARSET_NAME},
    {<<"MYSQLI_REPORT_INDEX">>, ?MYSQLI_REPORT_INDEX},
    {<<"MYSQLI_REPORT_ERROR">>, ?MYSQLI_REPORT_ERROR},
    {<<"MYSQLI_REPORT_STRICT">>, ?MYSQLI_REPORT_STRICT},
    {<<"MYSQLI_REPORT_ALL">>, ?MYSQLI_REPORT_ALL},
    {<<"MYSQLI_REPORT_OFF">>, ?MYSQLI_REPORT_OFF},
    {<<"MYSQLI_DEBUG_TRACE_ENABLED">>, ?MYSQLI_DEBUG_TRACE_ENABLED},
    {<<"MYSQLI_SERVER_QUERY_NO_GOOD_INDEX_USED">>, ?MYSQLI_SERVER_QUERY_NO_GOOD_INDEX_USED},
    {<<"MYSQLI_SERVER_QUERY_NO_INDEX_USED">>, ?MYSQLI_SERVER_QUERY_NO_INDEX_USED},
    {<<"MYSQLI_REFRESH_GRANT">>, ?MYSQLI_REFRESH_GRANT},
    {<<"MYSQLI_REFRESH_LOG">>, ?MYSQLI_REFRESH_LOG},
    {<<"MYSQLI_REFRESH_TABLES">>, ?MYSQLI_REFRESH_TABLES},
    {<<"MYSQLI_REFRESH_HOSTS">>, ?MYSQLI_REFRESH_HOSTS},
    {<<"MYSQLI_REFRESH_STATUS">>, ?MYSQLI_REFRESH_STATUS},
    {<<"MYSQLI_REFRESH_THREADS">>, ?MYSQLI_REFRESH_THREADS},
    {<<"MYSQLI_REFRESH_SLAVE">>, ?MYSQLI_REFRESH_SLAVE},
    {<<"MYSQLI_REFRESH_MASTER">>, ?MYSQLI_REFRESH_MASTER},
    {<<"MYSQLI_TRANS_COR_AND_CHAIN">>, ?MYSQLI_TRANS_COR_AND_CHAIN},
    {<<"MYSQLI_TRANS_COR_AND_NO_CHAIN">>, ?MYSQLI_TRANS_COR_AND_NO_CHAIN},
    {<<"MYSQLI_TRANS_COR_RELEASE">>, ?MYSQLI_TRANS_COR_RELEASE},
    {<<"MYSQLI_TRANS_COR_NO_RELEASE">>, ?MYSQLI_TRANS_COR_NO_RELEASE},
    {<<"MYSQLI_TRANS_START_READ_ONLY">>, ?MYSQLI_TRANS_START_READ_ONLY},
    {<<"MYSQLI_TRANS_START_READ_WRITE">>, ?MYSQLI_TRANS_START_READ_WRITE}
].

-spec get_classes() -> [class()].

get_classes() ->
    ephp_class_mysqli:get_classes() ++
    ephp_class_mysqli_result:get_classes().

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

-spec mysqli_get_host_info(context(), line(), var_value()) -> binary().

mysqli_get_host_info(_Context, _Line, {_, ObjRef}) ->
    ClassCtx = ephp_object:get_context(ObjRef),
    ephp_context:get(ClassCtx, #variable{name = <<"host_info">>}).

-spec mysqli_query(context(), line(), var_value(),
                                      var_value(),
                                      var_value()) -> mixed().

mysqli_query(Context, Line, {_, ObjRef}, {_, Query}, {_, ResMode}) ->
    Call = #call{type = object,
                 name = <<"query">>,
                 args = [Query, ResMode],
                 line = Line},
    ephp_context:call_method(Context, ObjRef, Call).

-spec mysqli_close(context(), line(), var_value()) -> undefined.

mysqli_close(Context, _Line, {_, Id}) ->
    ok = ephp_object:remove(Context, Id),
    undefined.

-spec mysqli_fetch_lengths(context(), line(), var_value()) -> ephp_array().

mysqli_fetch_lengths(_Context, _Line, {_, ObjRef}) ->
    ObjCtx = ephp_object:get_context(ObjRef),
    ephp_context:get(ObjCtx, #variable{name = <<"lenghts">>}).

-spec mysqli_fetch_all(context(), line(), var_value(), var_value()) -> mixed().

mysqli_fetch_all(Context, Line, {_, ObjRef}, {_, ResMode}) ->
    Call = #call{type = object,
                 name = <<"fetch_all">>,
                 args = [ResMode],
                 line = Line},
    ephp_context:call_method(Context, ObjRef, Call).

-spec mysqli_data_seek(context(), line(), var_value(), var_value()) -> boolean().

mysqli_data_seek(Context, Line, {_, ObjRef}, {_, Offset}) ->
    Call = #call{type = object,
                 name = <<"data_seek">>,
                 args = [Offset],
                 line = Line},
    ephp_context:call_method(Context, ObjRef, Call).
