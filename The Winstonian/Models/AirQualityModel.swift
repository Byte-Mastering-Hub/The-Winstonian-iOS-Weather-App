// AirQualityModel.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation
import SwiftUI

// MARK: - Air Pollution API Response

struct AirPollutionResponse: Codable {
    let list: [AirQualityEntry]
}

struct AirQualityEntry: Codable {
    let dt: TimeInterval
    let main: AQIMain
    let components: AQIComponents
}

struct AQIMain: Codable {
    let aqi: Int  // 1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor
}

struct AQIComponents: Codable {
    let co: Double
    let no: Double?
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double?

    enum CodingKeys: String, CodingKey {
        case co, no, no2, o3, so2
        case pm2_5 = "pm2_5"
        case pm10, nh3
    }
}

// MARK: - AQI Display Helper

struct AirQualityInfo {
    let aqi: Int
    let label: String
    let color: Color
    let description: String

    static func from(aqi: Int) -> AirQualityInfo {
        switch aqi {
        case 1:
            return AirQualityInfo(aqi: aqi, label: "Good", color: Color(hue: 0.36, saturation: 0.7, brightness: 0.75), description: "Air quality is satisfactory.")
        case 2:
            return AirQualityInfo(aqi: aqi, label: "Fair", color: Color(hue: 0.22, saturation: 0.8, brightness: 0.9), description: "Air quality is acceptable.")
        case 3:
            return AirQualityInfo(aqi: aqi, label: "Moderate", color: Color(hue: 0.1, saturation: 0.85, brightness: 0.9), description: "Sensitive groups may be affected.")
        case 4:
            return AirQualityInfo(aqi: aqi, label: "Poor", color: Color(hue: 0.04, saturation: 0.85, brightness: 0.85), description: "Health effects for everyone.")
        case 5:
            return AirQualityInfo(aqi: aqi, label: "Very Poor", color: Color(hue: 0.85, saturation: 0.7, brightness: 0.7), description: "Serious health effects.")
        default:
            return AirQualityInfo(aqi: aqi, label: "Unknown", color: .gray, description: "No data available.")
        }
    }
}
