# 🎯 CleverTap Product Experiences - Credit Card App Demo Guide

## Quick Test Scenarios

### 🥇 Scenario 1: Premium Gold (Default)

**Use Case**: Standard customer experience
**Card Type**: `Premium Gold`
**Theme**: Gold gradient with dark header

```json
{
  "app_theme": {
    "headerGradientTopHex": "#1A1A2E",
    "headerGradientBottomHex": "#16213E",
    "cardGradientTopHex": "#FFD700",
    "cardGradientBottomHex": "#FFB800",
    "iconTintHex": "#FFD700",
    "buttonColorHex": "#FFD700",
    "textColorHex": "#000000"
  },
  "credit_card_details": {
    "cardType": "Premium Gold",
    "cardNumber": "**** **** **** 5678",
    "creditLimit": "₹5,00,000",
    "availableCredit": "₹3,75,000",
    "rewardPoints": "12,450"
  }
}
```

---

### 🥈 Scenario 2: Platinum Elite

**Use Case**: High-value customer with premium benefits
**Card Type**: `Platinum Elite`
**Theme**: Silver/Gray gradient

```json
{
  "app_theme": {
    "headerGradientTopHex": "#2C3E50",
    "headerGradientBottomHex": "#34495E",
    "cardGradientTopHex": "#BDC3C7",
    "cardGradientBottomHex": "#95A5A6",
    "iconTintHex": "#7F8C8D",
    "buttonColorHex": "#7F8C8D",
    "textColorHex": "#000000"
  },
  "credit_card_details": {
    "cardType": "Platinum Elite",
    "cardNumber": "**** **** **** 9012",
    "creditLimit": "₹10,00,000",
    "availableCredit": "₹8,50,000",
    "rewardPoints": "25,890"
  }
}
```

---

### ⚫ Scenario 3: Black Exclusive (VIP)

**Use Case**: Ultra-premium VIP customers
**Card Type**: `Black Exclusive`
**Theme**: Black card with gold accents

```json
{
  "app_theme": {
    "headerGradientTopHex": "#000000",
    "headerGradientBottomHex": "#1C1C1C",
    "cardGradientTopHex": "#2C2C2C",
    "cardGradientBottomHex": "#1A1A1A",
    "iconTintHex": "#FFD700",
    "buttonColorHex": "#FFD700",
    "textColorHex": "#000000"
  },
  "credit_card_details": {
    "cardType": "Black Exclusive",
    "cardNumber": "**** **** **** 3456",
    "creditLimit": "₹25,00,000",
    "availableCredit": "₹22,00,000",
    "rewardPoints": "1,05,670"
  }
}
```

---

### 🔴 Scenario 4: Low Credit Alert

**Use Case**: User with low available credit (promote payment)
**Card Type**: `Premium Gold`
**Theme**: Red alert theme

```json
{
  "app_theme": {
    "headerGradientTopHex": "#7F1D1D",
    "headerGradientBottomHex": "#991B1B",
    "cardGradientTopHex": "#DC2626",
    "cardGradientBottomHex": "#B91C1C",
    "iconTintHex": "#EF4444",
    "buttonColorHex": "#DC2626",
    "textColorHex": "#000000"
  },
  "credit_card_details": {
    "cardType": "Premium Gold",
    "cardNumber": "**** **** **** 5678",
    "creditLimit": "₹5,00,000",
    "availableCredit": "₹25,000",
    "rewardPoints": "3,450"
  }
}
```

---

### 🔵 Scenario 5: Royal Blue Variant

**Use Case**: A/B testing different color schemes
**Card Type**: `Titanium Plus`
**Theme**: Royal blue gradient

```json
{
  "app_theme": {
    "headerGradientTopHex": "#1E3A8A",
    "headerGradientBottomHex": "#1E40AF",
    "cardGradientTopHex": "#3B82F6",
    "cardGradientBottomHex": "#2563EB",
    "iconTintHex": "#60A5FA",
    "buttonColorHex": "#3B82F6",
    "textColorHex": "#000000"
  },
  "credit_card_details": {
    "cardType": "Titanium Plus",
    "cardNumber": "**** **** **** 7890",
    "creditLimit": "₹15,00,000",
    "availableCredit": "₹12,75,000",
    "rewardPoints": "45,230"
  }
}
```

---

## 🖼️ Banner Images for Testing

### Credit Card Promotions

```json
{
  "Banner": {
    "Banner Image 1": "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80",
    "Banner Image 2": "https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&q=80",
    "Banner Image 3": "https://images.unsplash.com/photo-1591085686350-798c0f9faa7f?w=800&q=80"
  }
}
```

