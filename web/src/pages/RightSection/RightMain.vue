<script setup lang="ts">
// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

// Components
import MainHeader from "@/components/layout/MainHeader.vue"
import CartItems from "./CartItems.vue"
import CartPayment from "./CartPayment.vue"
</script>

<template>
  <main class="shop__right">
    <section class="shop__right-cart">
      <MainHeader :locales="shopStore.locales.cartHeader" :position="'right'" />
      <CartItems />
      <CartPayment />
    </section>
  </main>
</template>

<style lang="scss">
.shop__right {
  display: flex;
  flex-direction: column;
  width: 27.5%;
  height: 100%;
  gap: 0.5vh;

  &-cart {
    position: relative;
    height: 100%;
    width: 100%;
    display: flex;
    flex-direction: column;
    font-family: "PFDinDisplayPro-Bold", sans-serif;
    gap: 2vh;
  }
}
</style>
