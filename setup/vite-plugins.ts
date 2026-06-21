import { defineVitePluginsSetup } from "@slidev/types";

export default defineVitePluginsSetup((options) => {
  console.warn(
    "Plugin long-code-sharp-in-pdf: Starting slide processing",
  );
  console.warn(`Number of slides to process: ${options.data.slides.length}`);

  return [
    {
      name: "slidev-plugin-long-code",
      transform(code, id) {
        if (!id.endsWith(".md")) return;

        // Debug message styled similarly to slidev-addon-narrator
        const debugMessage = `
<div class="fixed bottom-5 right-5 z-50 bg-blue-500 text-white px-4 py-2 rounded shadow">
  Debug: Plugin active on this slide
</div>
`;

        return {
          code: `${code}\n\n---\n\n${debugMessage}`,
          map: null,
        };
      },
    },
  ];
});
