<template>
  <div class="bg-section slidev-layout new-section">
    <CornerCurves class="absolute left-0 top-0 transform rotate-90" />
    <div class="h-full flex flex-col justify-center items-center">
      <div
        class="flex flex-col justify-center text-center dark:decoration-purple-400 bg-white p-12 shadow-2xl neon-border"
      >
        <slot></slot>
      </div>
    </div>
    <SlideCurrentNo
      class="dark:!text-white absolute top-4 right-2 -translate-x-1/2 !text-[8px] p-1 w-6 h-6 items-center justify-center flex rounded-full bg-white/10 backdrop-blur-sm border border-gray-600 opacity-80"
    />
    <div
      class="absolute bottom-0 p-4 justify-end -ml-16 mt-auto flex items-center w-full z-50"
    >
      <Link class="dark:!text-purple-300" to="sommaire">
        Back to table of contents
      </Link>
    </div>
    <AsGraphic type="zigzag" class="absolute top-20 -right-30" />
  </div>
</template>

<style>
.slidev-layout.new-section {
  h1 {
    @apply text-primary text-6xl z-50 leading-20 mb-0 font-title font-extrabold;
  }

  h1 + p {
    @apply mt-4 opacity-100;
  }

  p > img {
    @apply w-2/3 mx-auto;
  }
}

/* Simple moving neon border */
.neon-border {
  position: relative;
  border: 2px solid transparent;
  border-radius: 8px;
  background:
    linear-gradient(white, white) padding-box,
    linear-gradient(90deg, #ff006e, #8338ec, #3a86ff, #06ffa5, #ffbe0b, #ff006e)
      border-box;
  background-size: 200% 100%;
  animation: neon-move 3s linear infinite;
}

.neon-border::before {
  content: "";
  position: absolute;
  top: -4px;
  left: -4px;
  right: -4px;
  bottom: -4px;
  border-radius: 12px;
  background: linear-gradient(
    90deg,
    #ff006e,
    #8338ec,
    #3a86ff,
    #06ffa5,
    #ffbe0b,
    #ff006e
  );
  background-size: 200% 100%;
  z-index: -1;
  filter: blur(8px);
  opacity: 0.7;
  animation: neon-move 3s linear infinite;
}

@keyframes neon-move {
  0% {
    background-position: 0% 50%;
  }
  100% {
    background-position: 200% 50%;
  }
}

/* Mode sombre */
.dark .neon-border {
  background:
    linear-gradient(rgb(15, 23, 42), rgb(15, 23, 42)) padding-box,
    linear-gradient(90deg, #ff0080, #9d4edd, #4cc9f0, #7209b7, #f72585, #ff0080)
      border-box;
  background-size: 200% 100%;
}

.dark .neon-border::before {
  background: linear-gradient(
    90deg,
    #ff0080,
    #9d4edd,
    #4cc9f0,
    #7209b7,
    #f72585,
    #ff0080
  );
  background-size: 200% 100%;
}
</style>
