<script setup lang="ts">
// External Libraries
import { computed, onMounted } from "vue"

// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

// Composables
import { useShopEvents } from "@/composables/useShopEvents"
const { getItems, getLocales } = useShopEvents()

// Utils
import { formatPrice } from "@/utils/formatPrice"
import { getImageSrc } from "@/utils/getImageSrc"

const filteredItems = computed(() => {
  return shopStore.items.filter(item => shopStore.selectedCategory === "all" || item.category === shopStore.selectedCategory)
})

const addToCart = (name: string): void => {
  const item = shopStore.items.find(item => item.name === name)
  if (item) {
    const existingIndex = shopStore.cart.findIndex(cartItem => cartItem.name === item.name)

    if (existingIndex !== -1) {
      shopStore.cart[existingIndex].quantity += 1
    } else {
      shopStore.cart.push({
        label: item.label,
        name: item.name,
        price: item.price,
        quantity: 1,
        category: item.category,
      })
    }
  }
}

onMounted(async () => {
  await getLocales()
  await getItems()
})
</script>

<template>
  <section class="shop__left-items">
    <div v-for="item in filteredItems" :key="item.name">
      <div v-if="shopStore.selectedCategory === 'all' || shopStore.selectedCategory === item.category" class="item">
        <div class="front">
          <div class="image-wrapper">
            <img :src="getImageSrc(item.name)" draggable="false" />
          </div>
          <div class="info">
            <p class="item-label">{{ item.label }}</p>
            <div class="item-price">{{ formatPrice(item.price) }}</div>
          </div>
          <div class="add-to-cart" @click="addToCart(item.name)">{{ shopStore.locales.buttons.addCart }}</div>
        </div>
      </div>
    </div>
  </section>
</template>

<style lang="scss">
.shop__left-items {
  position: relative;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  grid-auto-rows: minmax(25vh, 20vh);
  overflow: hidden;
  overflow-y: auto;
  scrollbar-gutter: stable;
  scroll-behavior: smooth;
  height: 100%;
  width: 100%;
  padding-right: 2vh;
  gap: 1.75vh;

  .item {
    display: flex;
    flex-shrink: 0;
    justify-content: center;
    align-items: center;
    position: relative;
    width: 100%;
    height: 100%;
    background-color: rgb(30, 30, 30);
    border-radius: 0.5vh;
    padding: 1.5vh;
    overflow: hidden;

    .front {
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      align-items: center;
      height: 100%;
      width: 100%;

      .image-wrapper {
        position: relative;
        display: flex;
        justify-content: center;
        align-items: center;
        background: radial-gradient(82.5% 50% at 50% 50%, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0) 100%);
        width: 100%;
        height: 70%;

        img {
          width: 8.5vh;
          height: auto;
          object-fit: contain;
        }
      }

      .info {
        display: flex;
        position: relative;
        flex-direction: row;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        font-family: "PFDinDisplayPro-Medium", sans-serif;

        .item-label {
          width: 65%;
          font-size: 0.875rem;
          color: rgba(255, 255, 255, 0.8);
          margin: 0;
        }

        .item-price {
          font-size: 0.85rem;
          font-family: "PFDinDisplayPro-Medium", sans-serif;
          color: rgb(102, 249, 111);
          text-shadow: 0vh 0vh 1.19vh rgba(102, 249, 111, 0.5);
          margin: 0;
        }
      }

      .add-to-cart {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 100%;
        height: 3.5vh;
        border-radius: 0.5vh;
        font-size: 1.3vh;
        font-family: "PFDinDisplayPro-Medium", sans-serif;
        background-color: rgb(47, 48, 48);
        color: rgb(255, 255, 255);
        transition:
          0.25s background-color,
          0.25s box-shadow;

        &:hover {
          background-color: rgb(255, 255, 255);
          box-shadow: 0vh 0.4vh 2.3vh rgba(255, 255, 255, 0.35);
          color: rgb(0, 0, 0);
          cursor: pointer;
        }
      }
    }
  }

  &::-webkit-scrollbar-thumb,
  &::-webkit-scrollbar-track {
    background-color: rgba(255, 255, 255, 0.05);
    border-radius: 0.2vh;
  }

  &::-webkit-scrollbar-thumb {
    cursor: pointer;
  }

  &::-webkit-scrollbar {
    width: 0.5vh;
  }
}
</style>
