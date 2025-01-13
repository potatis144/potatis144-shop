// Type Interfaces
import type { FetchData } from "@/types/FetchData"

export const fetchData = async (data: FetchData) => {
  try {
    // @ts-expect-error: GetParentResourceName() is a fivem function
    const response = await fetch(`https://${GetParentResourceName()}/shop:fetchData`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Failed to fetch data: ${response.status} ${response.statusText} - ${errorText}`)
    }

    return await response.json()
  } catch (error) {
    console.error(`Error fetching ${data.label ?? "data"}:`, error)
    return null
  }
}