### Travel Rewards

```json
{
  "Banner": {
    "Banner Image 1": "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80",
    "Banner Image 2": "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=80",
    "Banner Image 3": "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80"
  }
}
```

### Shopping Deals

```json
{
  "Banner": {
    "Banner Image 1": "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80",
    "Banner Image 2": "https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=800&q=80",
    "Banner Image 3": "https://images.unsplash.com/photo-1534452203293-494d7ddbf7e0?w=800&q=80"
  }
}
```

---

## 📋 How to Use in CleverTap Dashboard

1. **Go to Product Experiences** → Variables
2. **Find your variable groups**: `Banner`, `app_theme`, `credit_card_details`
3. **Copy values** from scenarios above
4. **Paste into dashboard** fields
5. **Save & Publish**
6. **In the app**, tap "Refresh Config from Dashboard" button

---

## 🎭 Demo Flow for Customer Presentation

### Part 1: Basic Personalization (5 minutes)

1. **Start**: Show Scenario 1 (Premium Gold - default state)
2. **Update**: Switch to Scenario 2 (Platinum Elite) in dashboard
3. **Refresh**: Click refresh button in app
4. **Result**: Show how card type, limits, and theme change instantly

### Part 2: VIP Experience (3 minutes)

1. **Update**: Switch to Scenario 3 (Black Exclusive)
2. **Refresh**: Show the dramatic change to black card
3. **Highlight**: Point out the 25L limit and 1L+ reward points

### Part 3: Contextual Messaging (3 minutes)

1. **Update**: Switch to Scenario 4 (Low Credit Alert)
2. **Refresh**: Show red theme indicating urgency
3. **Explain**: How this prompts users to pay their bills

### Part 4: A/B Testing (2 minutes)

1. **Update**: Switch to Scenario 5 (Royal Blue)
2. **Explain**: How different color schemes can be A/B tested
3. **Discuss**: Measuring engagement and conversion

### Part 5: Dynamic Content (2 minutes)

1. **Add banners**: Use any banner set above
2. **Refresh**: Show carousel with promotional images
3. **Explain**: How banners can be personalized per segment

---

## 💡 Personalization Ideas for Customer

### By User Segment

- **High Spenders** → Black Exclusive theme + Travel banners
- **Shopping Enthusiasts** → Shopping deals banners
- **Low Credit Users** → Red theme + Payment reminders
- **New Users** → Premium Gold + Onboarding banners
- **Travel Lovers** → Travel rewards banners

### By User Behavior

- **Missed Payment** → Red alert theme + "Pay Now" banner
- **High Reward Points** → Special redemption offers
- **Card Upgrade Eligible** → Platinum/Black card preview
- **Seasonal** → Festive themes and offers

### By Location

- **Metro Cities** → Premium cards with lifestyle benefits
- **Tier 2/3 Cities** → Focus on cashback and savings

---

## 🎨 Additional Color Themes

### Emerald Green

```
headerGradientTopHex: #065F46
headerGradientBottomHex: #047857
cardGradientTopHex: #10B981
cardGradientBottomHex: #059669
iconTintHex: #34D399
buttonColorHex: #10B981
```

### Rose Gold

```
headerGradientTopHex: #9F1239
headerGradientBottomHex: #BE123C
cardGradientTopHex: #FDA4AF
cardGradientBottomHex: #FB7185
iconTintHex: #F43F5E
buttonColorHex: #E11D48
```

### Purple Luxury

```
headerGradientTopHex: #581C87
headerGradientBottomHex: #6B21A8
cardGradientTopHex: #A855F7
cardGradientBottomHex: #9333EA
iconTintHex: #C084FC
buttonColorHex: #A855F7
```

---

## 🔧 Troubleshooting

**Variables not updating?**

- Ensure you've called `CleverTapPlugin.syncVariables()` (line 92 in code)
- Check CleverTap dashboard is published
- Tap "Refresh Config from Dashboard" button

**Colors not showing correctly?**

- Verify hex codes include the `#` symbol
- Ensure 6-character hex format (e.g., #FFD700)
- Check for typos in variable names

**Banners not loading?**

- Verify image URLs are accessible
- Check internet connection
- Look for errors in console logs

---

## 📊 Key Metrics to Track

- **Engagement Rate**: How many users interact after theme changes
- **Conversion Rate**: Payment completion rates for different themes
- **Time to Payment**: How quickly users pay after red alert theme
- **Banner Click Rate**: Which banner images get most clicks
- **A/B Test Results**: Which color scheme performs better

---

**For more details, see:** `PRODUCT_EXPERIENCE_SAMPLES.json`
