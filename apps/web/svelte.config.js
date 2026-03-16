import adapter from "@sveltejs/adapter-static";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    adapter: adapter({
      pages: "build",
      assets: "build",
      fallback: "index.html",
      strict: false,
    }),
    alias: {
      $components: "src/lib/components",
      $features: "src/lib/features",
      $services: "src/lib/services",
      $stores: "src/lib/stores",
      $types: "src/lib/types",
      $utils: "src/lib/utils",
      $i18n: "src/lib/i18n",
    },
  },
  vitePlugin: {
    dynamicCompileOptions: ({ filename }) =>
      filename.includes("node_modules") ? undefined : { runes: true },
  },
};

export default config;
