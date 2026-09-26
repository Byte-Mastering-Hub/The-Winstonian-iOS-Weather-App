// ConditionIconView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Animated Weather Icon

struct ConditionIconView: View {

    let sfSymbol: String
    let size: CGFloat
    let color: Color

    @State private var bounce = false

    var body: some View {
        Image(systemName: sfSymbol)
            .symbolRenderingMode(.multicolor)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(color)
            .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 4)
            .scaleEffect(bounce ? 1.06 : 1.0)
            .animation(
                .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                value: bounce
            )
            .onAppear { bounce = true }
    }
}

// MARK: - Small Icon for lists

struct SmallConditionIcon: View {
    let sfSymbol: String
    let color: Color

    var body: some View {
        Image(systemName: sfSymbol)
            .symbolRenderingMode(.multicolor)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(color)
    }
}

#Preview {
    ZStack {
        Color(hue: 0.6, saturation: 0.5, brightness: 0.3).ignoresSafeArea()
        ConditionIconView(sfSymbol: "sun.max.fill", size: 100, color: .yellow)
    }
}
