import { defineStore } from "pinia"
import { ref, reactive } from "vue"

// Mock Data
import { mockCategories } from "@/mock/categoryMockData"
import { mockItems } from "@/mock/itemMockData"

// Type Interfaces
import type { Locales } from "@/types/Locales"
import type { ShopCategory } from "@/types/ShopCategory"
import type { ShopItem } from "@/types/ShopItem"
import type { CartItem } from "@/types/CartItem"

export const useShopStore = defineStore("shop", () => {
  const isDevMode = import.meta.env.VITE_ENV_MODE === "development"

  const showShop = ref(false)
  if (isDevMode) {
    showShop.value = true
  }

  const imagePath = "img/items/"

  const selectedCategory = ref<string>("all")

  const categories = reactive<ShopCategory[]>([])
  if (isDevMode) {
    Object.assign(categories, mockCategories)
  }

  const items = reactive<ShopItem[]>([])
  if (isDevMode) {
    Object.assign(items, mockItems)
  }

  const cart = reactive<CartItem[]>([])

  const locales = reactive<Locales>({
    mainHeader: {
      title: "market",
      tag: "24/7",
      description: "Welcome to your local market, where we're always here for you, day or night!\nExplore a curated selection of premium goods, tailored to meet your every need.",
    },
    cartHeader: {
      title: "shopping",
      tag: "cart",
      description: "Review your chosen items and proceed to secure, easy checkout with multiple payment options.",
    },
    buttons: {
      addCart: "Add To Cart",
      payBank: "Bank",
      payCash: "Cash",
    },
    item: {
      paymentTitle: "Payment",
    },
    currencySymbol: "$",
  })

  return {
    isDevMode,

    showShop,

    imagePath,
    selectedCategory,
    categories,
    items,
    cart,
    locales,
  }
})
