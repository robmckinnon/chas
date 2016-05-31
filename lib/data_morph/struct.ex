defmodule DataMorph.Struct do
  @moduledoc false

  @doc ~S"""
  Defines a struct from given alias and list of fields.

  When called a second time with additional new fields it redefines struct,
  setting fields to be the union of the old and new fields.

  ## Example

      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:baz, :boom])
      {:module, Foo.Bar, _, %Foo.Bar{baz: nil, boom: nil}}
      iex> %Foo.Bar{baz: "zy", boom: "boom"}
      %Foo.Bar{baz: "zy", boom: "boom"}
      iex> DataMorph.Struct.defmodulestruct(Foo.Bar, [:bish, :bash])
      {:module, Foo.Bar, _, %Foo.Bar{bash: nil, baz: nil, bish: nil, boom: nil}}
      iex> %Foo.Bar{bish: "zy", bash: "boom"}
      %Foo.Bar{bash: "boom", baz: nil, bish: "zy", boom: nil}

  """
  defmacro defmodulestruct kind, fields do
    quote do
      value = try do
        template = struct unquote(kind)
        existing_fields = template |> Map.to_list |> Keyword.keys |> MapSet.new
        new_fields = MapSet.new unquote(fields)

        if MapSet.equal? existing_fields, new_fields do
          {:module, unquote(kind), nil, template}
        else
          union = MapSet.union(existing_fields, new_fields)
          defmodule Module.concat([ unquote(kind) ]) do
            defstruct MapSet.to_list(union)
          end
        end
      rescue
        UndefinedFunctionError ->
          defmodule Module.concat([ unquote(kind) ]) do
            defstruct unquote(fields)
          end
      end
      value
    end
  end

  @doc ~S"""
  Defines a struct and returns list of structs created from list of maps.

  When called a second time with different fields it redefines struct,
  setting fields to be the union of the old and new fields.

  ## Example

      iex> structs = DataMorph.Struct.from_list_of_maps OpenRegister, "country", [
      iex> %{"name" => "New Zealand", "iso" => "nz"},
      iex> %{"name" => "United Kingdom", "iso" => "gb"}
      iex> ]
      [%OpenRegister.Country{iso: "nz", name: "New Zealand"},
      %OpenRegister.Country{iso: "gb", name: "United Kingdom"}]
  """
  def from_list_of_maps namespace, name, list do
    kind = DataMorph.Module.camelize_concat(namespace, name)
    fields = extract_fields(list)
    defmodulestruct kind, fields
    Enum.map list, &(Maptu.struct!(kind, &1))
  end

  defp extract_fields list do
    list
      |> List.first
      |> Map.keys
      |> Enum.map(&(String.to_atom &1))
  end

end
