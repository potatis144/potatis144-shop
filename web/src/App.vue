<script>
import { Icon } from "@iconify/vue"

export default {
  data() {
    return {
      showShop: false,
      debugMode: false,

      imagePath: "item_images/",
      currencySymbol: "$",

      locales: {
        // Main Header
        mainTitle: "Market",
        mainTag: "24/7",
        mainDescription:
          "Welcome to your local 24/7, where we're always here for you, day or night!\nExplore a curated selection of premium goods, tailored to meet your every need.",

        // Cart Header
        cartTitle: "Shopping",
        cartTag: "Cart",
        cartDescription: "Review your chosen items and proceed to secure, easy checkout with multiple payment options.",

        // Buttons
        addCart: "Add To Cart",
        paymentTitle: "Payment",
        payBank: "Bank",
        payCash: "Cash",
      },

      selectedCategory: "all",
      categories: [],
      // categories: [
      //   { name: "All Products", type: "all", icon: "ic:round-clear-all" },
      //   { name: "Weapons", type: "weapons", icon: "mdi:pistol" },
      //   { name: "Food", type: "food", icon: "mdi:food-drumstick" },
      //   { name: "Drinks", type: "drinks", icon: "ion:water-sharp" },
      //   { name: "Electronics", type: "electronics", icon: "ic:round-phone-iphone" },
      //   { name: "Tools", type: "tools", icon: "ion:hammer" },
      //   { name: "Healing", type: "healing", icon: "material-symbols:healing" },
      // ],
      items: [],
      // items: [
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      //   { name: "WEAPON_COMBATPDW", label: "Combat PDW", category: "weapons", price: 100000 },
      // ],
      cart: [],
    }
  },
  components: {
    Icon,
  },
  computed: {
    filteredItems() {
      return this.items.filter(item => this.selectedCategory === "all" || item.category === this.selectedCategory)
    },
    totalPrice() {
      return this.cart.reduce((total, item) => total + item.price * item.quantity, 0)
    },
  },
  methods: {
    handleMessage(event) {
      const { action, ...data } = event.data

      const actions = {
        toggleShop: () => {
          this.showShop = data.showShop
        },
        setShopData: () => {
          this.locales = {
            ...this.locales,
            ...data.locales,
          }
          this.cart = []
          this.categories = data.categories
          this.selectedCategory = "all"
          this.scrollIntoView()
          this.items = data.items
          this.items.forEach(item => {
            item.count = 0
          })
        },
      }

      if (actions[action]) {
        actions[action]()
      }
    },
    handleKeyup(event) {
      if (event.key === "Escape") {
        this.fetchData({ label: "closeShop" })
      }
    },
    async fetchData(data) {
      try {
        const response = await fetch(`https://${GetParentResourceName()}/shop:fetchData`, {
          method: "POST",
          headers: { "Content-Type": "application/json; charset=UTF-8" },
          body: JSON.stringify(data),
        })
        if (!response === true) {
          throw new Error("Network response returned false")
        }
        return await response.json()
      } catch (error) {
        console.error("Error fetching data:", error)
      }
    },
    async initShopData() {
      const data = await this.fetchData({ label: "initShopData" })
      if (data) {
        this.locales = data.locales
        this.imagePath = data.imagePath
        this.currencySymbol = data.currencySymbol
      }
    },
    async payCart(type) {
      if (this.cart.length === 0) return

      const data = {
        label: "payCart",
        type: type,
        cart: this.cart,
      }

      const response = await this.fetchData(data)
      if (response === true) {
        this.clearCart()
      }
    },

    formatPrice(number) {
      if (typeof number !== "number") return number

      const currencySymbol = this.currencySymbol || "$"
      return `${currencySymbol} ${number.toLocaleString("de-DE")}`
    },
    getImageSrc(name) {
      if (!name || typeof name !== "string") {
        return null
      }
      return `${this.imagePath}${encodeURIComponent(name)}.png`
    },

    addToCart(name) {
      const item = this.items.find(item => item.name === name)
      if (item) {
        const existingIndex = this.cart.findIndex(cartItem => cartItem.name === item.name)

        if (existingIndex !== -1) {
          this.cart[existingIndex].quantity += 1
        } else {
          this.cart.push({
            label: item.label,
            name: item.name,
            price: item.price,
            quantity: 1,
            category: item.category,
          })
        }
        item.count = 0
      }
    },
    clearCart() {
      if (this.cart.length == 0) return
      this.cart = []
    },

    decrementQuantity(index) {
      if (this.cart[index].quantity > 0) {
        this.cart[index].quantity--
        if (this.cart[index].quantity === 0) {
          this.cart.splice(index, 1)
        }
      }
    },
    incrementQuantity(index) {
      if (this.cart[index].quantity < 999) {
        this.cart[index].quantity++
      }
    },
    validateNumberInput(event) {
      const key = event.key
      const allowedKeys = ["Backspace", "Tab", "ArrowLeft", "ArrowUp", "ArrowRight", "ArrowDown", "Delete"]
      const isCtrlA = event.ctrlKey && key === "a"
      const isNumber = /^[0-9]$/.test(key)

      if (isNumber || allowedKeys.includes(key) || isCtrlA) {
        return
      }
      event.preventDefault()
    },
    validateQuantityInput(index) {
      const quantity = this.cart[index].quantity

      if (quantity === 0) {
        this.cart.splice(index, 1)
      } else if (!quantity || quantity < 0) {
        this.cart[index].quantity = 1
      } else if (quantity > 999) {
        this.cart[index].quantity = 999
      }
    },

    selectCategory(category) {
      this.selectedCategory = category
      this.scrollIntoView()
    },
    scrollIntoView() {
      this.$nextTick(() => {
        const container = this.$refs.categorySlide
        const selectedCategoryElement = container.querySelector(".selected")
        const lastIndex = this.categories.length - 2

        if (this.selectedCategory === "all" && container) {
          container.scrollTo({ left: 0, behavior: "smooth" })
        } else if (selectedCategoryElement) {
          const scrollOptions = {
            behavior: "smooth",
            block: "nearest",
            inline: "center",
          }

          selectedCategoryElement.scrollIntoView(scrollOptions)

          if (this.selectedCategory === this.categories[lastIndex].type && container) {
            container.scrollTo({ left: container.scrollWidth, behavior: "smooth" })
          }
        }
      })
    },
  },
  mounted() {
    window.addEventListener("message", this.handleMessage)
    window.addEventListener("keyup", this.handleKeyup)
    this.initShopData()
  },
  unmounted() {
    window.removeEventListener("message", this.handleMessage)
    window.removeEventListener("keyup", this.handleKeyup)
  },
}

