defmodule InkHoard.UUIDTest do
  use ExUnit.Case, async: true

  # UUID v7 format: xxxxxxxx-xxxx-7xxx-[89ab]xxx-xxxxxxxxxxxx
  # Per RFC 9562 §5.7: 48-bit Unix timestamp (ms), version nibble = 7,
  # 12-bit sub-millisecond / sequence, variant bits 10xxxxxx.
  @uuid_v7_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

  describe "InkHoard.UUID.generate/0" do
    test "returns a lowercase, hyphenated UUID string" do
      uuid = InkHoard.UUID.generate()

      assert is_binary(uuid),
             "expected a binary string, got: #{inspect(uuid)}"

      assert String.length(uuid) == 36,
             "expected 36-character UUID, got length #{String.length(uuid)}"
    end

    test "returns a valid UUID v7 (version nibble = 7, RFC 9562 variant bits)" do
      uuid = InkHoard.UUID.generate()

      assert uuid =~ @uuid_v7_regex,
             "UUID #{inspect(uuid)} does not match UUID v7 format " <>
               "(expected xxxxxxxx-xxxx-7xxx-[89ab]xxx-xxxxxxxxxxxx)"
    end

    test "is castable as an Ecto UUID" do
      uuid = InkHoard.UUID.generate()

      assert {:ok, _} = Ecto.UUID.cast(uuid),
             "Ecto.UUID.cast/1 rejected #{inspect(uuid)}"
    end

    test "generated UUIDs are time-ordered across milliseconds" do
      # UUID v7 embeds a 48-bit millisecond timestamp in the most-significant
      # bits, so lexicographic comparison on the canonical string form is
      # equivalent to temporal ordering. Within the same millisecond, random
      # sub-ms bits mean ordering is not guaranteed — this is acceptable for
      # InkHoard's write throughput profile.
      uuid1 = InkHoard.UUID.generate()
      Process.sleep(2)
      uuid2 = InkHoard.UUID.generate()

      assert uuid1 < uuid2,
             "expected #{inspect(uuid1)} < #{inspect(uuid2)} — " <>
               "UUIDs generated 2ms apart must be time-ordered"
    end

    test "a sequence of 50 UUIDs generated 2ms apart is strictly increasing" do
      uuids = Enum.map(1..50, fn _ ->
        uuid = InkHoard.UUID.generate()
        Process.sleep(2)
        uuid
      end)

      sorted = Enum.sort(uuids)

      assert uuids == sorted,
             "UUID sequence is not time-ordered; " <>
               "first out-of-order pair: #{inspect(first_inversion(uuids))}"
    end

    test "1_000 generated UUIDs are all unique" do
      uuids = Enum.map(1..1_000, fn _ -> InkHoard.UUID.generate() end)
      unique = Enum.uniq(uuids)

      assert length(uuids) == length(unique),
             "expected 1_000 unique UUIDs, found #{length(uuids) - length(unique)} duplicate(s)"
    end
  end

  # --- helpers -----------------------------------------------------------

  # Returns the first {a, b} pair where a >= b (i.e. not strictly increasing).
  defp first_inversion(uuids) do
    uuids
    |> Enum.zip(tl(uuids))
    |> Enum.find(fn {a, b} -> a >= b end)
  end
end
