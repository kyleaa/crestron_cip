defmodule CrestronCip.Decoder do
  use Bitwise
  alias CrestronCip.Joins
  require Logger

  # def decode(<<0x00>> <> rest), do: [:ack | decode(rest)]
  # def decode(<<0x01>> <> rest), do: [:signon | decode(rest)]
  # def decode(<<0x02>> <> rest), do: [:connection_accepted | decode(rest)]
  # def decode(<<0x04>> <> rest), do: [:connection_refused | decode(rest)]

  def decode(<<0x05, _filler::size(40), join_type::size(8)>> <> command) when join_type in [0x00, 0x27] do
    # Digital Join
    {index, value} = Joins.Digital.decode(command)
    {:digital_join, index, value}
  end

  def decode(<<0x05, _filler::size(40), join_type::size(8)>> <> command = msg) when join_type in [0x01, 0x14] do
    # Analog Join
    Logger.debug "Decoding #{inspect msg}"
    {index, value} = Joins.Analog.decode(command)
    {:analog_join, index, value}
  end

  # def decode(<<0x0D>> <> rest), do: [:ping | decode(rest)]
  # def decode(<<0x0E>> <> rest), do: [:pong | decode(rest)]
  # def decode(<<0x0F>> <> rest), do: [:query | decode(rest)]


  def decode(_any), do: {:unknown}


end
