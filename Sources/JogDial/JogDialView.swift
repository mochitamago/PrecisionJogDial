//
//  JogDialView.swift
//  JogDial
//

import SwiftUI
import UIKit

@MainActor
public struct JogDialView<Label: View>: View {
    @Binding var value: Float
    let range: ClosedRange<Float>
    let levels: Int
    let style: JogDialStyle
    let onEditingBegan: (() -> Void)?
    let onEditingEnded: (() -> Void)?
    private let label: (Int, Bool) -> Label

    @State private var activeLevel: Int?
    @State private var lastAngle: Double?
    @State private var spinAngles: [Int: Double] = [1: 0, 2: 0, 3: 0]

    @State private var lastHapticAngle: Double = 0
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    public init(
        value: Binding<Float>,
        range: ClosedRange<Float>,
        levels: Int = 3,
        style: JogDialStyle = JogDialStyle(),
        onEditingBegan: (() -> Void)? = nil,
        onEditingEnded: (() -> Void)? = nil,
        @ViewBuilder label: @escaping (Int, Bool) -> Label
    ) {
        self._value = value
        self.range = range
        self.levels = levels
        self.style = style
        self.onEditingBegan = onEditingBegan
        self.onEditingEnded = onEditingEnded
        self.label = label
    }

    public var body: some View {
        let rw = style.ringWidth
        let rg = style.ringGap
        let tl = style.tickLength

        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height)
            let maxRadius = min(geo.size.width / 2, geo.size.height) - 24

            ZStack(alignment: .bottom) {
                Path { path in
                    path.addArc(center: center, radius: 10, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                }
                .fill(style.trackColor.opacity(0.1))

                ForEach((1...levels).reversed(), id: \.self) { level in
                    let radius = maxRadius - CGFloat(levels - level) * (rw + rg)

                    ZStack {
                        Path { path in
                            path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .stroke(activeLevel == level ? style.accentColor.opacity(0.15) : style.trackColor.opacity(0.02), lineWidth: rw * 0.8)

                        Path { path in
                            path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .stroke(activeLevel == level ? style.accentColor : style.trackColor.opacity(0.2), lineWidth: 0)

                        let needleHeight = rw * 0.45
                        let needleWidth: CGFloat = 10
                        let angularWidth = Double((needleWidth / (2 * .pi * radius)) * 360.0)

                        Color.clear.overlay(
                            JogDialTicks(radius: radius, tickLength: tl, tickCount: 60)
                                .stroke(activeLevel == level ? style.accentColor : style.trackColor.opacity(0.5), lineWidth: 1)
                                .rotationEffect(.radians(spinAngles[level] ?? 0), anchor: .bottom)
                        )
                        .mask {
                            ZStack {
                                Rectangle().fill(Color.white)

                                ArcWindowMarker(centerPoint: center, radius: radius, thickness: needleHeight, angleWidth: angularWidth)
                                    .fill(style.maskColor.opacity(activeLevel == level ? 1.0 : 0.0))
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                        }
                        .clipShape(Rectangle())
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: activeLevel)

                        ZStack {
                            ArcWindowMarker(centerPoint: center, radius: radius, thickness: needleHeight, angleWidth: angularWidth)
                                .fill(activeLevel == level ? style.glassTint : style.trackColor.opacity(0.05))
                                .animation(.easeOut(duration: 0.2), value: activeLevel)

                            Color.clear.overlay(
                                JogDialTicks(radius: radius, tickLength: tl, tickCount: 120)
                                    .stroke(style.accentColor, lineWidth: 1.5)
                                    .rotationEffect(.radians(spinAngles[level] ?? 0), anchor: .bottom)
                            )
                            .scaleEffect(activeLevel == level ? 1.25 : 1.0, anchor: UnitPoint(x: 0.5, y: (geo.size.height - radius) / geo.size.height))
                            .opacity(activeLevel == level ? 1.0 : 0.0)
                            .mask(
                                ArcWindowMarker(centerPoint: center, radius: radius, thickness: needleHeight, angleWidth: angularWidth)
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: activeLevel)

                            ArcWindowMarker(centerPoint: center, radius: radius, thickness: needleHeight, angleWidth: angularWidth)
                                .stroke(activeLevel == level ? style.accentColor : style.trackColor.opacity(0.5), lineWidth: 0.5)
                                .animation(.easeOut(duration: 0.2), value: activeLevel)
                        }

                        label(level, activeLevel == level)
                            .position(x: center.x, y: center.y - radius - (rw * 0.55))
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        if activeLevel == nil {
                            if style.hapticsEnabled {
                                hapticGenerator.prepare()
                            }
                            onEditingBegan?()
                        }
                        handleDrag(location: drag.location, center: center, maxRadius: maxRadius, ringWidth: rw, ringGap: rg)
                    }
                    .onEnded { _ in
                        activeLevel = nil
                        lastAngle = nil
                        onEditingEnded?()
                    }
            )
        }
    }

    private func handleDrag(location: CGPoint, center: CGPoint, maxRadius: CGFloat, ringWidth: CGFloat, ringGap: CGFloat) {
        let dx = location.x - center.x
        let dy = location.y - center.y
        let dist = hypot(dx, dy)

        if activeLevel == nil {
            for level in 1...levels {
                let r = maxRadius - CGFloat(levels - level) * (ringWidth + ringGap)
                let innerEdge = r - (ringWidth / 2)
                let outerEdge = r + (ringWidth / 2)
                if dist >= innerEdge && dist <= outerEdge {
                    activeLevel = level
                    lastHapticAngle = spinAngles[level, default: 0]
                    break
                }
            }
            if activeLevel == nil {
                activeLevel = levels
                lastHapticAngle = spinAngles[levels, default: 0]
            }
        }

        guard let level = activeLevel else { return }

        let currentAngle = atan2(Double(dy), Double(dx))

        if let last = lastAngle {
            var delta = currentAngle - last

            if delta > .pi { delta -= 2 * .pi }
            else if delta < -.pi { delta += 2 * .pi }

            let span = range.upperBound - range.lowerBound
            let baseSensitivity = span / 3.0

            let multiplier: Float
            if levels == 3 {
                switch level {
                case 3: multiplier = baseSensitivity * 0.1
                case 2: multiplier = baseSensitivity * 1.0
                case 1: multiplier = baseSensitivity * 5.0
                default: multiplier = baseSensitivity
                }
            } else if levels == 2 {
                switch level {
                case 2: multiplier = baseSensitivity * 0.1
                case 1: multiplier = baseSensitivity * 1.0
                default: multiplier = baseSensitivity
                }
            } else {
                multiplier = baseSensitivity
            }

            let change = Float(-delta) * multiplier
            value = min(max(value + change, range.lowerBound), range.upperBound)

            spinAngles[level, default: 0] += delta

            let currentSpin = spinAngles[level, default: 0]
            let tickThreshold = (2 * Double.pi) / 120.0

            if style.hapticsEnabled, abs(currentSpin - lastHapticAngle) >= tickThreshold {
                hapticGenerator.impactOccurred()

                let steps = floor(abs(currentSpin - lastHapticAngle) / tickThreshold)
                let sign: Double = currentSpin > lastHapticAngle ? 1.0 : -1.0
                lastHapticAngle += tickThreshold * steps * sign
            }
        }
        lastAngle = currentAngle
    }
}

public extension JogDialView where Label == EmptyView {
    init(
        value: Binding<Float>,
        range: ClosedRange<Float>,
        levels: Int = 3,
        style: JogDialStyle = JogDialStyle(),
        onEditingBegan: (() -> Void)? = nil,
        onEditingEnded: (() -> Void)? = nil
    ) {
        self.init(
            value: value,
            range: range,
            levels: levels,
            style: style,
            onEditingBegan: onEditingBegan,
            onEditingEnded: onEditingEnded
        ) { _, _ in
            EmptyView()
        }
    }
}

#if DEBUG
private struct PreviewChrome: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let levels: Int
    let style: JogDialStyle
    let background: Color
    let valueColor: Color

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 16) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(valueColor.opacity(0.8))

