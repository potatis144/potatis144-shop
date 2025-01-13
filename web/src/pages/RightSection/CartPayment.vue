<script setup lang="ts">
// External Libraries
import { computed } from "vue"
import { Icon } from "@iconify/vue"

// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

// Utils
import { fetchData } from "@/utils/api"
import { formatPrice } from "@/utils/formatPrice"

const totalPrice = computed(() => {
  return shopStore.cart.reduce((total, item) => total + item.price * item.quantity, 0)
})

const payCart = async (type: string): Promise<void> => {
  if (shopStore.cart.length === 0) return

  const data = {
    label: "payCart",
    type,
    cart: shopStore.cart,
  }

  const response = await fetchData(data)
  if (response === true) {
    clearCart()
  }
}
const clearCart = (): void => {
  if (shopStore.cart.length === 0) return
  shopStore.cart = []
}
</script>

<template>
  <section class="payment">
    <p class="payment-title">{{ shopStore.locales.item.paymentTitle }}</p>
    <span class="price">{{ formatPrice(totalPrice) }}</span>
    <div class="pay">
      <button class="button" @click="payCart('bank')"><Icon icon="mingcute:bank-card-fill" /> {{ shopStore.locales.buttons.payBank }}</button>
      <button class="button" @click="payCart('cash')"><Icon icon="mdi:wallet" /> {{ shopStore.locales.buttons.payCash }}</button>
    </div>
  </section>
</template>

<style lang="scss">
.payment {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  width: 100%;
  height: 22%;
  justify-content: space-around;
  gap: 0.7vh;

  .payment-title,
  .price-container,
  .description {
    margin: 0;
    padding: 0;
    line-height: 100%;
  }

  .payment-title {
    font-family: "PFDinDisplayPro-Medium", sans-serif;
    font-size: 1.15rem;
    letter-spacing: 0.05em;
    color: rgb(255, 255, 255);
  }

  .price {
    overflow: auto;
    width: 100%;
    height: fit-content;
    font-family: "PFDinDisplayPro-Bold", sans-serif;
    font-size: 3rem;
    letter-spacing: 0;
    color: rgb(102, 249, 111);
    text-shadow: 0vh 0vh 1.19vh rgba(102, 249, 111, 0.5);
  }

  .pay {
    margin-left: auto;
    display: flex;
    flex-direction: row;
    justify-content: flex-start;
    gap: 1vh;
    width: 100%;
    height: fit-content;

    .button {
      all: unset;
      display: flex;
      justify-content: center;
      align-items: center;
      width: 50%;
      height: 4.25vh;
      border-radius: 0.5vh;
      color: rgb(255, 255, 255);
      background-color: rgb(47, 48, 48);
      font-family: "PFDinDisplayPro-Bold", sans-serif;
      font-size: 0.88rem;
      transition: 0.25s background-color;
      gap: 0.5vh;

      svg {
        width: 2.25vh;
        height: auto;
        color: rgb(255, 255, 255);
      }

      &:hover {
        background-color: rgb(255, 255, 255);
        color: rgb(0, 0, 0);
        cursor: pointer;

        svg {
          color: rgb(0, 0, 0);
        }
      }
    }
  }
}
</style>
