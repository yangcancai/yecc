%% a operator leex
Definitions.
Number = [0-9]+
Float = (\+|-)?{D}\.{D}((E|e)(\+|-)?[0-9]+)?
Space = [\t\s]*
Return = [\r\n]+
NoneLine = {Space}[\r\n]*
Atom = [a-z][0-9a-zA-Z_]*
SuiLine = {Space}sui[\s]+client.+
Comment = {Space}#.+
Code = .*
Rules.

{SuiLine} : {token,{sui, TokenLine, parse_sui(TokenChars)}}.
{Comment} : {token, {comment, TokenLine, parse_comment(TokenChars)}}.
{NoneLine} : skip_token.
%{Return} : {token, {'\n', TokenLine, :nil}}.
{Return} : skip_token.
{Code} : {token, {code, TokenLine, parse_code(TokenChars)}}.

Erlang code.
parse_comment(CommentLine) ->
    #{"cli" => "comment", "line" => CommentLine}.
parse_code(CodeLine) ->
    #{"cli" => "code", "line" => CodeLine}.

parse_sui(SuiLine) ->
 {match, List} = re:run(SuiLine, "[0-9a-z_-]+",[global,{capture,all,binary}]),
 [_Sui, _Client, Method | Rest] = lists:flatten(List),
 parse_sui(Method, Rest).
parse_sui(<<"new-address">> = Method, Args) ->
     #{"cli" => "sui_client", "cmd" => erlang:binary_to_list(Method), "args" => [erlang:binary_to_list(R) || R <- Args]};
parse_sui(Method, Rest)  ->
 do_parse_sui(Rest, #{"cli" => "sui_client", "cmd" => Method}).
do_parse_sui([], Acc) ->
  Acc;
do_parse_sui([<<"--", H/binary>> | Rest], Acc) ->
 do_parse_sui({H, []}, Rest, Acc).

do_parse_sui({Key, Value}, [], Acc) ->
  append_key_value({Key, Value}, Acc);
do_parse_sui({Key, Value}, [<<"--", _/binary>> | _] = List, Acc) ->
    do_parse_sui(List, append_key_value({Key, Value}, Acc));
do_parse_sui({Key,Value}, [H | Rest], Acc) ->
  do_parse_sui({Key, [erlang:binary_to_list(H) | Value]}, Rest, Acc).

append_key_value({Key, Value}, Acc)   ->
Acc#{erlang:binary_to_list(Key) => lists:reverse(Value)}.
