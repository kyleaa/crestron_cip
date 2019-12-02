defmodule CrestronCip.Encoder do
  use Bitwise
  alias CrestronCip.Joins

  def encode({:digital_join, join, value}) do
    Joins.Digital.encode(join, value)
  end


end
