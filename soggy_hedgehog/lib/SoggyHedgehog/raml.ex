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
    atom_token = token |> hd |> atomize
    data = put_in(data, [:types, atom_token], %{})
    _parse([{:types, atom_token} | lines], data)
  end

  defp _parse([state, ["/" <> endpoint | rest] | lines], data) when is_tuple(state) and elem(state,0) == :types do  
    _parse([{:endpoints}, ["/" <> endpoint | rest] | lines], data)
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
    data = put_in_safely(data, [:types, typename, :properties, atomize(key)], hd(value))
    _parse([{:types, typename, :properties} | lines], data)
  end

  defp _parse([{:endpoints}, endpoint | lines], data) do
    data = put_in_safely(data, [:endpoints, endpoint], %{})
  end

  defp _parse([_ | lines], data) do
    _parse(lines, data)
  end

  defp atomize(str) do
    str |> String.trim |> String.replace_trailing(":", "") |> String.to_atom
  end

  defp put_in_safely(target, path, item) do
    target = _build_map_path(target, path)
    put_in(target, path, item)
  end

  defp _build_map_path(target, path, processed \\ [])

  defp _build_map_path(target, [_ | []], _) do
    target
  end

  defp _build_map_path(target, [current | rest], processed) do
    reversed = Enum.reverse([current | processed])
    target = if get_in(target, reversed) == nil do
      put_in(target, reversed, %{})
    else
      target
    end
    _build_map_path(target, rest, [current | processed])
  end
end
