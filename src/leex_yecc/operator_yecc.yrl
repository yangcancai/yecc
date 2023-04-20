Header "%% Copyright (C)"
"%% @private"
"%% @Author Cam".
Nonterminals root result const elements element.
Terminals number '+' '-' '*' '/' '(' ')' '\n' float.

Rootsymbol root.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.
root -> elements: '$1'.
elements -> element: ['$1'].
elements -> element elements: ['$1' | '$2'].
element -> result: '$1'.
element -> result '\n': '$1'.
result -> '-' '(' result ')': -value_of('$3').
result -> '(' result ')': '$2'.
result -> result result: add('$1', '$2').
result -> result '+' result: add('$1', '$3').
result -> result '*' result: mutpl('$1', '$3').
result -> result '-' result: sub('$1', '$3').
result -> result '/' result: chu('$1', '$3').
result -> const : '$1'.
const -> number: '$1'.
const -> float: '$1'.

Erlang code.
add(A, B) ->
   value_of(A) + value_of(B).
sub(A, B) ->
  value_of(A) - value_of(B).
chu(A, B)   ->
   value_of(A) / value_of(B).
mutpl(A, B)    ->
    value_of(A) * value_of(B).
value_of({_, _, V}) -> V;
value_of(V) -> V.