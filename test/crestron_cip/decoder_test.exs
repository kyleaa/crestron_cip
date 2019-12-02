defmodule CrestronCip.DecoderTest do
  use ExUnit.Case
  doctest CrestronCip.Decoder
  alias CrestronCip.Decoder

  test "decode samples" do
    assert Decoder.decode("\x05\x00\x06\x00\x00\x03\x27\x0e\x80") == {:digital_join, 15, false}
    assert Decoder.decode("\x05\x00\x06\x00\x00\x03\x27\x0e\x00") == {:digital_join, 15, true}
    assert Decoder.decode("\x05\x00\x06\x00\x00\x03\x27\x00\x00") == {:digital_join, 1, true}

  end
end
