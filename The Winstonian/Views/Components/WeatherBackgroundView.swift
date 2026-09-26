// WeatherBackgroundView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Pre-computed circle layout (fixed at creation, not re-randomised on every render)

private struct CircleConfig {
    let sizeFraction: CGFloat   // fraction of container width
    let xFraction: CGFloat      // offset fraction of container width
    let yFraction: CGFloat      // offset fraction of container height
    let duration: Double        // animation duration in seconds
}

private let circleConfigs: [CircleConfig] = [
    CircleConfig(sizeFraction: 0.75, xFraction: -0.05, yFraction: -0.10, duration: 5.5),
    CircleConfig(sizeFraction: 0.55, xFraction:  0.50, yFraction:  0.05, duration: 6.8),
    CircleConfig(sizeFraction: 0.65, xFraction:  0.20, yFraction:  0.55, duration: 4.9),
    CircleConfig(sizeFraction: 0.45, xFraction:  0.60, yFraction:  0.60, duration: 7.2),
    CircleConfig(sizeFraction: 0.80, xFraction: -0.15, yFraction:  0.70, duration: 5.1),
    CircleConfig(sizeFraction: 0.50, xFraction:  0.35, yFraction:  0.30, duration: 6.3),
]

// MARK: - Dynamic Animated Background

struct WeatherBackgroundView: View {

    let colors: [Color]
    let isDark: Bool

    @State private var animate = false

    var body: some View {
        ZStack {
            // Base gradient — direction animates slowly back and forth
            LinearGradient(
                colors: colors,
                startPoint: animate ? .topLeading : .topTrailing,
                endPoint: animate ? .bottomTrailing : .bottomLeading
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 6).repeatForever(autoreverses: true),
                value: animate
            )

            // Subtle glowing orbs for depth — positions are fixed constants
            GeometryReader { geo in
                ForEach(Array(circleConfigs.enumerated()), id: \.offset) { index, config in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(animate ? 0.06 : 0.02),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.4
                            )
                        )
                        .frame(
                            width: geo.size.width * config.sizeFraction,
                            height: geo.size.width * config.sizeFraction
                        )
                        .offset(
                            x: config.xFraction * geo.size.width,
                            y: config.yFraction * geo.size.height
                        )
                        .animation(
                            .easeInOut(duration: config.duration)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                            value: animate
                        )
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { animate = true }
    }
}

// MARK: - Preview

#Preview {
    WeatherBackgroundView(
        colors: [
            Color(hue: 0.58, saturation: 0.7, brightness: 0.85),
            Color(hue: 0.62, saturation: 0.75, brightness: 0.60)
        ],
        isDark: true
    )
}
