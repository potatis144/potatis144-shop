<script setup lang="ts">
// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

// Components
import MainHeader from "@/components/layout/MainHeader.vue"
import CategoryList from "./CategoryList.vue"
import ItemList from "./ItemList.vue"
</script>

<template>
  <main class="shop__left">
    <section class="shop__left-top">
      <MainHeader :locales="shopStore.locales.mainHeader" :position="'left'" />
      <CategoryList />
    </section>
    <ItemList />
  </main>
</template>

<style lang="scss">
.shop__left {
  display: flex;
  flex-direction: column;
  width: 70%;
  height: 100%;
  gap: 2vh;

  &-top {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: fit-content;
  }
}
</style>
