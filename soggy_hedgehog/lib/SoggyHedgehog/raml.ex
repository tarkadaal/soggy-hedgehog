defmodule SoggyHedgehog.Raml do

  def parse("") do
    {:error, "Can't parse an empty string"}
  end

  def parse(text) do
    lines = text 
            |> String.split("\n") 
            |> Enum.map(&(String.replace_leading(&1, "  ", "\t"))) # replace with tabs, so we keep indentation, but can still split on spaces
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
    _parse([{:types} | lines], Map.put(data, :types, %{}))
  end

  defp _parse([{:types}, token | lines], data) do
    endpoint? = hd(token) == "/"
    if endpoint? do
      _parse([token | lines], data)
    else
      atom_token = token |> hd |> atomize
      data = put_in(data, [:types, atom_token], %{})
      _parse([{:types, atom_token} | lines], data)
    end
  end

  defp _parse([{:types, typename}, [ "\t\ttype:" | value] | lines], data) do
    data = put_in(data, [:types, typename, :type], hd(value))
    _parse([{:types, typename}| lines], data)
  end

  defp _parse([{:types, typename}, [ "\t\tproperties:" | _] | lines], data) do
    data = put_in(data, [:types, typename, :properties], %{})
    _parse([{:types, typename, :properties} | lines], data)
  end

  defp _parse([{:types, _, :properties}, _], data) do
    data
  end

  defp _parse([{:types, _, :properties}, [key | []] | lines], data) do
    _parse([{:types}, [key | []] | lines], data)
  end

  defp _parse([{:types, typename, :properties}, [key | value] | lines], data) do
    data = put_in(data, [:types, typename, :properties, atomize(key)], hd(value))
    _parse([{:types, typename, :properties} | lines], data)
  end

  defp _parse([_ | lines], data) do
    _parse(lines, data)
  end

  defp atomize(str) do
    str |> String.trim |> String.replace_trailing(":", "") |> String.to_atom
  end

end
