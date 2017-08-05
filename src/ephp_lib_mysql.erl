-module(ephp_lib_mysql).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,

    mysql_connect/3
]).

-include_lib("ephp/include/ephp.hrl").
-include("ephp_mysql.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {mysql_connect, [pack_args, {args, [string]}]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [].

-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

-spec mysql_connect(context(), line(), var_value()) -> undefined | pid().

mysql_connect(_Context, _Line, _Vars) ->
    undefined.
