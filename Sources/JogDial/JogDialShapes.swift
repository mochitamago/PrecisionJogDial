//
//  JogDialShapes.swift
//  JogDial
//

import SwiftUI

struct JogDialTicks: Shape {
    let radius: CGFloat
    let tickLength: CGFloat
    let tickCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)

        for i in 0..<tickCount {
            let angle = (Double(i) / Double(tickCount)) * 2 * .pi

            let isMajor = i % 5 == 0
            let currentLength = isMajor ? tickLength * 1.8 : tickLength

            let inner = radius - (currentLength / 2)
            let outer = radius + (currentLength / 2)

            let p1 = CGPoint(x: center.x + CGFloat(cos(angle)) * inner, y: center.y + CGFloat(sin(angle)) * inner)
            let p2 = CGPoint(x: center.x + CGFloat(cos(angle)) * outer, y: center.y + CGFloat(sin(angle)) * outer)

            path.move(to: p1)
            path.addLine(to: p2)
        }
        return path
    }
}

struct ArcWindowMarker: Shape {
    let centerPoint: CGPoint
    let radius: CGFloat
    let thickness: CGFloat
    /// Angular width in degrees (see original layout math).
    let angleWidth: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = Angle.degrees(270 - angleWidth / 0.6)
        let end = Angle.degrees(270 + angleWidth / 0.6)

        path.addArc(center: centerPoint, radius: radius + thickness / 1.5, startAngle: start, endAngle: end, clockwise: false)
        path.addArc(center: centerPoint, radius: radius - thickness / 1.5, startAngle: end, endAngle: start, clockwise: true)
        path.closeSubpath()

        return path
    }
}
