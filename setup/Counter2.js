<script>
export default {
  // MODEL - Data
  data() {
    return {
        compteur: 0,}
  },
  // VIEWMODEL - Logique
  methods: {
    incrementer() {
      this.compteur++;
    },
    decrementer() {
      this.compteur--;
    }
  }
}
</script>

<template>
  <!-- VIEW - Interface -->
  <div>
    <p>Compteur: {{ compteur }}</p>
    <button @click="incrementer">+1</button>
  </div>
</template>