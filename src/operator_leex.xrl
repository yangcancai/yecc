%% a operator leex
Definitions.
D = [0-9]+
Other = [a-z]
Space = [\t\s]*
Return = [\r\n]+
NoneLine = {Space}[\r\n]*
Float = (\+|-)?{D}\.{D}((E|e)(\+|-)?[0-9]+)?
Rules.

(\+|-)?{D} :
   {token, {number, TokenLine, list_to_integer(TokenChars)}}.
{Float}   :
   {token, {float, TokenLine, list_to_float(TokenChars)}}.
[a-z]* :
    skip_token.
{Space} : skip_token.
[+] : {token, {'+', TokenLine, TokenChars}}.
[-] : {token, {'-', TokenLine, TokenChars}}.
[*] : {token, {'*', TokenLine, TokenChars}}.
[/] : {token, {'/', TokenLine, TokenChars}}.
[(] : {token, {'(', TokenLine, TokenChars}}.
[)] : {token, {')', TokenLine, TokenChars}}.
%% 回车
{NoneLine} :
     {token, {'\n', TokenLine, TokenChars}}.
{Return} : skip_token.
Erlang code.
