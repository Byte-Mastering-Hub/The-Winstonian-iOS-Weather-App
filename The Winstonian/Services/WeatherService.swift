// WeatherService.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation

// MARK: - Weather Service Errors

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "Invalid request URL."
        case .invalidResponse:         return "Server returned an invalid response."
        case .httpError(let code):     return "Server error (HTTP \(code)). Check your API key."
        case .decodingError(let msg):  return "Data parsing error: \(msg)"
        case .noData:                  return "No weather data available."
        }
    }
}

// MARK: - Weather Service

struct WeatherService {

    private let session: URLSession
    private let decoder: JSONDecoder

    nonisolated init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Current Weather  (/data/2.5/weather — free tier)

    func fetchCurrentWeather(lat: Double, lon: Double, units: Constants.Units = .metric) async throws -> CurrentWeather {
        let url = try buildURL(
            path: "/data/2.5/weather",
            params: [
                "lat":   "\(lat)",
                "lon":   "\(lon)",
                "units": units.rawValue,
                "appid": Constants.API.apiKey
            ]
        )
        return try await fetch(url: url, as: CurrentWeather.self)
    }

    // MARK: - 5-Day / 3-Hour Forecast  (/data/2.5/forecast — free tier)

    func fetchForecast(lat: Double, lon: Double, units: Constants.Units = .metric) async throws -> ForecastAPIResponse {
        let url = try buildURL(
            path: "/data/2.5/forecast",
            params: [
                "lat":   "\(lat)",
                "lon":   "\(lon)",
                "units": units.rawValue,
                "appid": Constants.API.apiKey
            ]
        )
        return try await fetch(url: url, as: ForecastAPIResponse.self)
    }

    // MARK: - Air Quality  (/data/2.5/air_pollution — free tier)

    func fetchAirQuality(lat: Double, lon: Double) async throws -> AirQualityEntry {
        let url = try buildURL(
            path: "/data/2.5/air_pollution",
            params: [
                "lat":   "\(lat)",
                "lon":   "\(lon)",
                "appid": Constants.API.apiKey
            ]
        )
        let response = try await fetch(url: url, as: AirPollutionResponse.self)
        guard let entry = response.list.first else { throw WeatherServiceError.noData }
        return entry
    }

    // MARK: - City Search  (/geo/1.0/direct — free tier)

    func searchCity(query: String) async throws -> [CityResult] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let url = try buildURL(
            path: "/geo/1.0/direct",
            params: [
                "q":     query,
                "limit": "\(Constants.Geocoding.resultLimit)",
                "appid": Constants.API.apiKey
            ]
        )
        return try await fetch(url: url, as: [CityResult].self)
    }

    // MARK: - Private Helpers

    private func buildURL(path: String, params: [String: String]) throws -> URL {
        var components = URLComponents(string: Constants.API.baseURL + path)
        components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else { throw WeatherServiceError.invalidURL }
        return url
    }

    private func fetch<T: Decodable>(url: URL, as type: T.Type) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        do {
            return try decoder.decode(type, from: data)
        } catch let error as DecodingError {
            throw WeatherServiceError.decodingError(error.localizedDescription)
        }
    }
}
