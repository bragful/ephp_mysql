-module(ephp_mysql).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-export([main/1]).

-spec main(Args :: [string()]) -> integer().

main(Args) ->
    ephp:main(Args).
