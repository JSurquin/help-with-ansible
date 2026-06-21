<template>
  <AuthWrapper>
    <slot />
  </AuthWrapper>
</template>

<script setup lang="ts">
import AuthWrapper from "../components/AuthWrapper.vue";
</script>

<style>
.auth-layout {
  height: 100vh;
  width: 100vw;
}

.auth-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  gap: 1rem;
  text-align: center;
  padding: 2rem;
}
</style>
