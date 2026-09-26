// SearchView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - City Search Sheet

struct SearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(hue: 0.62, saturation: 0.45, brightness: 0.12)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))

                        TextField("Search city...", text: $viewModel.searchQuery)
                            .focused($searchFocused)
                            .foregroundStyle(.white)
                            .tint(.white)
                            .font(.system(size: 17, design: .rounded))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .submitLabel(.search)

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: { viewModel.searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white.opacity(0.5))
                                    .font(.system(size: 16))
                            }
                        }

                        if viewModel.isSearching {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Results
                    if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty && !viewModel.isSearching {
                        emptyState
                    } else {
                        resultsList
                    }

                    Spacer()
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        viewModel.showingSearch = false
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                }
            }
        }
        .onAppear { searchFocused = true }
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, city in
                    Button(action: { viewModel.loadWeather(for: city) }) {
                        CityRow(city: city)
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.searchResults.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 56)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.fill")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.25))
                .padding(.top, 48)
            Text("No cities found")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            Text("Try a different city name or spelling")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}

// MARK: - City Row

struct CityRow: View {
    let city: CityResult

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(city.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 4) {
                    if let state = city.state, !state.isEmpty {
                        Text(state)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.white.opacity(0.55))
                        Text("·")
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    Text(city.country)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
