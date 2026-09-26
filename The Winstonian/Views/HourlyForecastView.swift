// HourlyForecastView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Hourly Forecast Scroll

struct HourlyForecastView: View {
    let forecast: [HourlyForecast]
    let units: Constants.Units
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Section header
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                Text("HOURLY FORECAST")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(forecast) { hour in
                        HourlyCell(hour: hour, units: units, accentColor: accentColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Single Hour Cell

struct HourlyCell: View {
    let hour: HourlyForecast
    let units: Constants.Units
    let accentColor: Color

    private var isNow: Bool {
        Calendar.current.isDate(hour.time, equalTo: Date(), toGranularity: .hour)
    }

    private var timeLabel: String {
        if isNow { return "Now" }
        let f = DateFormatter()
        f.dateFormat = "ha"
        return f.string(from: hour.time).lowercased()
    }

    private var condStyle: WeatherConditionStyle {
        WeatherConditionHelper.style(for: hour.condition.id, isDay: hour.time.isDay)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(timeLabel)
                .font(.system(size: 13, weight: isNow ? .bold : .medium, design: .rounded))
                .foregroundStyle(isNow ? .white : .white.opacity(0.6))

            Image(systemName: condStyle.sfSymbol)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 24))
                .frame(height: 28)

            // Rain probability or placeholder
            if hour.pop > 0.09 {
                Text("\(Int(hour.pop * 100))%")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hue: 0.58, saturation: 0.55, brightness: 0.95))
            } else {
                Color.clear.frame(height: 15)
            }

            Text("\(Int(hour.temp.rounded()))\(units.tempSymbol)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 62)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isNow
                      ? Color.white.opacity(0.18)
                      : Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isNow ? Color.white.opacity(0.4) : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Date Extension

extension Date {
    var isDay: Bool {
        let h = Calendar.current.component(.hour, from: self)
        return h >= 6 && h < 20
    }
}