/*global GetParentResourceName*/
/*eslint no-undef: "error"*/
</script>

<template>
  <transition name="fade">
    <div v-if="showShop || debugMode" id="app">
      <div class="shop">
        <div class="container">
          <div class="left">
            <div class="top">
              <div class="header">
                <div class="title">
                  {{ locales.mainTitle }}
                  <span class="tag">{{ locales.mainTag }}</span>
                </div>
                <p class="description" v-html="locales.mainDescription"></p>
              </div>
              <div class="categories">
                <div class="category-slide" ref="categorySlide">
                  <div
                    v-for="(category, index) in categories"
                    :key="index"
                    class="category"
                    @click="selectCategory(category.type)"
                    :class="{ selected: selectedCategory === category.type }"
                  >
                    <div class="icon-holder">
                      <Icon :icon="category.icon" />
                    </div>
                    <div class="name-holder">
                      <p class="category-name">{{ category.name }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="items">
              <div v-for="item in filteredItems" :key="item.name">
                <div v-if="selectedCategory === 'all' || selectedCategory === item.category" class="item">
                  <div class="front">
                    <div class="image-wrapper">
                      <img :src="getImageSrc(item.name)" draggable="false" />
                    </div>
                    <div class="info">
                      <p class="item-label">{{ item.label }}</p>
                      <div class="item-price">{{ formatPrice(item.price) }}</div>
                    </div>
                    <div class="add-to-cart" @click="addToCart(item.name)">{{ locales.addCart }}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="right">
            <div class="cart">
              <div class="header">
                <div class="title">
                  {{ locales.cartTitle }}
                  <span class="tag">{{ locales.cartTag }}</span>
                </div>
                <p class="description" v-html="locales.cartDescription"></p>
              </div>
              <div class="cart-items">
                <div v-if="cart.length === 0" class="no-cart">
                  <Icon icon="mdi:shopping-basket-off" />
                </div>
                <div class="item-list">
                  <div v-for="(item, index) in cart" :key="item.name" class="item">
                    <div class="front">
                      <img :src="getImageSrc(item.name)" draggable="false" />
                      <div class="text-container">
                        <p class="item-label">{{ item.label }}</p>
                        <span class="item-price">{{ formatPrice(item.price) }}</span>
                      </div>
                      <div class="button-container">
                        <div class="decrement" @click="decrementQuantity(index)">
                          <Icon class="icon" icon="typcn:minus" />
                        </div>
                        <input
                          class="counter"
                          type="text"
                          minlength="1"
                          maxlength="3"
                          :placeholder="item.quantity"
                          v-model.number="item.quantity"
                          @keydown="validateNumberInput"
                          @blur="validateQuantityInput(index)"
                        />
                        <div class="increment" @click="incrementQuantity(index)">
                          <Icon class="icon" icon="typcn:plus" />
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="payment">
                <p class="payment-title">{{ locales.paymentTitle }}</p>
                <span class="price">{{ formatPrice(totalPrice) }}</span>
                <div class="pay">
                  <button class="button" @click="payCart('bank')"><Icon icon="mingcute:bank-card-fill" /> {{ locales.payBank }}</button>
                  <button class="button" @click="payCart('cash')"><Icon icon="mdi:wallet" /> {{ locales.payCash }}</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<style lang="scss">
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

$debugMode: false;
body {
  @if $debugMode ==true {
    background-image: url(@/assets/evening-bg.png);
    background-size: cover;
    background-repeat: no-repeat;
  }

  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
  image-rendering: optimizeQuality;

  -webkit-user-drag: none;
  user-select: none;

  overflow: hidden;
  overflow-wrap: break-word;
  word-wrap: break-word;
  white-space: pre-wrap;
  margin: 0;
  padding: 0;
}

*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
.fade-leave-from,
.fade-enter-to {
  opacity: 1;
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
  background: rgba(10, 10, 10, 0.93);

  .container {
    position: relative;
    display: flex;
    flex-direction: row;
    width: 100vw;
    height: 100vh;
    padding: 8vh;
    color: white;
    gap: 0.5vh;
    justify-content: space-between;

    .left {
      display: flex;
      flex-direction: column;
      width: 70%;
      height: 100%;
      gap: 2vh;

      .top {
        display: flex;
        flex-direction: column;
        width: 100%;
        height: fit-content;

        .header {
          position: relative;
          text-align: left;

          .title {
            font-family: "PFDinDisplayPro-Bold", sans-serif;
            color: white;
            font-size: 1.8rem;
            letter-spacing: 0.06em;
            display: flex;
            align-items: center;
            text-transform: uppercase;

            .tag {
              font-family: "PFDinDisplayPro-Medium", sans-serif;
              background-color: #3f3f3f;
              color: rgba(255, 255, 255, 0.8);
              font-size: 1.1rem;
              letter-spacing: 0;
              padding: 0.7vh 1.7vh;
              border-radius: 0.3vh;
            }
          }

          .description {
            margin-top: 0.5vh;
            color: rgba(255, 255, 255, 0.5);
            line-height: 1.4rem;
            font-size: 1rem;
          }
        }

        .categories {
          display: flex;
          overflow: hidden;
          gap: 1vh;
          width: 100%;
          margin-top: 1vh;

          .category-slide {
            display: flex;
            overflow: auto;
            overflow-x: auto;
            white-space: nowrap;
            scroll-behavior: smooth;
            width: fit-content;
            max-width: 100%;
            gap: 1.9vh;
            padding: 1vh 1vh 1.75vh 0;

            .category {
              flex-shrink: 0;
              display: flex;
              justify-content: flex-start;
              align-items: center;
              gap: 0.75vh;
              align-items: stretch;
              width: fit-content;
              height: fit-content;
              font-size: 0.85rem;
              color: rgba(255, 255, 255, 0.8);
              transition: 0.25s background-color;
              cursor: pointer;

              &:hover,
              &.selected {
                .icon-holder,
                .name-holder {
                  background-color: #ffffff;
                  color: #000000;

                  svg {
                    color: #000000;
                  }
                }
              }

              .icon-holder {
                display: flex;
                justify-content: center;
                align-items: center;
                width: 5.5vh;
                height: auto;
                border-radius: 0.5vh;
                background-color: #1e1e1e;
                transition: 0.25s background-color;

                svg {
                  width: 45%;
                  height: auto;
                  color: #ffffff;
                }
              }

              .name-holder {
                text-align: center;
                background-color: #1e1e1e;
                padding: 2vh 2.75vh;
                border-radius: 0.5vh;
                transition: 0.25s background-color;

                .category-name {
                  font-family: "PFDinDisplayPro-Bold", sans-serif;
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
              height: 0.5vh;
            }
          }
        }
      }

      .items {
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
          background-color: #1e1e1e;
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
                color: #66f96f;
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
              background-color: #2f3030;
              color: #fff;
              transition:
                0.25s background-color,
                0.25s box-shadow;

              &:hover {
                background-color: #fff;
                box-shadow: 0vh 0.4vh 2.3vh rgba(255, 255, 255, 0.35);
                color: #000000;
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
    }

    .right {
      display: flex;
      flex-direction: column;
      width: 27.5%;
      height: 100%;
      gap: 0.5vh;

      .cart {
        position: relative;
        height: 100%;
        width: 100%;
        display: flex;
        flex-direction: column;
        font-family: "PFDinDisplayPro-Bold", sans-serif;
        gap: 2vh;

        .header {
          position: relative;
          text-align: right;

          .title {
            font-family: "PFDinDisplayPro-Bold", sans-serif;
            color: white;
            font-size: 1.8rem;
            letter-spacing: 0.06em;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            text-transform: uppercase;

            .tag {
              font-family: "PFDinDisplayPro-Medium", sans-serif;
              background-color: #3f3f3f;
              color: rgba(255, 255, 255, 0.8);
              font-size: 1.1rem;
              letter-spacing: 0;
              padding: 0.7vh 1.7vh;
              border-radius: 0.3vh;
            }
          }

          .description {
            margin-top: 0.5vh;
            color: rgba(255, 255, 255, 0.5);
            line-height: 1.4rem;
            font-size: 1rem;
          }
        }

        .cart-items {
          height: 100%;

          .item-list {
            overflow: overlay;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            scrollbar-gutter: stable;
            scroll-behavior: smooth;
            height: 100%;
            max-height: 59vh;
            gap: 1vh;

            .item {
              flex-shrink: 0;
              position: relative;
              width: 96%;
              height: 6.5vh;
              background-color: #1e1e1e;
              border-radius: 0.5vh;
              display: flex;
              align-items: center;
              padding: 1.5vh;

              .front {
                display: flex;
                flex: 1;
                align-items: center;
                justify-content: space-between;
                height: 100%;
                font-family: "PFDinDisplayPro-Medium", sans-serif;

                img {
                  width: 6.25vh;
                  height: auto;
                  padding-right: 1.75vh;
                  object-fit: contain;
                }

                .text-container {
                  display: flex;
                  flex: 1;
                  flex-direction: row;
                  align-items: center;
                  gap: 1vh;

                  .item-label {
                    width: 10vh;
                    text-align: left;
                    font-size: 0.9rem;
                    color: rgba(255, 255, 255, 0.8);
                  }

                  .item-price {
                    font-size: 0.9rem;
                    color: #66f96f;
                    text-shadow: 0 0 1.19vh rgba(102, 249, 111, 0.5);
                  }
                }

                .button-container {
                  display: flex;
                  flex-direction: row;
                  align-items: center;
                  gap: 1.5vh;

                  .counter {
                    all: unset;
                    box-sizing: border-box;
                    font-size: 0.85rem;
                    color: #fff;
                    text-align: center;
                    width: auto;
                    height: auto;
                    min-width: 1ch;
                    max-width: 3ch;
                  }

                  .decrement,
                  .increment {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    width: 3.25vh;
                    height: 3.25vh;
                    font-size: 0.85rem;
                    border-radius: 0.65vh;
                    background-color: #2f3030;
                    color: #fff;
                    transition:
                      0.25s background-color,
                      0.25s box-shadow;

                    &:hover {
                      background-color: #fff;
                      box-shadow: 0 0.37vh 1.74vh rgba(255, 255, 255, 0.733);
                      color: #000000;
                      cursor: pointer;
                    }
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

          .no-cart {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            width: 100%;
            font-size: 7.5rem;
            color: rgba(255, 255, 255, 0.15);
          }
        }
      }

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
          color: #ffffff;
        }

        .price {
          overflow: auto;
          width: 100%;
          height: fit-content;
          font-family: "PFDinDisplayPro-Bold", sans-serif;
          font-size: 3rem;
          letter-spacing: 0;
          color: #66f96f;
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
            color: #fff;
            background-color: #2f3030;
            font-family: "PFDinDisplayPro-Bold", sans-serif;
            font-size: 0.88rem;
            transition: 0.25s background-color;
            gap: 0.5vh;

            svg {
              width: 2.25vh;
              height: auto;
              color: #ffffff;
            }

            &:hover {
              background-color: #ffffff;
              color: #000000;
              cursor: pointer;

              svg {
                color: #000000;
              }
            }
          }
        }
      }
    }
  }
}
</style>
