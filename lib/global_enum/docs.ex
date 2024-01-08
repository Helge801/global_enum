defmodule GlobalEnum.Docs do
  @moduledoc false

  @indent "  "

  def format_list(list) do
    "[\n#{@indent}#{list |> Enum.map(&format_value/1) |> Enum.join(",\n#{@indent}")}\n]"
  end

  defp format_value({key, val}) when is_atom(key), do: "#{key}: #{inspect(val)}"
  defp format_value(other), do: inspect(other)
end
