-module(ephp_mysql).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-include_lib("ephp/include/ephp.hrl").

-export([main/1]).

-spec main(Args :: [string()]) -> integer().

main([Filename|_] = RawArgs) ->
    ephp:start(),
    case file:read_file(Filename) of
    {ok, Content} ->
        AbsFilename = list_to_binary(filename:absname(Filename)),
        ephp_config:start_link(?PHP_INI_FILE),
        {ok, Ctx} = ephp:context_new(AbsFilename),
        ephp:register_superglobals(Ctx, RawArgs),
        case ephp:eval(AbsFilename, Ctx, Content) of
            {ok, _Return} ->
                Result = ephp_context:get_output(Ctx),
                io:format("~s", [Result]),
                ephp_context:destroy_all(Ctx),
                quit(0);
            {error, _Reason} ->
                quit(1)
        end;
    {error, enoent} ->
        io:format("File not found: ~s~n", [Filename]),
        quit(2);
    {error, Reason} ->
        io:format("Error: ~p~n", [Reason]),
        quit(3)
    end;

main(_) ->
    io:format("Usage: ephp <file.php>~n", []),
    quit(1).

-ifndef(TEST).
-spec quit(integer()) -> no_return().
quit(Code) ->
    erlang:halt(Code).
-else.
-spec quit(integer()) -> integer().
quit(Code) ->
    Code.
-endif.
