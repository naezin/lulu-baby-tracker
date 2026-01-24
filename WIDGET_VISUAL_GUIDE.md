# 🎨 Lulu Widget Visual Design Guide

## Overview

This guide provides a visual reference for all Lulu widget variants with exact specifications.

---

## 📐 Widget Dimensions

### iOS
- **Small Widget**: 158×158 pts (2×2 grid)
- **Medium Widget**: 338×158 pts (4×2 grid)
- **Lock Screen Widget**: Accessory Rectangular (varies by device)

### Android
- **Small Widget**: 110×110 dp minimum
- **Medium Widget**: 250×110 dp minimum
- **Resizable**: Horizontal and vertical

---

## 🌙 Small Widget (2×2) - "Next Sweet Spot"

### Layout
```
┌─────────────────────────────┐
│                             │
│        ┌─────────┐          │
│        │  ╱───╲  │          │
│        │ │ 52m │ │          │  ← Circular progress gauge
│        │  ╲───╱  │          │    (Lavender Mist)
│        └─────────┘          │
│                             │
│    Next Sweet Spot          │  ← Label (white 80%)
│                             │
│         14:30               │  ← Time (white 100%)
│                             │
└─────────────────────────────┘
```

### Visual Specs
- **Background**: Midnight Blue gradient (#1A1F3A → #2D3351)
- **Opacity**: 95%
- **Border Radius**: 20dp
- **Progress Ring**:
  - Stroke width: 4dp
  - Color: Lavender Mist (#C7ABE6)
  - Background: White 20%
- **Countdown Text**:
  - Size: 20sp
  - Weight: Bold
  - Color: White 100%
- **Label**:
  - Size: 12sp
  - Color: White 80%
- **Time**:
  - Size: 16sp
  - Weight: SemiBold
  - Color: White 100%

### Data Displayed
- Minutes until next sweet spot (dynamic)
- Progress as percentage (0.0 - 1.0)
- Target time (HH:MM format)

### Interaction
- **Tap**: Opens app to Log Sleep screen
- **Deep Link**: `lulu://sleep`

---

## 📊 Medium Widget (4×2) - "Daily Summary"

### Layout
```
┌────────────────────────────────────────────────────────┐
│  Today          │        Next Sleep                   │
│                 │                                      │
│  🛏️ 12.5h       │         14:30                       │
│                 │                                      │
│  🍼 8×          │        in 52m                        │
│                 │                                      │
│  ✨ 6×          │    [🛏️] [🍼] [✨]                    │
│                 │                                      │
└────────────────────────────────────────────────────────┘
     Left Side              Right Side
```

### Left Side: Today's Summary
- **Header**: "Today" (white 70%, 14sp)
- **Sleep Row**:
  - Icon: 🛏️ (12sp)
  - Text: "12.5h" (white 100%, 16sp bold)
  - Color: Lavender Mist tint
- **Feeding Row**:
  - Icon: 🍼 (12sp)
  - Text: "8×" (white 100%, 16sp bold)
  - Color: Warning Soft tint
- **Diaper Row**:
  - Icon: ✨ (12sp)
  - Text: "6×" (white 100%, 16sp bold)
  - Color: Info Soft tint

### Divider
- Width: 1dp
- Color: White 20%
- Height: Full widget height

### Right Side: Next Action
- **Label**: "Next Sleep" or "Next Feed" (white 70%, 12sp)
- **Time**: "14:30" (white 100%, 22sp bold)
- **Countdown**: "in 52m" (white 80% or red if urgent, 14sp)
- **Action Buttons**:
  - Size: 32×32 dp
  - Background: White 15%
  - Corner radius: 8dp
  - Icons: White 100%, 14sp
  - Spacing: 8dp between buttons

### Data Displayed
- Total sleep hours today
- Total feeding count today
- Total diaper changes today
- Next action type (sleep or feeding)
- Time until next action
- Urgency indicator

### Interaction
- **Sleep Button**: `lulu://sleep`
- **Feeding Button**: `lulu://feeding`
- **Diaper Button**: `lulu://diaper`

---

## 🔒 Lock Screen Widget (iOS Only)

### Layout
```
┌─────────────────────────┐
│ Next Feed               │  ← Label (secondary color, 11sp)
│                         │
│ 02:30                   │  ← Time (primary color, 16sp bold)
└─────────────────────────┘
```

### Visual Specs
- **Style**: Accessory Rectangular
- **Background**: System provided (auto dark/light)
- **Label**:
  - Text: "Next Feed"
  - Size: 11sp
  - Color: Secondary label color
- **Time**:
  - Text: "02:30" (HH:MM format)
  - Size: 16sp
  - Weight: SemiBold
  - Color: Primary label color

### Data Displayed
- Next feeding time only

### Interaction
- **Tap**: Opens app to Log Feeding screen
- **Deep Link**: `lulu://feeding`

---

## 🎨 Color System

### Primary Gradient (Midnight Blue)
```
Start Color:  #1A1F3A  (26, 31, 58)
             rgb(26, 31, 58)

End Color:    #2D3351  (45, 51, 81)
             rgb(45, 51, 81)

Opacity:      95%
Angle:        135° (top-left to bottom-right)
```

### Accent Colors
```
Lavender Mist:    #C7ABE6  (199, 171, 230)
                  Used for: Progress ring, sleep icons

Warning Soft:     #FFD670  (255, 214, 112)
                  Used for: Feeding icons, alerts

Info Soft:        #99D9FF  (153, 217, 255)
                  Used for: Diaper icons, info

Success Soft:     #4CAF50  (76, 175, 80)
                  Used for: Good quality indicators

Error Soft:       #FF7070  (255, 112, 112)
                  Used for: Urgent/overdue states
```

### Text Colors
```
White 100%:  #FFFFFF  (Main text, numbers)
White 80%:   #CCFFFFFF  (Labels, subtitles)
White 70%:   #B3FFFFFF  (Section headers)
White 20%:   #33FFFFFF  (Dividers, backgrounds)
White 15%:   #26FFFFFF  (Button backgrounds)
```

---

## 📏 Spacing & Layout

### Padding
- **Widget container**: 16dp all sides
- **Between sections**: 8-12dp
- **Icon spacing**: 4dp from text
- **Button spacing**: 8dp between buttons

### Corner Radius
- **Widget container**: 20dp
- **Buttons**: 8-12dp
- **Progress ring**: Circular (no corners)

### Typography Scale
```
Display:   22sp  (Next action time)
Title:     18sp  (Widget headers)
Body:      14-16sp  (Main content)
Label:     12-13sp  (Section labels)
Caption:   11sp  (Lock screen label)
```

---

## 🔄 State Variations

### Normal State
- Progress ring: Lavender Mist
- Countdown text: White 80%
- Background: Standard gradient

### Urgent State (< 15 min)
- Countdown text: **Red (#FF7070)**
- Progress ring: Pulsing animation (iOS)
- Border: Subtle red glow

### Overdue State
- Countdown shows negative: "−15m"
- Text color: **Red (#FF7070)**
- Icon: Warning indicator

### No Data State
- Progress: 0%
- Text: "—"
- Message: "Start tracking"

---

## 🌓 Dark Mode (Lock Screen)

The lock screen widget automatically adapts:

### Light Mode Lock Screen
- Background: White/Light gray (system)
- Label: Gray (system secondary)
- Time: Black (system primary)

### Dark Mode Lock Screen
- Background: Black/Dark gray (system)
- Label: Light gray (system secondary)
- Time: White (system primary)

**Note**: iOS handles dark mode automatically. No custom implementation needed.

---

## 📱 Example States

### 1. Sweet Spot Approaching (30 min)
```
Small Widget:
- Progress: 62% filled
- Text: "30m"
- Time: "14:30"
- Color: Normal (white)
```

### 2. Sweet Spot Imminent (5 min)
```
Small Widget:
- Progress: 94% filled
- Text: "5m"
- Time: "14:05"
- Color: Urgent (red pulse)
```

### 3. Sweet Spot Passed
```
Small Widget:
- Progress: 100% filled
- Text: "−10m"
- Time: "13:50"
- Color: Overdue (red)
```

### 4. Active Day
```
Medium Widget Left:
- Sleep: 🛏️ 10.2h
- Feeding: 🍼 7×
- Diaper: ✨ 8×

Right:
- Next Sleep
- 15:30
- in 45m
- [Action buttons visible]
```

---

## 🎯 Design Principles

### 1. **At-a-Glance Readability**
- Large countdown numbers
- High contrast text
- Clear visual hierarchy
- Minimal clutter

### 2. **Consistency**
- Same color system across all widgets
- Consistent spacing and typography
- Unified interaction patterns

### 3. **Accessibility**
- Sufficient text sizes (11sp minimum)
- High contrast ratios (4.5:1+)
- VoiceOver/TalkBack support
- Dynamic type support (iOS)

### 4. **Platform Native**
- Follows iOS/Android design guidelines
- System fonts and colors
- Platform-appropriate animations
- Native widget refresh patterns

---

## 📐 Measurement Reference

### iOS Points to Pixels
- iPhone 14 Pro: 1pt = 3px (3× scale)
- iPhone 14: 1pt = 3px (3× scale)
- iPhone SE: 1pt = 2px (2× scale)

### Android DP to Pixels
- mdpi: 1dp = 1px (1× scale)
- hdpi: 1dp = 1.5px (1.5× scale)
- xhdpi: 1dp = 2px (2× scale)
- xxhdpi: 1dp = 3px (3× scale)
- xxxhdpi: 1dp = 4px (4× scale)

---

## 🎨 Export Specifications

### For Designers

**iOS Widget Mockups:**
- Size: 158×158 pt @ 3× = 474×474 px (Small)
- Size: 338×158 pt @ 3× = 1014×474 px (Medium)
- Format: PNG with transparency
- Color space: sRGB

**Android Widget Mockups:**
- Size: 110×110 dp @ 4× = 440×440 px (Small)
- Size: 250×110 dp @ 4× = 1000×440 px (Medium)
- Format: PNG with transparency
- Color space: sRGB

**Corner Radius:**
- iOS: 20pt system radius (auto-applied)
- Android: 20dp in drawable XML

---

This visual guide ensures pixel-perfect implementation across both platforms while maintaining the glassmorphism aesthetic and Midnight Blue theme that defines Lulu's widget experience.
