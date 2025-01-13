import { useShopStore } from "@/stores/shop"

export const formatPrice = (number: number): string => {
  const shopStore = useShopStore()
  if (typeof number !== "number") return `${number}`

  const currencySymbol = shopStore.locales.currencySymbol || "$"
  return `${currencySymbol} ${number.toLocaleString("de-DE")}`
}
