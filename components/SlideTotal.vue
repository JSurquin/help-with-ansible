<script setup lang="ts">
import { useSlideContext } from "@slidev/client";

const { $slidev } = useSlideContext();
</script>

<template>
  <span class="slidev-total">{{ $slidev.nav.total }}</span>
</template>

<style>
.slidev-total {
  font-size: 0.75rem;
  color: inherit;
}
</style>
