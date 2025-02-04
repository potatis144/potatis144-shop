import { useShopStore } from "@/stores/shop"
import { fetchData } from "@/utils/api"

export const useShopEvents = () => {
  const shopStore = useShopStore()

  const handleMessage = (event: MessageEvent) => {
    const { action, ...data } = event.data

    const actions: Record<string, () => void> = {
      toggleShop: async () => {
        if (data.showShop) {
          shopStore.selectedCategory = "all"
          shopStore.cart = []
        }
        shopStore.showShop = data.showShop
      },
    }

    const actionFunction = actions[action]
    if (actionFunction) {
      actionFunction()
    }
  }

  const getCategories = async () => {
    const data = await fetchData({ label: "getCategories" })
    if (data) {
      shopStore.categories = data.categories ?? []
    }
  }
  const getItems = async () => {
    const data = await fetchData({ label: "getItems" })
    if (data) {
      shopStore.items = data.items ?? []
    }
  }
  const getLocales = async () => {
    const data = await fetchData({ label: "getLocales" })
    if (data) {
      shopStore.imagePath = data.imagePath ?? shopStore.imagePath
      shopStore.locales = data.locales ?? {}
    }
  }

  return {
    handleMessage,
    getCategories,
    getItems,
    getLocales,
  }
}
