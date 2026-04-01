//
//  JogDialStyle.swift
//  JogDial
//

import SwiftUI

/// Visual and interaction configuration for ``JogDialView``.
public struct JogDialStyle: Sendable {
    /// Primary accent (active ring, lens ticks, window frame when focused).
    public var accentColor: Color
    /// Neutral track and inactive chrome.
    public var trackColor: Color
    /// Fill for the magnifying “glass” window when a ring is active.
    public var glassTint: Color
    /// Color used for the hole punch in the tick mask (`destinationOut`); typically opaque black.
    public var maskColor: Color

    /// Radial thickness of each ring’s hit area and visual baseline.
    public var ringWidth: CGFloat
    /// Spacing between concentric rings.
    public var ringGap: CGFloat
    /// Base length of tick marks (major ticks scale from this).
    public var tickLength: CGFloat

    /// When `false`, rotational haptics are not triggered.
    public var hapticsEnabled: Bool

    public init(
        accentColor: Color = Color(red: 0.15, green: 0.92, blue: 0.98),
        trackColor: Color = .white,
        glassTint: Color = Color(red: 0.15, green: 0.92, blue: 0.98).opacity(0.15),
        maskColor: Color = .black,
        ringWidth: CGFloat = 44,
        ringGap: CGFloat = 4,
        tickLength: CGFloat = 6,
        hapticsEnabled: Bool = true
    ) {
        self.accentColor = accentColor
        self.trackColor = trackColor
        self.glassTint = glassTint
        self.maskColor = maskColor
        self.ringWidth = ringWidth
        self.ringGap = ringGap
        self.tickLength = tickLength
        self.hapticsEnabled = hapticsEnabled
    }
}
