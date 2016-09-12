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

  defp _parse(lines, state \\ [], data \\ %{})

  defp _parse([], _, data) do
    data
  end

  defp _parse([["#%RAML", "1.0"] | lines], state, data) do
    _parse(lines, state, data)
  end

  defp _parse([[key | []]| lines], state, data) do 
    if string_depth(key) < length(state) do
      _parse([[key | []]| lines], tl(state), data)
    else
      _parse(lines, [String.trim(key) | state], data)
    end
  end

  defp _parse([[key , value]|lines], state, data) do
    key = String.trim key
    value = String.trim value
    data = put_in_safely(data, Enum.reverse([key | state]), value)
    _parse(lines, state, data)
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
    target = if (get_in(target, reversed) == nil), do: put_in(target, reversed, %{}), else: target
    _build_map_path(target, rest, [current | processed])
  end

  defp string_depth(str, depth \\ 0)
  defp string_depth(<<>>, depth) do
    depth
  end
  defp string_depth(<<9::utf8, rest:: binary>>, depth) do
    string_depth(rest, depth + 1)
  end
  defp string_depth(_, depth) do
    depth
  end


end
