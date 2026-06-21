import type { SlideInfo } from '@slidev/types'

export default {
  name: 'slidev-plugin-long-code',
  onSlidesParsed(slides: SlideInfo[]) {
    console.warn(
      'Plugin long-code-sharp-in-pdf: Starting slide processing',
    )
    console.warn(`Number of slides to process: ${slides.length}`)

    return slides.map((slide) => {
      console.warn('Processing slide:', slide)

      // Debug message styled similarly to slidev-addon-narrator
      const debugMessage = `
<div class="fixed bottom-5 right-5 z-50 bg-blue-500 text-white px-4 py-2 rounded shadow">
  Debug: Plugin active on this slide
</div>
`

      return {
        ...slide,
        content: `${slide.content}\n\n---\n\n${debugMessage}`,
      }
    })
  },
}
