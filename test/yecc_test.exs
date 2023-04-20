defmodule YeccTest do
  use ExUnit.Case
  doctest Yecc

  test "sui parser" do
    sui_scripts = """
       # create a sui-address
        sui client new-address
        sui client new-address e2519r
        sui client gas
      sui client transfer-sui --to 0x313c133acaf25103aae40544003195e1a3bb7d5b2b11fd4c6ec61af16bcdb968 --sui-coin-object-id 0x3a5f70f0bedb661f1e8bc596e308317edb0bdccc5bc86207b45f01db1aad5ddf --gas-budget 2000
    sui client call --function buy_ham --module sandwich --package 0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8 --args args1 args2 --gas gas_obj --gas-budget 30000
      a = b
      case a do
          true -> :ok
          false -> :error
        end
      a
      |>
      b
    assert a == 1
                sui client new-address e2519r
    """

    check_sui(sui_scripts, [
      %{'cli' => 'comment', 'line' => '   # create a sui-address'},
      %{'args' => [], 'cli' => 'sui_client', 'cmd' => 'new-address'},
      %{'args' => ['e2519r'], 'cli' => 'sui_client', 'cmd' => 'new-address'},
      %{'cli' => 'sui_client', 'cmd' => 'gas'},
      %{
        'cli' => 'sui_client',
        'cmd' => 'transfer-sui',
        'gas-budget' => ['2000'],
        'sui-coin-object-id' => [
          '0x3a5f70f0bedb661f1e8bc596e308317edb0bdccc5bc86207b45f01db1aad5ddf'
        ],
        'to' => ['0x313c133acaf25103aae40544003195e1a3bb7d5b2b11fd4c6ec61af16bcdb968']
      },
      %{
        'args' => ['args1', 'args2'],
        'cli' => 'sui_client',
        'cmd' => 'call',
        'function' => ['buy_ham'],
        'gas' => ['gas_obj'],
        'gas-budget' => ['30000'],
        'module' => ['sandwich'],
        'package' => ['0x08204ed92afcfdf9d0f6727a2c7d40db93a059d8']
      },
      %{'cli' => 'code', 'line' => '  a = b'},
      %{'cli' => 'code', 'line' => '  case a do'},
      %{'cli' => 'code', 'line' => '      true -> :ok'},
      %{'cli' => 'code', 'line' => '      false -> :error'},
      %{'cli' => 'code', 'line' => '    end'},
      %{'cli' => 'code', 'line' => '  a'},
      %{'cli' => 'code', 'line' => '  |>'},
      %{'cli' => 'code', 'line' => '  b'},
      %{'cli' => 'code', 'line' => 'assert a == 1'},
      %{'args' => ['e2519r'], 'cli' => 'sui_client', 'cmd' => 'new-address'}
    ])
  end

  def check_sui(str, expected) do
    {:ok, token, _} = :sui_leex.string(String.to_charlist(str))
    {:ok, {res, code}} = :sui_yecc.parse(token)
    code = :re.replace(code, "\#{", "%{", [:global, {:return, :list}])
    :file.write_file("a.ex", code)
    #    assert List.to_string(code) == :ok
    assert expected == res
  end

  test "operator parser" do
    check('7*2 + 1', [15])
    check('1 + 7*2 ', [15])
    check('(1 + 7)*2 ', [16])
    check('(1 + (7 - 2))*2 ', [12])
    check('(1 + (7 - 2))*2 \n1+1\r89*1', [12, 2, 89])
    check('-(1 + (7 - 2))*2 ', [-12])
    check('-(1.1 + (7 - 2))*2 ', [-12.2])
    check('-(1.1 + (7 - 2))*-2 ', [12.2])
    check('-(1.1 + (7 - 2))*-2 + 1 + (1+1+(1-1))', [15.2])
    check('-(6)*-2+1', [13])
    check('(6)*-2+1', [-11])
    assert Yecc.hello() == :world
  end

  test "Erlang scan and parse" do
    module = """
      A = {(1+2+3)*4},
      C = lists:seq(1,10),
      D = operator_leex:string("1+2"),
      E = 'Elixir.Yecc':hello(),
      {A, b, C, D, E}.
    """

    {:ok, tokens, _} = :erl_scan.string(:erlang.binary_to_list(module))
    {:ok, parsed} = :erl_parse.parse_exprs(tokens)
    {:value, value, _} = :erl_eval.exprs(parsed, [])

    assert value ==
             {{24}, :b, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
              {:ok, [{:number, 1, 1}, {:number, 1, 2}], 1}, :world}
  end

  def check(str, number) do
    {:ok, token, _} = :operator_leex.string(str)
    {:ok, number1} = :operator_yecc.parse(token)
    assert number1 == number
  end
end
