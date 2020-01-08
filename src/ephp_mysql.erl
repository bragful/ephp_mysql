-module(ephp_mysql).
-author('manuel@altenwald.com').

-export([main/1]).

-spec main(Args :: [string()]) -> integer().

main(Args) ->
    ephp:main(Args).
