-module(ephp_lib_mysqli).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,

    mysqli_connect/3,
    mysqli_close/3
]).

-include_lib("ephp/include/ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    % mysqli_connect ([ string $host = ini_get("mysqli.default_host")
    %                 [, string $username = ini_get("mysqli.default_user")
    %                 [, string $passwd = ini_get("mysqli.default_pw")
    %                 [, string $dbname = ""
    %                 [, int $port = ini_get("mysqli.default_port")
    %                 [, string $socket = ini_get("mysqli.default_socket") ]]]]]] )
    {mysqli_connect, [pack_args,
                      {args, 0, 6, undefined, [{string, undefined},
                                               {string, undefined},
                                               {string, undefined},
                                               {string, <<>>},
                                               {integer, undefined},
                                               {string, undefined}]}]},
    {mysqli_close, [resource]}
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

-spec mysqli_connect(context(), line(), var_value()) -> undefined | pid().

mysqli_connect(_Context, _Line, [{_, Host0}, {_, User0}, {_, Pass0}, {_, DB},
                                 {_, Port0}, {_, Socket0}]) ->
    Host = vget(Host0, "mysqli.default_host"),
    User = vget(User0, "mysqli.default_user"),
    Pass = vget(Pass0, "mysqli.default_pw"),
    Port = vget(Port0, "mysqli.default_port"),
    _Socket = vget(Socket0, "mysqli.default_socket"),
    {ok, PID} = p1_mysql_conn:start_link(Host, Port, User, Pass, DB, undefined),
    PID.

vget(undefined, Key) -> ephp_config:get(Key);
vget(Value, _Key) -> Value.

% gen_id(Host, User, Pass, Port, Socket) ->
%     String = <<Host/binary, User/binary, Pass/binary, Port:16, Socket/binary>>,
%     <<A:128>> = crypto:hash(md5, String),
%     integer_to_binary(A, 16).

-spec mysqli_close(context(), line(), var_value()) -> undefined.

mysqli_close(_Context, _Line, [{_, Id}]) ->
    %% FIXME: we should to disconnect only
    p1_mysql_conn:stop(Id).
