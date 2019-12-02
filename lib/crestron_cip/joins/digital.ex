defmodule CrestronCip.Joins.Digital do
  @doc """
  iex> #{__MODULE__}.decode(<<0x0e,0x00>>)
  {15, true}
  iex> #{__MODULE__}.decode(<<0x0e,0x80>>)
  {15, false}
  """
  def decode(<<index::size(8), value::size(1), universe::size(7)>>) do
    {1 + index + (universe * 0x100), value == 0}
  end

  @doc """
  iex> #{__MODULE__}.encode(15, true)
  <<0x0e,0x00>>
  iex> #{__MODULE__}.encode(300, true)
  <<0x2b,0x01>>
  iex> #{__MODULE__}.encode(3000, true)
  <<0xb7,0x0b>>
  iex> #{__MODULE__}.encode(15, false)
  <<0x0e,0x80>>
  """
  def encode(join, value) do
    universe = div(join - 1, 0x100)
    index = rem(join - 1, 0x100)
    val = if value, do: 0, else: 1
    <<index::size(8), val::size(1), universe::size(7)>>
  end
end
