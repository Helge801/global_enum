defmodule GlobalEnum.Build do
  @moduledoc false

  defmacro define_values_guard(name) do
    quote bind_quoted: [name: name] do
      # define guard for enum type
      @doc """
      Guard clause checking that the given value is part of the #{name} Enum.
      ```
      when value in #{inspect(Module.get_attribute(__MODULE__, :"#{name}"))}
      ```
      """
      Module.eval_quoted(
        __MODULE__,
        {:defguard, @ge_meta,
         [
           {:when, @ge_meta,
            [
              {:"is_#{name}_enum_value", @ge_meta, [{:value, @ge_meta, nil}]},
              {:in, @ge_meta, [{:value, @ge_meta, nil}, {:@, @ge_meta, [{:"#{name}", @ge_meta, nil}]}]}
            ]}
         ]}
      )
    end
  end

  defmacro define_value_guards(name) do
    quote bind_quoted: [name: name] do
      __MODULE__
      |> Module.get_attribute(:"#{name}")
      |> Enum.each(
        &Module.eval_quoted(
          __MODULE__,
          [
            {:@, @ge_meta,
             [
               {:doc, @ge_meta,
                [
                  "Guard checking that the given value is equal to the `#{&1}` value of the `#{name}` enum. Specifically\n```\n defguard is_#{name}_#{&1}(value) when value == :#{&1}\n```"
                ]}
             ]},
            {:defguard, @ge_meta,
             [
               {:when, @ge_meta,
                [
                  {:"is_#{name}_#{&1}", @ge_meta, [{:value, @ge_meta, nil}]},
                  {:==, @ge_meta, [{:value, @ge_meta, nil}, &1]}
                ]}
             ]}
          ]
        )
      )
    end
  end

  defmacro define_enum_function(name) do
    quote bind_quoted: [name: name] do
      enum = Module.get_attribute(__MODULE__, :"#{name}_enum")

      Module.eval_quoted(
        __MODULE__,
        GlobalEnum.Ast.define_function_with_spec_and_doc(%{
          name: :"#{name}_enum",
          return: enum,
          doc: """
          Returns `:#{name}` enum as a keyword list.
          ```
          #{GlobalEnum.Docs.format_list(enum)}
          ```
          """,
          meta: @ge_meta
        })
      )
    end
  end

  defmacro define_mapping_function(name) do
    quote bind_quoted: [name: name] do
      mapping = Module.get_attribute(__MODULE__, :"#{name}_mapping")

      Module.eval_quoted(
        __MODULE__,
        GlobalEnum.Ast.define_function_with_spec_and_doc(%{
          name: :"#{name}_mapping",
          return: mapping,
          doc: """
          Returns `:#{name}` enum mapping
          ```
          #{inspect(mapping)}
          ```
          """,
          meta: @ge_meta
        })
      )
    end
  end

  defmacro define_values_function(name) do
    quote bind_quoted: [name: name] do
      Module.eval_quoted(
        __MODULE__,
        GlobalEnum.Ast.define_function_with_spec_and_doc(%{
          name: :"#{name}",
          return: Module.get_attribute(__MODULE__, name),
          doc: """
          Returns a list of values from the `#{name}` enum.
          ```
          #{inspect(Module.get_attribute(__MODULE__, name))}
          ```
          """,
          meta: @ge_meta
        })
      )
    end
  end

  defmacro define_dump_values_function(name) do
    quote bind_quoted: [name: name] do
      Module.eval_quoted(
        __MODULE__,
        GlobalEnum.Ast.define_function_with_spec_and_doc(%{
          name: :"#{name}_dumped",
          return: Module.get_attribute(__MODULE__, :"#{name}_dumped"),
          doc: """
          Returns a list of dump values from the `#{name}` enum.
          ```
          #{inspect(Module.get_attribute(__MODULE__, :"#{name}_dumped"))}
          ```
          """,
          meta: @ge_meta
        })
      )
    end
  end

  defmacro define_value_functions(name) do
    quote bind_quoted: [name: name] do
      __MODULE__
      |> Module.get_attribute(:"#{name}")
      |> Enum.map(fn value ->
        function_ast =
          GlobalEnum.Ast.define_function_with_spec_and_doc(%{
            name: :"#{name}_#{value}",
            return: value,
            doc: "Returns ```:#{value}``` value from the #{name} enum",
            meta: @ge_meta
          })

        Module.eval_quoted(__MODULE__, function_ast)
      end)
    end
  end

  defmacro define_dump_value_functions(name) do
    quote bind_quoted: [name: name] do
      __MODULE__
      |> Module.get_attribute(:"#{name}_enum")
      |> Enum.each(fn {value, dump_value} ->
        function_ast =
          GlobalEnum.Ast.define_function_with_spec_and_doc(%{
            name: :"#{name}_#{value}_dumped",
            return: dump_value,
            doc: "Returns ```\"#{dump_value}\"``` dump value of `:#{value}` from the `#{name}` enum",
            meta: @ge_meta
          })

        Module.eval_quoted(__MODULE__, function_ast)
      end)
    end
  end

  defmacro define_value_attributes(name) do
    quote bind_quoted: [name: name] do
      __MODULE__
      |> Module.get_attribute(name)
      |> Enum.each(&Module.put_attribute(__MODULE__, :"#{name}_#{&1}", &1))
    end
  end

  defmacro define_dump_value_attributes(name) do
    quote bind_quoted: [name: name] do
      __MODULE__
      |> Module.get_attribute(:"#{name}_enum")
      |> Enum.each(fn {value, dump_value} ->
        Module.put_attribute(__MODULE__, :"#{name}_#{value}", dump_value)
      end)
    end
  end

  defmacro define_enum_value_type(name) do
    quote bind_quoted: [name: name] do
      enum_values = Module.get_attribute(__MODULE__, name)
      enum_values_as_type_ast = GlobalEnum.Ast.type_list_to_type(enum_values, @ge_meta)

      type_doc = """
      Enum value for the `#{name}` enum.
      """

      GlobalEnum.Build.define_type(:"#{name}_enum_value", type_doc, enum_values_as_type_ast)
    end
  end

  def format_enum(values) do
    values
    |> Stream.map(&to_key_value_pair/1)
    |> Enum.uniq()
  end

  defmacro eval(ast) do
    quote bind_quoted: [ast: ast] do
      Module.eval_quoted(__MODULE__, ast)
    end
  end

  defmacro copy_transform_attribute(from, to, transformer) do
    quote bind_quoted: [from: from, to: to, transformer: transformer] do
      __MODULE__
      |> Module.get_attribute(from)
      |> transformer.()
      |> (&Module.put_attribute(__MODULE__, to, &1)).()
    end
  end

  defmacro define_type(name, type_doc, type_ast) do
    quote bind_quoted: [name: name, type: type_ast, type_doc: type_doc] do
      name
      |> GlobalEnum.Ast.define_type(type_doc, type, @ge_meta)
      |> (&Module.eval_quoted(__MODULE__, &1)).()
    end
  end

  defp to_key_value_pair({key, value}), do: {key, value}
  defp to_key_value_pair(key), do: {key, Atom.to_string(key)}
end
