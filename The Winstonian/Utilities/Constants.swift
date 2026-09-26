// Constants.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation

// MARK: - App Constants

enum Constants {

    // MARK: API
    enum API {
        static let baseURL     = "https://api.openweathermap.org"
        static let iconBaseURL = "https://openweathermap.org/img/wn"

        // API key — replace this string if you regenerate your key
        static let apiKey      = "5edd684c8c80f9974a686155a38f9cd4"
    }

    // MARK: Units
    enum Units: String, CaseIterable, Identifiable {
        case metric = "metric"
        case imperial = "imperial"

        var id: String { rawValue }

        var tempSymbol: String {
            switch self {
            case .metric: return "°C"
            case .imperial: return "°F"
            }
        }

        var speedUnit: String {
            switch self {
            case .metric: return "m/s"
            case .imperial: return "mph"
            }
        }

        var displayName: String {
            switch self {
            case .metric: return "Metric (°C)"
            case .imperial: return "Imperial (°F)"
            }
        }
    }

    // MARK: Geocoding limits
    enum Geocoding {
        static let resultLimit = 5
    }

    // MARK: Forecast limits
    enum Forecast {
        static let hourlyCount = 24
        static let dailyCount = 7
    }
}
