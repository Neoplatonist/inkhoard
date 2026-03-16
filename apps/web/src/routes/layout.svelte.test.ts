import { describe, expect, it } from "vitest";
import { render } from "vitest-browser-svelte";
import { createRawSnippet } from "svelte";
import Layout from "./+layout.svelte";

describe("root layout", () => {
  it("renders without error", () => {
    render(Layout, {
      children: createRawSnippet(() => ({ render: () => "<span></span>" })),
    });

    expect(document.querySelector('link[rel="icon"]')).not.toBeNull();
  });
});
