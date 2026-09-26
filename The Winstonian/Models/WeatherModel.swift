// WeatherModel.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation

// MARK: - Current Weather (/weather endpoint)

struct CurrentWeather: Codable, Identifiable {
    let id: Int
    let name: String
    let dt: TimeInterval
    let timezone: Int
    let coord: Coordinates
    let weather: [WeatherCondition]
    let main: MainWeatherData
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    let visibility: Int?

    var condition: WeatherCondition { weather.first ?? .default }
    var localDate: Date { Date(timeIntervalSince1970: dt) }

    struct Coordinates: Codable {
        let lat: Double
        let lon: Double
    }

    struct MainWeatherData: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Wind: Codable {
        let speed: Double
        let deg: Int?
        let gust: Double?
    }

    struct Clouds: Codable {
        let all: Int
    }

    struct Sys: Codable {
        let country: String?
        let sunrise: TimeInterval?
        let sunset: TimeInterval?
    }
}




// MARK: - Weather Condition

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String

    static let `default` = WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: "01d")

    var iconURL: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
}
