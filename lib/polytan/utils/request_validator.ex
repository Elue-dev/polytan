defmodule Polytan.Utils.RequestValidator do
  def validate_required(params, required_fields) when is_map(params) do
    errors =
      required_fields
      |> Enum.reduce(%{}, fn field, acc ->
        case Map.get(params, field) in [nil, ""] do
          true -> Map.put(acc, field, ["is required"])
          false -> acc
        end
      end)

    case map_size(errors) == 0 do
      true -> {:ok, params}
      false -> {:error, errors}
    end
  end
end
