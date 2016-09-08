defmodule SoggyHedgehog.Raml do

  def parse("") do
    {:error, "Can't parse an empty string"}
  end

  def parse(text) do
    lines = text 
            |> String.split("\n") 
            |> Enum.map(&(String.replace_leading(&1, "  ", "\t")))
            |> Enum.map(&(String.split(&1, " ", parts: 2)))
    {:ok, _parse(lines)}
  end

  defp _parse(lines, data \\ %{})

  defp _parse([], data) do
    data
  end

  defp _parse([["title:" | value] | lines], data) do
    _parse(lines, Map.put(data, :title, hd(value)))
  end

  defp _parse([["version:" | value] | lines], data) do
    _parse(lines, Map.put(data, :version, hd(value)))
  end

  defp _parse([["baseUri:" | value] | lines], data) do
    _parse(lines, Map.put(data, :base_uri, hd(value)))
  end

  defp _parse([["types:" | _] | lines], data) do
    _parse([:types | lines], Map.put(data, :types, %{}))
  end

  defp _parse([:types, token | lines], data) do
    endpoint? = hd(token) == "/"
    if endpoint? do
      _parse([token | lines], data)
    else
      atom_token = token |> hd |> String.trim |> String.replace_trailing(":", "") |> String.to_atom
      data = put_in(data, [:types, atom_token], %{})
      #types = Map.put(data.types, atom_token, %{})
      #data = %{data | types: types}
      _parse([{:types, atom_token} | lines], data)
    end
  end

  defp _parse([{:types, typename}, ["type:" | value] | lines], data) do
    #data = %{data | types: }
  end

  defp _parse([_ | lines], data) do
    _parse(lines, data)
  end

end
