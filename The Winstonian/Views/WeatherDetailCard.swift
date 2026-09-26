// WeatherDetailCard.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Individual Metric Card

struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)

            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - AQI Card (special layout)

struct AQICard: View {
    let info: AirQualityInfo
    let pm25: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "aqi.medium")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(info.color)
                Text("AIR QUALITY")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(info.aqi)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(info.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(info.color)
            }

            Text("PM2.5 · \(String(format: "%.1f", pm25)) μg/m³")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - UV Card

struct UVCard: View {
    let uvi: Double
    let accentColor: Color

    private var uviInfo: (label: String, color: Color) {
        WeatherConditionHelper.uviInfo(uvi: uvi)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(uviInfo.color)
                Text("UV INDEX")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%.0f", uvi))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(uviInfo.label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(uviInfo.color)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 4)
                    Capsule()
                        .fill(uviInfo.color)
                        .frame(width: geo.size.width * min(uvi / 11.0, 1.0), height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

// MARK: - Detail Grid

struct WeatherDetailGrid: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            // Humidity
            MetricCard(
                icon: "humidity.fill",
                label: "Humidity",
                value: viewModel.humidityString,
                unit: "Relative humidity",
                accentColor: Color(hue: 0.58, saturation: 0.7, brightness: 0.9)
            )

            // Wind
            MetricCard(
                icon: "wind",
                label: "Wind",
                value: viewModel.windString,
                unit: viewModel.units.speedUnit,
                accentColor: Color(hue: 0.55, saturation: 0.5, brightness: 0.9)
            )

            // Feels Like  (replaces UV Index — UV needs paid One Call API)
            MetricCard(
                icon: "thermometer.medium",
                label: "Feels Like",
                value: viewModel.feelsLikeString
                    .replacingOccurrences(of: "Feels like ", with: ""),
                unit: "Apparent temperature",
                accentColor: Color(hue: 0.07, saturation: 0.7, brightness: 0.9)
            )

            // Air Quality
            if let aqiInfo = viewModel.aqiInfo,
               let pm25 = viewModel.airQualityEntry?.components.pm2_5 {
                AQICard(info: aqiInfo, pm25: pm25)
            }

            // Pressure
            if let pressure = viewModel.currentWeather?.main.pressure {
                MetricCard(
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    label: "Pressure",
                    value: "\(pressure)",
                    unit: "hPa",
                    accentColor: Color(hue: 0.83, saturation: 0.5, brightness: 0.9)
                )
            }

            // Visibility
            if let visibility = viewModel.currentWeather?.visibility {
                MetricCard(
                    icon: "eye.fill",
                    label: "Visibility",
                    value: "\(visibility / 1000)",
                    unit: "km",
                    accentColor: Color(hue: 0.14, saturation: 0.6, brightness: 0.9)
                )
            }
        }
    }
}
