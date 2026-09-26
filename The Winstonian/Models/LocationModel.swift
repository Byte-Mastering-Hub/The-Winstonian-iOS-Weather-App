// LocationModel.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import Foundation

// MARK: - Geocoding API Result

struct CityResult: Codable, Identifiable, Hashable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    var id: String { "\(name)-\(lat)-\(lon)" }

    var displayName: String {
        var parts = [name]
        if let state = state, !state.isEmpty { parts.append(state) }
        parts.append(country)
        return parts.joined(separator: ", ")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CityResult, rhs: CityResult) -> Bool {
        lhs.id == rhs.id
    }
}
