// ForecastModel.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation

// MARK: - Hourly Forecast (used by Views)

struct HourlyForecast: Identifiable {
    let dt: TimeInterval
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let windSpeed: Double
    let pop: Double
    let weather: [WeatherCondition]

    var id: TimeInterval { dt }
    var time: Date { Date(timeIntervalSince1970: dt) }
    var condition: WeatherCondition { weather.first ?? .default }
}

// MARK: - Daily Forecast (used by Views)

struct DailyForecast: Identifiable {
    let dt: TimeInterval
    let temp: DailyTemp
    let weather: [WeatherCondition]
    let pop: Double
    let humidity: Int
    let windSpeed: Double

    var id: TimeInterval { dt }
    var date: Date { Date(timeIntervalSince1970: dt) }
    var condition: WeatherCondition { weather.first ?? .default }

    struct DailyTemp {
        let min: Double
        let max: Double
        let day: Double
    }
}

// MARK: - /data/2.5/forecast API Response (free tier)

struct ForecastAPIResponse: Codable {
    let list: [ForecastAPIItem]
    let city: ForecastAPICity
}

struct ForecastAPIItem: Codable, Identifiable {
    let dt: TimeInterval
    let main: ForecastAPIMain
    let weather: [WeatherCondition]
    let wind: ForecastAPIWind
    let visibility: Int?
    let pop: Double

    var id: TimeInterval { dt }
    var date: Date { Date(timeIntervalSince1970: dt) }
    var condition: WeatherCondition { weather.first ?? .default }

    struct ForecastAPIMain: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
        let pressure: Int

        enum CodingKeys: String, CodingKey {
            case temp, humidity, pressure
            case feelsLike = "feels_like"
            case tempMin   = "temp_min"
            case tempMax   = "temp_max"
        }
    }

    struct ForecastAPIWind: Codable {
        let speed: Double
        let deg: Int?
    }
}

struct ForecastAPICity: Codable {
    let name: String
    let country: String
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
