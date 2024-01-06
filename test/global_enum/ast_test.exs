defmodule GlobalEnum.AstTest do
  use ExUnit.Case

  @test_meta [line: 1]

  doctest GlobalEnum.Ast

  describe "term_to_type/2" do
    test "with binary" do
      assert {:binary, [line: 1], []} == GlobalEnum.Ast.term_to_type("foo", @test_meta)
    end

    test "with atom" do
      assert :foo == GlobalEnum.Ast.term_to_type(:foo, @test_meta)
    end

    test "with integer" do
      result = GlobalEnum.Ast.term_to_type(1, @test_meta)
      assert {:integer, [line: 1], []} == result
      assert "integer()" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with list of binary" do
      result = GlobalEnum.Ast.term_to_type(["foo", "bar"], @test_meta)
      assert [{:binary, [line: 1], []}] == result
      assert "[binary()]" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with list of atoms" do
      result = GlobalEnum.Ast.term_to_type([:foo, :bar], @test_meta)
      assert [{:|, [line: 1], [:foo, :bar]}] == result
      assert "[:foo | :bar]" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with list of integers" do
      result = GlobalEnum.Ast.term_to_type([1, 2], @test_meta)
      assert [{:integer, [line: 1], []}] == result
      assert "[integer()]" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with mixed list" do
      result = GlobalEnum.Ast.term_to_type([:foo, "bar", 1], @test_meta)
      assert [{:|, [line: 1], [:foo, {:|, [line: 1], [{:binary, [line: 1], []}, {:integer, [line: 1], []}]}]}] == result
      assert "[:foo | binary() | integer()]" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with map of atom:binary" do
      result = GlobalEnum.Ast.term_to_type(%{foo: "bar"}, @test_meta)
      assert {:%{}, [line: 1], [foo: {:binary, [line: 1], []}]} == result
      assert "%{foo: binary()}" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with map of binary:atom" do
      result = GlobalEnum.Ast.term_to_type(%{"foo" => :bar}, @test_meta)
      assert {:%{}, [line: 1], [{{:binary, [line: 1], []}, :bar}]} == result
      assert "%{binary() => :bar}" == GlobalEnum.Ast.ast_to_string(result)
    end

    test "with mixed types" do
      map = %{
        :foo => "bar",
        "foo" => :bar,
        :fiz => 1,
        2 => "buz"
      }

      result = GlobalEnum.Ast.term_to_type(map, @test_meta)

      assert {:%{}, [line: 1],
              [
                {:fiz, {:integer, [line: 1], []}},
                {:foo, {:binary, [line: 1], []}},
                {{:integer, [line: 1], []}, {:binary, [line: 1], []}},
                {{:binary, [line: 1], []}, :bar}
              ]} == result

      assert "%{:fiz => integer(), :foo => binary(), integer() => binary(), binary() => :bar}" ==
               GlobalEnum.Ast.ast_to_string(result)
    end

    test "with duplicate types" do
      map = %{
        "fiz" => "bar",
        "foo" => :bar,
        1 => 2,
        2 => "qiz",
        3 => "baz",
        4 => :quz
      }

      result = GlobalEnum.Ast.term_to_type(map, @test_meta)

      assert {:%{}, [line: 1],
              [
                {{:integer, [line: 1], []},
                 {:|, [line: 1], [:quz, {:|, [line: 1], [{:binary, [line: 1], []}, {:integer, [line: 1], []}]}]}},
                {{:binary, [line: 1], []}, {:|, [line: 1], [:bar, {:binary, [line: 1], []}]}}
              ]} == result

      assert "%{integer() => :quz | binary() | integer(), binary() => :bar | binary()}" ==
               GlobalEnum.Ast.ast_to_string(result)
    end
  end
end
