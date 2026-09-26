// WeatherViewModel.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation
import SwiftUI
import Combine
import CoreLocation

// MARK: - ViewModel State

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - Weather ViewModel

@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: Published State
    @Published var viewState: ViewState = .idle
    @Published var currentWeather: CurrentWeather?
    @Published var forecastResponse: ForecastAPIResponse?
    @Published var airQualityEntry: AirQualityEntry?
    @Published var searchResults: [CityResult] = []
    @Published var selectedCity: CityResult?
    @Published var isSearching: Bool = false
    @Published var units: Constants.Units = .metric
    @Published var showingSearch: Bool = false

    @Published var searchQuery: String = "" {
        didSet { handleSearchDebounce(searchQuery) }
    }

    // MARK: - Computed: Hourly Forecast
    // Maps the 3-hour interval items from /forecast into HourlyForecast for the Views
    var hourlyForecast: [HourlyForecast] {
        guard let items = forecastResponse?.list else { return [] }
        return Array(items.prefix(Constants.Forecast.hourlyCount).map { item in
            HourlyForecast(
                dt:        item.dt,
                temp:      item.main.temp,
                feelsLike: item.main.feelsLike,
                humidity:  item.main.humidity,
                windSpeed: item.wind.speed,
                pop:       item.pop,
                weather:   item.weather
            )
        })
    }

    // MARK: - Computed: Daily Forecast
    // Groups the 3-hour items by calendar day, picks min/max temp and noon condition
    var dailyForecast: [DailyForecast] {
        guard let items = forecastResponse?.list else { return [] }
        let calendar = Calendar.current
        let grouped  = Dictionary(grouping: items) { calendar.startOfDay(for: $0.date) }

        return grouped.keys.sorted().prefix(Constants.Forecast.dailyCount).compactMap { day in
            guard let dayItems = grouped[day], !dayItems.isEmpty else { return nil }
            let temps   = dayItems.map { $0.main.temp }
            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 0
            let maxPop  = dayItems.map { $0.pop }.max() ?? 0
            // Pick item closest to noon for the representative condition
            let midItem = dayItems.min(by: {
                abs(calendar.component(.hour, from: $0.date) - 12) <
                abs(calendar.component(.hour, from: $1.date) - 12)
            }) ?? dayItems[0]

            return DailyForecast(
                dt:        day.timeIntervalSince1970,
                temp:      DailyForecast.DailyTemp(
                    min: minTemp,
                    max: maxTemp,
                    day: midItem.main.temp
                ),
                weather:   midItem.weather,
                pop:       maxPop,
                humidity:  midItem.main.humidity,
                windSpeed: midItem.wind.speed
            )
        }
    }

    // MARK: - Computed Helpers

    var conditionStyle: WeatherConditionStyle {
        WeatherConditionHelper.style(for: currentWeather?.condition.id ?? 800, isDay: isCurrentlyDay)
    }

    var isCurrentlyDay: Bool {
        guard let w = currentWeather else { return true }
        let now     = Date().timeIntervalSince1970
        let sunrise = w.sys.sunrise ?? 0
        let sunset  = w.sys.sunset  ?? 86400
        return now > sunrise && now < sunset
    }

    var temperatureString: String {
        guard let temp = currentWeather?.main.temp else { return "--" }
        return "\(Int(temp.rounded()))\(units.tempSymbol)"
    }

    var feelsLikeString: String {
        guard let fl = currentWeather?.main.feelsLike else { return "--" }
        return "Feels like \(Int(fl.rounded()))\(units.tempSymbol)"
    }

    var cityDisplayName: String {
        if let city = currentWeather {
            let country = city.sys.country ?? ""
            return country.isEmpty ? city.name : "\(city.name), \(country)"
        }
        return selectedCity?.displayName ?? "Searching..."
    }

    var windString: String {
        guard let wind = currentWeather?.wind else { return "--" }
        return "\(Int(wind.speed.rounded())) \(units.speedUnit)"
    }

    var humidityString: String {
        guard let h = currentWeather?.main.humidity else { return "--" }
        return "\(h)%"
    }

    var aqiInfo: AirQualityInfo? {
        airQualityEntry.map { AirQualityInfo.from(aqi: $0.main.aqi) }
    }

    var hasData: Bool { currentWeather != nil }

    // MARK: Dependencies
    private let service: WeatherService
    private let locationManager: LocationManager
    private var searchDebounceTask: Task<Void, Never>?

    // MARK: Init
    init(service: WeatherService = WeatherService()) {
        self.service         = service
        self.locationManager = LocationManager()
    }

    // MARK: - Public API

    func loadWeatherForCurrentLocation() {
        Task {
            viewState = .loading
            do {
                let location = try await locationManager.fetchCurrentLocation()
                try await fetchAll(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
                viewState = .success
            } catch let error as LocationManager.LocationError where error == .denied || error == .restricted {
                // If location is denied or restricted, show the empty home page
                // and automatically present the search sheet so the user can search.
                viewState = .success
                showingSearch = true
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func loadWeather(for city: CityResult) {
        selectedCity = city
        showingSearch = false
        searchQuery  = ""
        searchResults = []
        Task {
            viewState = .loading
            do {
                try await fetchAll(lat: city.lat, lon: city.lon)
                viewState = .success
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func refresh() {
        if let city = selectedCity {
            loadWeather(for: city)
        } else {
            loadWeatherForCurrentLocation()
        }
    }

    func toggleUnits() {
        units = units == .metric ? .imperial : .metric
        refresh()
    }

    // MARK: - Private

    private func fetchAll(lat: Double, lon: Double) async throws {
        // All three endpoints are on the free tier — run them in parallel
        async let currentTask  = service.fetchCurrentWeather(lat: lat, lon: lon, units: units)
        async let forecastTask = service.fetchForecast(lat: lat, lon: lon, units: units)
        async let aqiTask      = service.fetchAirQuality(lat: lat, lon: lon)

        let (current, forecast, aqi) = try await (currentTask, forecastTask, aqiTask)

        currentWeather   = current
        forecastResponse = forecast
        airQualityEntry  = aqi
    }

    private func handleSearchDebounce(_ query: String) {
        searchDebounceTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching   = false
            return
        }
        searchDebounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            isSearching = true
            do {
                let results = try await service.searchCity(query: trimmed)
                if !Task.isCancelled { searchResults = results }
            } catch {
                if !Task.isCancelled { searchResults = [] }
            }
            isSearching = false
        }
    }
}
