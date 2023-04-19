defmodule YeccTest do
  use ExUnit.Case
  doctest Yecc

  test "operator parser" do
    check('7*2 + 1', [15])
    check('1 + 7*2 ', [15])
    check('(1 + 7)*2 ', [16])
    check('(1 + (7 - 2))*2 ', [12])
    check('(1 + (7 - 2))*2 \n1+1\r89*1', [12,2, 89])
    check('-(1 + (7 - 2))*2 ', [-12])
    check('-(1.1 + (7 - 2))*2 ', [-12.2])
    check('-(1.1 + (7 - 2))*-2 ', [12.2])
    check('-(1.1 + (7 - 2))*-2 + 1 + (1+1+(1-1))', [15.2])
    check('-(6)*-2+1', [13])
    check('(6)*-2+1', [-11])
    assert Yecc.hello() == :world
  end
  def check(str, number) do
    {:ok, token, _ }= :first_leex.string(str)
    {:ok, number1} = :first_yecc.parse(token)
    assert number1 == number
    end
end
