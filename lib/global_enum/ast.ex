defmodule GlobalEnum.Ast do
  def define_function_with_spec_and_doc(%{name: name, return: return, doc: doc, meta: meta}) do
    {:__block__, [],
     [
       {:@, meta, [{:doc, meta, [doc]}]},
       {:@, meta, [{:spec, meta, [{:"::", meta, [{name, meta, []}, term_to_type(return, meta)]}]}]},
       {:def, meta, [{name, meta, []}, [do: Macro.escape(return)]]}
     ]}
  end

  @doc """
  Used for type specs, takes a list of types and returns the ast type equivalent

  ## Example
      iex> GlobalEnum.Ast.type_list_to_type([:value_1], [line: 1])
      :value_1

      iex> GlobalEnum.Ast.type_list_to_type([:value_1, :value_2, :value_3], [line: 1])
      {:|, [line: 1], [:value_1, {:|, [line: 1], [:value_2, :value_3]}]}

  """
  def type_list_to_type([_ | _] = values, meta) do
    # reversing the list initially preserve order after the ast is built
    [hd | tl] =
      values
      |> Enum.uniq()
      |> Enum.reverse()

    Enum.reduce(tl, hd, fn value, acc -> {:|, meta, [value, acc]} end)
  end

  @doc """
  Takes a supported term and converts to Ast represent of the type of that term.

  ## Example
      iex> GlobalEnum.Ast.term_to_type(:foo, [])
      :foo

      iex> GlobalEnum.Ast.term_to_type([:foo, :bar], [])
      [{:|, [], [:foo, :bar]}]

      iex> GlobalEnum.Ast.term_to_type(%{"foo" => :bar}, [])
      {:%{}, [], [{{:binary, [], []}, :bar}]}
  """
  def term_to_type(term, meta) when is_binary(term), do: {:binary, meta, []}
  def term_to_type(term, meta) when is_integer(term), do: {:integer, meta, []}
  def term_to_type(term, _meta) when is_atom(term), do: term
  def term_to_type({key, value}, meta), do: {term_to_type(key, meta), term_to_type(value, meta)}
  def term_to_type([], _meta), do: []

  def term_to_type([_ | _] = term, meta) do
    term
    |> Enum.map(&term_to_type(&1, meta))
    |> Enum.uniq()
    |> type_list_to_type(meta)
    |> (&[&1]).()
  end

  def term_to_type(%{} = term, meta) do
    term
    |> Map.to_list()
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      key_type = term_to_type(key, meta)
      value_type = term_to_type(value, meta)

      Map.update(acc, key_type, [value_type], &[value_type | &1])
    end)
    |> Enum.map(fn {key_type, value_types} -> {key_type, type_list_to_type(value_types, meta)} end)
    |> Enum.sort(fn a, b -> :erlang.phash2(a) >= :erlang.phash2(b) end)
    |> (&{:%{}, meta, &1}).()
  end

  def define_type(name, doc, type_ast, meta \\ []) do
    {:__block__, [],
     [
       {:@, meta, [{:typedoc, meta, [doc]}]},
       {:@, meta, [{:type, meta, [{:"::", meta, [{name, meta, nil}, type_ast]}]}]}
     ]}
  end

  # TODO: create eject task
  def ast_to_string(ast) do
    ast
    |> Code.quoted_to_algebra()
    |> Inspect.Algebra.format(:infinity)
    |> IO.iodata_to_binary()
  end
end
