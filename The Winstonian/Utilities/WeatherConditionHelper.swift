// WeatherConditionHelper.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation
import SwiftUI

// MARK: - Weather Condition Style

struct WeatherConditionStyle {
    let sfSymbol: String
    let gradientColors: [Color]
    let accentColor: Color
    let isDark: Bool          // true → white text, false → dark text
}

// MARK: - Helper

struct WeatherConditionHelper {

    /// Maps an OWM condition code + time-of-day flag to a style
    static func style(for conditionID: Int, isDay: Bool) -> WeatherConditionStyle {
        switch conditionID {
        // Thunderstorm (200–232)
        case 200...232:
            return WeatherConditionStyle(
                sfSymbol: "cloud.bolt.fill",
                gradientColors: [
                    Color(hue: 0.67, saturation: 0.4, brightness: 0.25),
                    Color(hue: 0.65, saturation: 0.3, brightness: 0.15)
                ],
                accentColor: Color(hue: 0.65, saturation: 0.5, brightness: 0.8),
                isDark: true
            )

        // Drizzle (300–321)
        case 300...321:
            return WeatherConditionStyle(
                sfSymbol: "cloud.drizzle.fill",
                gradientColors: [
                    Color(hue: 0.58, saturation: 0.35, brightness: 0.55),
                    Color(hue: 0.60, saturation: 0.4, brightness: 0.35)
                ],
                accentColor: Color(hue: 0.58, saturation: 0.5, brightness: 0.85),
                isDark: true
            )

        // Rain (500–531)
        case 500...531:
            let heavy = conditionID >= 502
            return WeatherConditionStyle(
                sfSymbol: heavy ? "cloud.heavyrain.fill" : "cloud.rain.fill",
                gradientColors: [
                    Color(hue: 0.60, saturation: 0.45, brightness: heavy ? 0.35 : 0.50),
                    Color(hue: 0.62, saturation: 0.5, brightness: heavy ? 0.20 : 0.35)
                ],
                accentColor: Color(hue: 0.60, saturation: 0.6, brightness: 0.85),
                isDark: true
            )

        // Snow (600–622)
        case 600...622:
            return WeatherConditionStyle(
                sfSymbol: conditionID == 611 || conditionID == 612 ? "cloud.sleet.fill" : "cloud.snow.fill",
                gradientColors: [
                    Color(hue: 0.60, saturation: 0.12, brightness: 0.85),
                    Color(hue: 0.62, saturation: 0.15, brightness: 0.70)
                ],
                accentColor: Color(hue: 0.60, saturation: 0.3, brightness: 0.6),
                isDark: false
            )

        // Atmosphere / Fog / Mist (700–781)
        case 700...781:
            return WeatherConditionStyle(
                sfSymbol: conditionID == 781 ? "tornado" : "cloud.fog.fill",
                gradientColors: [
                    Color(hue: 0.60, saturation: 0.10, brightness: 0.65),
                    Color(hue: 0.58, saturation: 0.12, brightness: 0.50)
                ],
                accentColor: Color(hue: 0.60, saturation: 0.2, brightness: 0.7),
                isDark: true
            )

        // Clear (800)
        case 800:
            if isDay {
                return WeatherConditionStyle(
                    sfSymbol: "sun.max.fill",
                    gradientColors: [
                        Color(hue: 0.58, saturation: 0.7, brightness: 0.85),
                        Color(hue: 0.62, saturation: 0.75, brightness: 0.60)
                    ],
                    accentColor: Color(hue: 0.14, saturation: 0.85, brightness: 1.0),
                    isDark: true
                )
            } else {
                return WeatherConditionStyle(
                    sfSymbol: "moon.stars.fill",
                    gradientColors: [
                        Color(hue: 0.65, saturation: 0.50, brightness: 0.20),
                        Color(hue: 0.70, saturation: 0.55, brightness: 0.10)
                    ],
                    accentColor: Color(hue: 0.65, saturation: 0.3, brightness: 0.9),
                    isDark: true
                )
            }

        // Clouds (801–804)
        case 801...804:
            if isDay {
                return WeatherConditionStyle(
                    sfSymbol: conditionID <= 802 ? "cloud.sun.fill" : "cloud.fill",
                    gradientColors: [
                        Color(hue: 0.58, saturation: 0.40, brightness: 0.70),
                        Color(hue: 0.60, saturation: 0.45, brightness: 0.50)
                    ],
                    accentColor: Color(hue: 0.58, saturation: 0.5, brightness: 0.9),
                    isDark: true
                )
            } else {
                return WeatherConditionStyle(
                    sfSymbol: "cloud.moon.fill",
                    gradientColors: [
                        Color(hue: 0.65, saturation: 0.35, brightness: 0.25),
                        Color(hue: 0.67, saturation: 0.40, brightness: 0.15)
                    ],
                    accentColor: Color(hue: 0.65, saturation: 0.3, brightness: 0.8),
                    isDark: true
                )
            }

        default:
            return WeatherConditionStyle(
                sfSymbol: "thermometer.medium",
                gradientColors: [
                    Color(hue: 0.60, saturation: 0.4, brightness: 0.55),
                    Color(hue: 0.62, saturation: 0.45, brightness: 0.40)
                ],
                accentColor: .white,
                isDark: true
            )
        }
    }

    /// Human-readable description for the condition main string
    static func shortDescription(for conditionID: Int) -> String {
        switch conditionID {
        case 200...232: return "Thunderstorm"
        case 300...321: return "Drizzle"
        case 500...504: return "Rain"
        case 511:       return "Freezing Rain"
        case 520...531: return "Shower Rain"
        case 600...622: return "Snow"
        case 700...771: return "Foggy"
        case 781:       return "Tornado"
        case 800:       return "Clear Sky"
        case 801:       return "Few Clouds"
        case 802:       return "Partly Cloudy"
        case 803...804: return "Overcast"
        default:        return "Unknown"
        }
    }

    /// UV Index label + color
    static func uviInfo(uvi: Double) -> (label: String, color: Color) {
        switch uvi {
        case ..<3:   return ("Low", Color(hue: 0.36, saturation: 0.7, brightness: 0.7))
        case 3..<6:  return ("Moderate", Color(hue: 0.15, saturation: 0.9, brightness: 0.95))
        case 6..<8:  return ("High", Color(hue: 0.07, saturation: 0.9, brightness: 0.95))
        case 8..<11: return ("Very High", Color(hue: 0.04, saturation: 0.9, brightness: 0.9))
        default:     return ("Extreme", Color(hue: 0.83, saturation: 0.7, brightness: 0.8))
        }
    }
}
