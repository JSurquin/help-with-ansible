<!-- global-top.vue -->

<template>
  <footer
    v-if="$slidev.themeConfigs.eventLogo || $slidev.themeConfigs.twitter"
    class="absolute bottom-0 p-4 w-full justify-between mt-auto flex items-center w-full text-primary dark:text-white z-10"
  >
    <div>
      <a
        v-if="$slidev.themeConfigs.twitter"
        :href="$slidev.themeConfigs.twitterUrl"
        target="_blank"
      >
        <logos-linkedin />{{ $slidev.themeConfigs.twitter }}
      </a>
    </div>
    <!-- <div>
      <Link to="sommaire" class="text-primary dark:text-white">
        Revenir au sommaire
      </Link>
    </div> -->
  </footer>
</template>
