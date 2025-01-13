import { useShopStore } from "@/stores/shop"

export const getImageSrc = (name: string): string | undefined => {
  const shopStore = useShopStore()
  if (!name || typeof name !== "string") return undefined

  return `${shopStore.imagePath}${encodeURIComponent(name)}.png`
}