                Text(String(format: "%.1f", value))
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(valueColor)

                JogDialView(value: $value, range: range, levels: levels, style: style) { level, isActive in
                    defaultPreviewLabel(levels: levels, level: level, isActive: isActive, accent: style.accentColor, muted: style.trackColor)
                }
                .frame(height: 160)
            }
        }
    }

    private func defaultPreviewLabel(levels: Int, level: Int, isActive: Bool, accent: Color, muted: Color) -> some View {
        let text: String = {
            if levels == 3 {
                switch level {
                case 3: return "FINE"
                case 2: return "NORMAL"
                case 1: return "COARSE"
                default: return ""
                }
            } else if levels == 2 {
                switch level {
                case 2: return "FINE"
                case 1: return "NORMAL"
                default: return ""
                }
            } else {
                return "VALUE"
            }
        }()

        return Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(isActive ? accent : muted.opacity(0.35))
    }
}

private struct PreviewDefaultThreeLevel: View {
    @State private var value: Float = 120
    var body: some View {
        PreviewChrome(
            title: "Default styling",
            value: $value,
            range: 0...500,
            levels: 3,
            style: JogDialStyle(),
            background: Color(white: 0.08),
            valueColor: JogDialStyle().accentColor
        )
        .preferredColorScheme(.dark)
    }
}

private struct PreviewOneLevel: View {
    @State private var value: Float = 50
    var body: some View {
        PreviewChrome(
            title: "Single ring",
            value: $value,
            range: 0...100,
            levels: 1,
            style: JogDialStyle(),
            background: Color(white: 0.08),
            valueColor: JogDialStyle().accentColor
        )
        .preferredColorScheme(.dark)
    }
}

private struct PreviewMinimalLight: View {
    @State private var value: Float = 25
    var body: some View {
        PreviewChrome(
            title: "Light minimal",
            value: $value,
            range: 0...100,
            levels: 3,
            style: JogDialStyle(
                accentColor: .indigo,
                trackColor: .black,
                glassTint: Color.indigo.opacity(0.12),
                maskColor: .black,
                ringWidth: 40,
                ringGap: 6,
                tickLength: 5,
                hapticsEnabled: true
            ),
            background: Color(white: 0.96),
            valueColor: .indigo
        )
        .preferredColorScheme(.light)
    }
}

#Preview("Default 3-level") {
    PreviewDefaultThreeLevel()
}

#Preview("1-level slider") {
    PreviewOneLevel()
}

#Preview("Minimal light") {
    PreviewMinimalLight()
}
#endif
