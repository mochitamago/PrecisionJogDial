# Precision Jog Dial

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-F05138.svg?style=flat)](https://swift.org)
[![iOS 15.0+](https://img.shields.io/badge/iOS-15.0+-blue.svg?style=flat)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()

A highly customizable, precision rotary dial component for SwiftUI. 

Designed for apps that need precise value scrubbing, **JogDial** features concentric rings for variable drag sensitivity (Coarse, Normal, Fine), a unique "magnifying lens" UI, and snappy haptic feedback.

<video src="https://raw.githubusercontent.com/mochitamago/PrecisionJogDial/main/Screen%20Recording%202026-04-01%20at%2010.41.24.mov" width="300" controls></video>

## ✨ Features

- **Multi-Level Precision:** Configure 1, 2, or 3 concentric rings to allow for coarse, normal, and fine-tuning adjustments.
- **Magnifying Lens UI:** Rings feature a smooth, spring-animated "glass" window that magnifies tick marks when grabbed.
- **Haptic Integration:** Snappy rotational haptics powered by `UIImpactFeedbackGenerator` (can be toggled off).
- **Fully Customizable:** Tweak colors, track widths, tick lengths, and glass opacity via `JogDialStyle`.
- **Custom Labels:** Built-in generic `@ViewBuilder` support so you can inject your own text or icons for each ring.

## 📦 Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## 🛠 Installation

### Swift Package Manager

The preferred way of installing JogDial is via the [Swift Package Manager](https://swift.org/package-manager/).

1. In Xcode, go to **File > Add Package Dependencies...**
2. Paste the repository URL: `https://github.com/mochitamago/precisionjogdial.git` *(Update this if your URL is different)*
3. Choose **Up to Next Major Version** and click Add Package.

## 🚀 Quick Start

Import the module and bind it to a `Float` state variable.

### Basic 1-Level Slider Replacement

If you just need a simple, single-ring rotary dial:

```swift
import SwiftUI
import JogDial

struct BasicExample: View {
    @State private var value: Float = 50.0
    
    var body: some View {
        VStack {
            Text("Value: \(value, specifier: "%.1f")")
            
            JogDialView(
                value: $value,
                range: 0...100,
                levels: 1
            )
            .frame(height: 160)
        }
    }
}
```

### Advanced 3-Level Dial with Custom Labels
For precise scrubbing, enable 3 levels. The outer ring is fine, the middle is normal, and the inner ring is coarse.
```swift
import SwiftUI
import JogDial

struct AdvancedExample: View {
    @State private var value: Float = 120.0
    
    var body: some View {
        JogDialView(
            value: $value,
            range: 0...500,
            levels: 3
        ) { level, isActive in
            // Custom Label Builder
            Text(labelFor(level: level))
                .font(.caption2.weight(.medium))
                .foregroundStyle(isActive ? .cyan : .white.opacity(0.35))
        }
        .frame(height: 160)
    }
    
    private func labelFor(level: Int) -> String {
        switch level {
        case 3: return "FINE"
        case 2: return "NORMAL"
        case 1: return "COARSE"
        default: return ""
        }
    }
}
```

### 🎨 Custom Styling
You can completely change the look of the dial by passing a JogDialStyle configuration.

```swift
let customStyle = JogDialStyle(
    accentColor: .indigo,
    trackColor: .black,
    glassTint: Color.indigo.opacity(0.12),
    maskColor: .black,
    ringWidth: 40,
    ringGap: 6,
    tickLength: 5,
    hapticsEnabled: true
)

JogDialView(
    value: $value, 
    range: 0...100, 
    style: customStyle
)
```

### Style Properties
| Property | Description | Default |
| :--- | :--- | :--- |
| `accentColor` | Color of the active ring, lens ticks, and window frame. | `Color(red: 0.15, green: 0.92, blue: 0.98)` |
| `trackColor` | Color of the inactive track and background elements. | `.white` |
| `glassTint` | Background fill inside the magnifying window. | `accentColor.opacity(0.15)` |
| `maskColor` | Used for the hole punch blend mode. Usually leave as `.black`. | `.black` |
| `ringWidth` | Thickness of the physical hit area and visual baseline. | `44` |
| `ringGap` | Spacing between concentric rings. | `4` |
| `tickLength` | Length of the small tick marks (major ticks are scaled 1.8x). | `6` |
| `hapticsEnabled`| Toggle Taptic Engine feedback. | `true` |

### 📝 License
JogDial is released under the MIT license. See LICENSE for details.
