defmodule InkHoard.UUID do
  @moduledoc """
  Thin wrapper around `Uniq.UUID.uuid7/0` for UUID v7 generation (RFC 9562).

  All InkHoard schemas use this module for primary key generation via
  `InkHoard.Schema`. The wrapper keeps the dependency swappable — if a
  different UUID v7 library is needed in the future, only this module changes.
  """

  @doc """
  Generates a new UUID v7 string.

  Returns a lowercase, hyphenated UUID with version nibble `7` and
  RFC 9562 variant bits (`10xxxxxx`).

  ## Examples

      iex> uuid = InkHoard.UUID.generate()
      iex> uuid =~ ~r/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
      true

  """
  @spec generate() :: String.t()
  def generate do
    Uniq.UUID.uuid7()
  end
end
