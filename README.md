<p align="center">
  <img src="Accounting/Assets.xcassets/AppIcon.appiconset/Icon60@3x.png" alt="Bi Finance Logo" width="120" />
</p>

<h1 align="center">Bi Finance (筆財務)</h1>

<p align="center">
  <b>A lightweight, full-featured personal accounting app for iOS, Apple Watch & Today Widget</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2010%2B-lightgrey?logo=apple" />
  <img src="https://img.shields.io/badge/language-Objective--C-orange" />
  <img src="https://img.shields.io/badge/watch-watchOS-blue?logo=apple" />
  <img src="https://img.shields.io/badge/widget-Today%20Extension-green" />
  <img src="https://img.shields.io/badge/data-Core%20Data-purple" />
  <img src="https://img.shields.io/badge/charts-Charts%203.x-red" />
  <img src="https://img.shields.io/badge/icons-FontAwesome-339AF0" />
  <img src="https://img.shields.io/badge/App%20Store-1331031395-0D96F6?logo=app-store" />
</p>

<p align="center">
  <a href="README-zh-HK.md">繁體中文（香港）版本</a>
</p>

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Features](#features)
  - [💰 Income \& Expense Tracking](#-income--expense-tracking)
  - [🏷️ Categories](#️-categories)
  - [🔖 Tags](#-tags)
  - [📊 Visual Reports \& Pie Chart](#-visual-reports--pie-chart)
  - [📅 Flexible Date Filtering](#-flexible-date-filtering)
  - [💵 Monthly Budget](#-monthly-budget)
  - [⌚ Apple Watch App](#-apple-watch-app)
  - [📱 Today Widget (Notification Center)](#-today-widget-notification-center)
  - [⚙️ Settings](#️-settings)
  - [🌐 Localization](#-localization)
  - [🔒 Data Safety](#-data-safety)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
  - [Data Flow](#data-flow)
  - [Key Architectural Decisions](#key-architectural-decisions)
- [Project Structure](#project-structure)
- [Core Data Model](#core-data-model)
  - [Accounting (Transaction)](#accounting-transaction)
  - [Category](#category)
  - [Tag](#tag)
- [Targets \& Extensions](#targets--extensions)
- [Custom UI Components](#custom-ui-components)
  - [RMSPieView](#rmspieview)
  - [RMSSlider](#rmsslider)
  - [NumberPad](#numberpad)
  - [TransactionTableViewCell](#transactiontableviewcell)
  - [EmptyInfoTableViewCell](#emptyinfotableviewcell)
- [Default Categories](#default-categories)
- [Theming \& Color Scheme](#theming--color-scheme)
- [Localization](#localization)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Build \& Test](#build--test)
- [Dependencies](#dependencies)
- [Contributing](#contributing)

---

## Overview

**Bi Finance** is a personal accounting iOS application developed in **Objective-C** by [RM Studio](https://blogrms.wordpress.com). It helps users track daily income and expenses through an intuitive interface with category management, tag labeling, monthly budgets, and visual pie-chart summaries.

The project ships with three companion targets:

| Target | Description |
|--------|-------------|
| **Accounting** (iOS App) | Main app — full transaction management, budgets, charts, settings |
| **AccountingToday** (Today Widget) | Quick-entry widget with numeric pad and category buttons |
| **AccountingWatch** (watchOS App + Extension) | Wrist-based category selection and amount entry, synced in real time |

All targets share data through **App Groups** (`group.org.rm-s.accounting`) and a shared **Core Data** persistent container.

---

## Features

### 💰 Income & Expense Tracking
- Record transactions with precise decimal amounts (up to 10 integer digits, 2 decimal places)
- Classify each entry as **Income** or **Expenses**
- Attach a comment / note to any transaction
- Edit or delete existing records

### 🏷️ Categories
- Pre-loaded default categories with emoji icons (Food 🍱, Education 🎓, Commute 🚌, Wages 💰, Entertainment 🎮, etc.)
- Create custom categories with your own name, icon, and type
- Reorder categories by sequence
- Categories sync to Apple Watch automatically via WatchConnectivity

### 🔖 Tags
- Create and manage colored tags
- Assign multiple tags to a single transaction for flexible labeling
- Tag management UI in Settings

### 📊 Visual Reports & Pie Chart
- Animated **pie chart** breakdown of spending by category (custom `RMSPieView`)
- Toggle between pie chart and transaction list
- Color-coded segments matching category colors

### 📅 Flexible Date Filtering
- Custom date picker supporting **monthly**, **yearly**, and **all-time** views
- 90-year selectable range starting from 2010
- Transaction list grouped by date or by category type

### 💵 Monthly Budget
- Set a monthly spending limit
- Real-time **progress bar** tracking actual vs. budgeted spending
- Color-coded indicators:
  - 🟢 Green: < 50 % spent
  - 🟡 Yellow: 50 – 75 % spent
  - 🟠 Orange: > 75 % spent

### ⌚ Apple Watch App
- Browse synced categories on your wrist
- Enter amounts with a custom **10-key number pad**
- One-tap transaction creation sent to the iPhone in real time
- Visual feedback: wait → success / fail status

### 📱 Today Widget (Notification Center)
- **Compact mode**: tap to launch the main app
- **Expanded mode**: full numeric keypad + top-5 category buttons for instant logging
- Shared Core Data — entries created from the widget appear immediately in the main app

### ⚙️ Settings
- Manage categories and tags
- Set monthly budget
- Rate the app on the App Store
- Share the app with friends
- About page (RM Studio blog in a web view)

### 🌐 Localization
- English and Simplified Chinese UI strings
- Storyboard-level and runtime localization via `.strings` files

### 🔒 Data Safety
- All data stored locally on-device via Core Data
- Shared across targets through an App Group container
- No external network calls for user data (only the About page loads a blog URL)

---

## Screenshots


<p align="center">
  <img src="docs/images/Image_20260501131704_78_6.jpg" alt="Screenshot 1" style="max-width:18%;height:auto;margin:0 4px" />
  <img src="docs/images/Image_20260501131704_79_6.jpg" alt="Screenshot 2" style="max-width:18%;height:auto;margin:0 4px" />
  <img src="docs/images/Image_20260501131704_80_6.jpg" alt="Screenshot 3" style="max-width:18%;height:auto;margin:0 4px" />
  <img src="docs/images/Image_20260501131704_81_6.jpg" alt="Screenshot 4" style="max-width:18%;height:auto;margin:0 4px" />
  <img src="docs/images/Image_20260501131705_82_6.jpg" alt="Screenshot 5" style="max-width:18%;height:auto;margin:0 4px" />
</p>


---

## Architecture

The project follows a classic **MVC (Model-View-Controller)** pattern:

```
┌───────────────────────────────────────────────────────────┐
│                        App Group                          │
│              group.org.rm-s.accounting                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Shared Core Data Store                 │  │
│  │  (Accounting, Category, Tag entities)               │  │
│  └────────┬──────────────┬──────────────┬──────────────┘  │
│           │              │              │                  │
│     ┌─────▼─────┐  ┌────▼────┐  ┌──────▼───────┐         │
│     │  iOS App  │  │ Widget  │  │  Watch Ext   │         │
│     │  (MVC)    │  │ (Today) │  │  (WCSession) │         │
│     └───────────┘  └─────────┘  └──────────────┘         │
└───────────────────────────────────────────────────────────┘
```

### Data Flow

```
iPhone ──WCSession──► Watch
  │                     │
  ▼                     ▼
Core Data           sendMessage
  │               (create_item)
  ▼                     │
Shared Container ◄──────┘
  │
  ▼
Today Widget
```

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **App Groups** | Unified Core Data store shared by all 3 targets |
| **WatchConnectivity** | Real-time bidirectional sync (categories → Watch, transactions → iPhone) |
| **Delegate pattern** | `TransactionDelegate`, `DatePickerDelegate`, `TagDelegate` encapsulate complex table/picker logic |
| **Category extensions** | `CALayer+Addition`, `UIImage+UIImageExtras`, `UIControl+UIButton` for reusable UI helpers |
| **Plist-driven defaults** | `DefaultCategory.plist` seeds first-boot data; `ColorScheme.plist` for theming |
| **NSDecimalNumber** | Precise currency arithmetic — no floating-point rounding errors |

---

## Project Structure

```
rms-accounting/
├── Podfile                              # CocoaPods dependencies
├── Accounting/                          # ── Main iOS App ──
│   ├── AppDelegate.{h,m}               # App lifecycle, Core Data stack, WCSession
│   ├── main.m                          # Entry point
│   ├── Info.plist                      # Bundle config (display name: "Bi")
│   ├── Accounting.entitlements         # App Group entitlement
│   ├── Config Files/
│   │   ├── DefaultCategory.plist       # Seed categories on first launch
│   │   └── ColorScheme.plist           # Theme colors
│   ├── Controllers/
│   │   ├── ViewController.{h,m}              # Home: summary, pie chart, transactions
│   │   ├── KeepAccountsViewController.{h,m}  # Add / edit transaction
│   │   ├── CategoryViewController.{h,m}      # Category management
│   │   ├── TagSettingViewController.{h,m}     # Tag management
│   │   ├── TagViewController.{h,m}           # Tag selection
│   │   ├── NoteViewController.{h,m}          # Transaction comment editor
│   │   ├── SettingViewController.{h,m}       # App settings
│   │   └── AboutUsViewController.{h,m}       # About page (web view)
│   ├── Models/
│   │   ├── BaseModel.{h,m}            # Shared Core Data helpers
│   │   ├── AccountingModel.{h,m}      # Transaction CRUD & queries
│   │   ├── CategoryModel.{h,m}        # Category CRUD & type filtering
│   │   └── TagModel.{h,m}             # Tag CRUD
│   ├── Entities/                       # Core Data generated classes
│   │   ├── Accounting+CoreData{Class,Properties}.{h,m}
│   │   ├── Category+CoreData{Class,Properties}.{h,m}
│   │   └── Tag+CoreData{Class,Properties}.{h,m}
│   ├── Delegate/
│   │   ├── TransactionDelegate.{h,m}  # Transaction table data source
│   │   ├── DatePickerDelegate.{h,m}   # Custom date picker logic
│   │   └── TagDelegate.{h,m}          # Tag table data source
│   ├── Views/
│   │   ├── RMSPieView.{h,m}           # Animated pie chart
│   │   ├── RMSSlider.{h,m}            # Drag-to-confirm slider
│   │   ├── TransactionTableViewCell    # Transaction row cell
│   │   └── EmptyInfoTableViewCell      # Empty-state placeholder
│   ├── Services/
│   │   ├── BudgetManager.{h,m}        # Monthly budget get/set
│   │   ├── NumberPad.{h,m}            # Numeric input handler
│   │   └── Utils.{h,m}               # Device detection, date math, helpers
│   ├── Supporting Files/
│   │   ├── fontawesome-webfont.ttf     # FontAwesome icons
│   │   ├── CALayer+Addition.{h,m}     # Border color helper
│   │   ├── UIImage+UIImageExtras.{h,m}# Image scaling
│   │   └── UIControl+UIButton.{h,m}   # Associated object storage
│   ├── en.lproj/                       # English localization
│   └── zh-Hans.lproj/                  # Simplified Chinese localization
│
├── AccountingToday/                     # ── Today Widget ──
│   ├── TodayViewController.{h,m}       # Compact + expanded numeric pad
│   ├── Info.plist
│   └── AccountingToday.entitlements
│
├── AccountingWatch/                     # ── watchOS App ──
│   ├── Info.plist
│   ├── Assets.xcassets/
│   └── Base.lproj/
│
├── AccountingWatch Extension/           # ── watchOS Extension ──
│   ├── InterfaceController.{h,m}       # Category list, WCSession sync
│   ├── NumberPadController.{h,m}       # Watch number pad
│   ├── CategoryRow.{h,m}              # Watch table row
│   ├── ExtensionDelegate.{h,m}        # Watch app lifecycle
│   └── NotificationController.{h,m}   # Push notification handler
│
├── AccountingTests/                     # Unit tests
└── AccountingUITests/                   # UI tests
```

---

## Core Data Model

Three entities persisted in a shared `NSPersistentContainer`:

### Accounting (Transaction)

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | String | UUID |
| `amount` | Decimal | Transaction value |
| `category` | String | Category name |
| `comment` | String | User note |
| `tags` | String | Comma-separated tag names |
| `create_time` | Date | Transaction date |
| `currency` | String | Currency code |
| `user_id` | String | User reference |
| `last_sync_time` | Date | Sync timestamp |

### Category

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | String | Display name |
| `icon` | String | Emoji icon |
| `alias` | String | Alternative name |
| `type` | String | `"Income"` or `"Expenses"` |
| `sequence` | Int16 | Sort order |

### Tag

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | String | Tag label |
| `color` | Int32 | Color value |
| `sequence` | Int16 | Sort order |

---

## Targets & Extensions

| Target | Platform | Purpose | Shared Data |
|--------|----------|---------|-------------|
| **Accounting** | iOS 10+ | Main app | Core Data via App Group |
| **AccountingToday** | iOS 10+ | Today Widget — quick entry | Core Data via App Group |
| **AccountingWatch** | watchOS | Watch UI storyboard | — |
| **AccountingWatch Extension** | watchOS | Watch logic + WCSession | Messages via WatchConnectivity |

---

## Custom UI Components

### RMSPieView
An animated pie chart drawn with `UIBezierPath` and `CAShapeLayer`. Accepts an array of values and renders proportional color segments with smooth animation.

### RMSSlider
A drag-to-confirm slider control (similar to "Slide to Unlock"). The user drags a handle to confirm the transaction — prevents accidental submissions.

### NumberPad
A shared numeric input engine used by the main app, Today Widget, and Watch Extension. Enforces:
- Max 10 integer digits
- Max 2 decimal places
- Proper decimal point handling
- Backspace support

### TransactionTableViewCell
Displays a single transaction row with the category emoji, category name, amount (color-coded: green for income, red for expense), and date.

### EmptyInfoTableViewCell
A placeholder cell shown when no transactions exist, featuring a FontAwesome icon and a descriptive message.

---

## Default Categories

Loaded from `DefaultCategory.plist` on first launch:

| Icon | Name | Type |
|------|------|------|
| 🍱 | Food | Expenses |
| 🎓 | Education | Expenses |
| 🚌 | Commute | Expenses |
| 💰 | Wages | Income |
| 🎮 | Entertainment | Expenses |
| 🍸 | Social | Expenses |
| ⚽️ | Sport | Expenses |
| ✈️ | Travel | Expenses |
| 🎁 | Gift | Expenses |

Users can add, edit, reorder, and delete categories at any time from Settings.

---

## Theming & Color Scheme

Configured via `ColorScheme.plist` and runtime constants:

| Element | Color | Hex / RGB |
|---------|-------|-----------|
| Primary / Navigation | Dark Navy | `#2B314D` |
| Accent / Selection | Dark Cyan | `#008B8B` |
| Income amount | Green | `rgb(0, 201, 87)` |
| Expense amount | Red | `rgb(255, 0, 0)` |
| Budget < 50 % | Green | Standard system |
| Budget 50 – 75 % | Yellow | Standard system |
| Budget > 75 % | Orange | Standard system |

Icons are rendered with **FontAwesome 4.7** (bundled `fontawesome-webfont.ttf`).

---

## Localization

| Language | Folder | Scope |
|----------|--------|-------|
| English | `en.lproj/` | Interface + strings |
| Simplified Chinese | `zh-Hans.lproj/` | Interface + strings |

Storyboard strings are in `Main.strings`; runtime strings are in `Localizable.strings`. Contributions for additional languages are welcome.

---

## Requirements

| Requirement | Version |
|-------------|---------|
| macOS | 10.13+ |
| Xcode | 10+ (recommended 12+) |
| iOS Deployment Target | 10.0 |
| CocoaPods | 1.x |
| Swift / ObjC | Objective-C |

---

## Getting Started

```bash
# 1. Clone
git clone https://github.com/<your-username>/rms-accounting.git
cd rms-accounting

# 2. Install pods
pod install

# 3. Open workspace (NOT .xcodeproj)
open Accounting.xcworkspace
```

Select the **Accounting** scheme and run on a simulator or device.

> **Note**: To run the Watch app, select the **AccountingWatch** scheme and pair with a Watch simulator.

---

## Build & Test

```bash
# Build (simulator)
xcodebuild -workspace Accounting.xcworkspace \
  -scheme Accounting \
  -configuration Debug \
  -sdk iphonesimulator \
  build

# Run unit tests
xcodebuild test \
  -workspace Accounting.xcworkspace \
  -scheme Accounting \
  -destination 'platform=iOS Simulator,name=iPhone 14'

# Run UI tests
xcodebuild test \
  -workspace Accounting.xcworkspace \
  -scheme AccountingUITests \
  -destination 'platform=iOS Simulator,name=iPhone 14'
```

---

## Dependencies

Managed via **CocoaPods** (`Podfile`):

| Pod | Version | Purpose |
|-----|---------|---------|
| [Charts](https://github.com/danielgindi/Charts) | ~> 3.0.5 | Charting library (pie chart data source) |

---

## Contributing

Contributions, issues, and feature requests are welcome!

1. **Fork** the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a **Pull Request**

Please follow the existing Objective-C coding style and write clear commit messages.