// ForecastView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - 7-Day Daily Forecast

struct ForecastView: View {
    let forecast: [DailyForecast]
    let units: Constants.Units
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 12 : 16
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("7-DAY FORECAST")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, 12)

            VStack(spacing: 0) {
                ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                    DailyRow(day: day, units: units, isFirst: index == 0)

                    if index < forecast.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.horizontal, horizontalPadding)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, horizontalPadding)
        }
    }
}

// MARK: - Daily Row

struct DailyRow: View {
    let day: DailyForecast
    let units: Constants.Units
    let isFirst: Bool

    private var condStyle: WeatherConditionStyle {
        WeatherConditionHelper.style(for: day.condition.id, isDay: true)
    }

    private var dayLabel: String {
        if isFirst { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: day.date)
    }

    private var compactDayLabel: String {
        if isFirst { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date)
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(
                dayText: dayLabel,
                dayWidth: 95,
                iconWidth: 28,
                precipWidth: 36,
                tempWidth: 44,
                barWidth: 60,
                fontSize: 15,
                spacing: 12,
                horizontalPadding: 16,
                showsTempBar: true
            )

            row(
                dayText: compactDayLabel,
                dayWidth: 58,
                iconWidth: 24,
                precipWidth: 28,
                tempWidth: 34,
                barWidth: 44,
                fontSize: 14,
                spacing: 8,
                horizontalPadding: 12,
                showsTempBar: true
            )

            row(
                dayText: compactDayLabel,
                dayWidth: 48,
                iconWidth: 22,
                precipWidth: 24,
                tempWidth: 32,
                barWidth: 0,
                fontSize: 14,
                spacing: 6,
                horizontalPadding: 10,
                showsTempBar: false
            )
        }
    }

    private func row(
        dayText: String,
        dayWidth: CGFloat,
        iconWidth: CGFloat,
        precipWidth: CGFloat,
        tempWidth: CGFloat,
        barWidth: CGFloat,
        fontSize: CGFloat,
        spacing: CGFloat,
        horizontalPadding: CGFloat,
        showsTempBar: Bool
    ) -> some View {
        HStack(spacing: spacing) {
            Text(dayText)
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: dayWidth, alignment: .leading)

            Image(systemName: condStyle.sfSymbol)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: showsTempBar ? 20 : 18))
                .frame(width: iconWidth)

            precipitationView(fontSize: max(fontSize - 3, 11), width: precipWidth)

            Spacer(minLength: 0)

            HStack(spacing: showsTempBar ? 4 : 3) {
                Text("\(Int(day.temp.min.rounded()))\(units.tempSymbol)")
                    .font(.system(size: fontSize, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: tempWidth, alignment: .trailing)

                if showsTempBar {
                    TempRangeBar(minTemp: day.temp.min, maxTemp: day.temp.max)
                        .frame(width: barWidth, height: 4)
                }

                Text("\(Int(day.temp.max.rounded()))\(units.tempSymbol)")
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: tempWidth, alignment: .trailing)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, showsTempBar ? 13 : 12)
    }

    @ViewBuilder
    private func precipitationView(fontSize: CGFloat, width: CGFloat) -> some View {
        if day.pop > 0.1 {
            Text("\(Int(day.pop * 100))%")
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundStyle(Color(hue: 0.58, saturation: 0.6, brightness: 0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: width)
        } else {
            Color.clear
                .frame(width: width, height: 1)
        }
    }
}

// MARK: - Temperature Range Bar

struct TempRangeBar: View {
    let minTemp: Double
    let maxTemp: Double

    // Approximate daily range for full bar context
    private let absoluteMin: Double = -10
    private let absoluteMax: Double = 45

    var body: some View {
        GeometryReader { geo in
            let totalRange = absoluteMax - absoluteMin
            let startFraction = (minTemp - absoluteMin) / totalRange
            let endFraction = (maxTemp - absoluteMin) / totalRange
            let clampedStart = CGFloat(min(max(startFraction, 0), 1))
            let clampedEnd = CGFloat(min(max(endFraction, 0), 1))
            let rangeWidth = max(geo.size.width * max(clampedEnd - clampedStart, 0), 6)
            let xOffset = min(geo.size.width * clampedStart, max(geo.size.width - rangeWidth, 0))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.15))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.60, saturation: 0.7, brightness: 0.8),
                                Color(hue: 0.10, saturation: 0.8, brightness: 0.9)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: rangeWidth,
                        height: geo.size.height
                    )
                    .offset(x: xOffset)
            }
        }
    }
}
