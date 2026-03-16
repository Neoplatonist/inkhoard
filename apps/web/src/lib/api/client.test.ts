import { beforeEach, describe, expect, it, vi } from "vitest";
import { delete as del, get, post, put } from "./client";

describe("api client contract", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    vi.stubGlobal(
      "fetch",
      vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({ ok: true }),
      }),
    );
  });

  it("exports get, post, put, delete functions", () => {
    expect(typeof get).toBe("function");
    expect(typeof post).toBe("function");
    expect(typeof put).toBe("function");
    expect(typeof del).toBe("function");
  });

  it("prepends /api/v1/ to all paths", async () => {
    await get("books");
    await post("books", { title: "Dune" });
    await put("books/1", { title: "Dune Messiah" });
    await del("books/1");

    expect(fetch).toHaveBeenNthCalledWith(
      1,
      "/api/v1/books",
      expect.objectContaining({ method: "GET" }),
    );
    expect(fetch).toHaveBeenNthCalledWith(
      2,
      "/api/v1/books",
      expect.objectContaining({ method: "POST" }),
    );
    expect(fetch).toHaveBeenNthCalledWith(
      3,
      "/api/v1/books/1",
      expect.objectContaining({ method: "PUT" }),
    );
    expect(fetch).toHaveBeenNthCalledWith(
      4,
      "/api/v1/books/1",
      expect.objectContaining({ method: "DELETE" }),
    );
  });

  it("attaches Authorization Bearer token when token is present", async () => {
    await get("books", { token: "test-token" });

    expect(fetch).toHaveBeenCalledWith(
      "/api/v1/books",
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: "Bearer test-token",
        }),
      }),
    );
  });
});
