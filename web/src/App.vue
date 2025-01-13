<script setup lang="ts">
// External Libraries
import { computed, onMounted, onUnmounted } from "vue"

// Stores
import { useShopStore } from "@/stores/shop"
const shopStore = useShopStore()

// Composables
import { useShopEvents } from "@/composables/useShopEvents"
const { handleMessage } = useShopEvents()

// Pages
import LeftMain from "@/pages/LeftSection/LeftMain.vue"
import RightMain from "@/pages/RightSection/RightMain.vue"

// Utils
import { fetchData } from "@/utils/api"

const devStyles = computed(() => {
  return {
    backgroundImage: `url(${new URL("@/assets/evening-bg.png", import.meta.url)})`,
    backgroundSize: "cover",
    backgroundRepeat: "no-repeat",
  }
})

const handleKeyup = (event: KeyboardEvent): void => {
  if (event.key !== "Escape") return
  closeShop()
}
const closeShop = (): void => {
  fetchData({ label: "closeShop" })
}

// Lifecycle Hooks
onMounted(() => {
  window.addEventListener("message", handleMessage)
  window.addEventListener("keyup", handleKeyup)
})
onUnmounted(() => {
  window.removeEventListener("message", handleMessage)
  window.removeEventListener("keyup", handleKeyup)
})
</script>

<template>
  <transition name="fade">
    <div v-if="shopStore.showShop" id="app" :style="shopStore.isDevMode ? devStyles : {}">
      <main class="shop">
        <main class="shop__container">
          <LeftMain />
          <RightMain />
        </main>
      </main>
    </div>
  </transition>
</template>

<style lang="scss">
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
}

body {
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
  image-rendering: optimizeQuality;

  overflow: hidden;
  overflow-wrap: break-word;
  word-wrap: break-word;
  white-space: pre-wrap;
  margin: 0;
  padding: 0;

  user-select: none;
}

@font-face {
  font-family: "PFDinDisplayPro-Medium";
  font-style: normal;
  font-weight: normal;
  src:
    local("PFDinDisplayPro-Medium"),
    url("@/assets/fonts/PFDinDisplayPro-Medium.woff") format("woff");
}
@font-face {
  font-family: "PFDinDisplayPro-Bold";
  font-style: normal;
  font-weight: normal;
  src:
    local("PFDinDisplayPro-Bold"),
    url("@/assets/fonts/PFDinDisplayPro-Bold.woff") format("woff");
}

.fade {
  &-enter-active,
  &-leave-active {
    transition: opacity 0.25s ease;
  }
  &-enter-from,
  &-leave-to {
    opacity: 0;
  }
  &-leave-from,
  &-enter-to {
    opacity: 1;
  }
}

.shop {
  position: absolute;
  display: flex;
  inset: 0;
  overflow: hidden;
  justify-content: center;
  align-items: center;
  width: 100vw;
  height: 100vh;
  font-family: "PFDinDisplayPro-Medium", sans-serif;
  background-color: rgba(10, 10, 10, 0.93);

  &__container {
    position: relative;
    display: flex;
    flex-direction: row;
    width: 100vw;
    height: 100vh;
    padding: 8vh;
    color: white;
    gap: 0.5vh;
    justify-content: space-between;
  }
}
</style>
