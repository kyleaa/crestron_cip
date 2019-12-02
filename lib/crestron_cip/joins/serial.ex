defmodule CrestronCip.Joins.Serial do
  @doc """
  iex> #{__MODULE__}.decode(<<0x00,0x0e,0x00,0x00>>)
  {15, 0}
  """
  def decode(<<join::size(16), value::size(16)>>) do
    {join + 1, value}
  end

  @doc """
  iex> #{__MODULE__}.encode(15, 0)
  <<0x00,0x0e,0x00,0x00>>
  """
  def encode(join, value) do
    <<join - 1::size(16), value::size(16)>>
  end
end
