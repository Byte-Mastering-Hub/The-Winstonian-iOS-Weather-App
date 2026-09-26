// HomeView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var contentVisible = false

    private var contentHorizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 12 : 16
    }

    private var topBarHorizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 16 : 20
    }

    var body: some View {
        ZStack {
            WeatherBackgroundView(
                colors: viewModel.conditionStyle.gradientColors,
                isDark: viewModel.conditionStyle.isDark
            )
            .ignoresSafeArea()

            Group {
                switch viewModel.viewState {
                case .idle:
                    LoadingView()
                        .onAppear { viewModel.loadWeatherForCurrentLocation() }
                case .loading:
                    LoadingView()
                case .success:
                    weatherContent
                case .error(let msg):
                    ErrorView(message: msg) { viewModel.refresh() }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingSearch) {
            SearchView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Scrollable Content

    private var weatherContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                topBar
                    .padding(.top, 6)
                    .padding(.horizontal, topBarHorizontalPadding)

                heroSection
                    .padding(.top, 20)
                    .padding(.bottom, 32)

                // ── Hourly ──────────────────────────────────
                sectionCard {
                    HourlyForecastView(
                        forecast: viewModel.hourlyForecast,
                        units: viewModel.units,
                        accentColor: viewModel.conditionStyle.accentColor
                    )
                }
                .padding(.horizontal, contentHorizontalPadding)
                .padding(.bottom, 14)

                // ── 7-Day ───────────────────────────────────
                sectionCard {
                    ForecastView(
                        forecast: viewModel.dailyForecast,
                        units: viewModel.units
                    )
                }
                .padding(.horizontal, contentHorizontalPadding)
                .padding(.bottom, 14)

                // ── Detail cards ────────────────────────────
                WeatherDetailGrid(viewModel: viewModel)
                    .padding(.horizontal, contentHorizontalPadding)
                    .padding(.bottom, 48)
            }
        }
        .refreshable { viewModel.refresh() }
        .opacity(contentVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { contentVisible = true }
        }
        .onChange(of: viewModel.currentWeather?.id) { _, _ in
            contentVisible = false
            withAnimation(.easeOut(duration: 0.4)) { contentVisible = true }
        }
    }

    // MARK: - Section Card Wrapper

    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.13), lineWidth: 1)
                    )
            )
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            // Units toggle pill
            Button(action: { viewModel.toggleUnits() }) {
                Text(viewModel.units == .metric ? "°C" : "°F")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial.opacity(0.7))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }

            Spacer()

            // GPS button
            Button(action: { viewModel.loadWeatherForCurrentLocation() }) {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial.opacity(0.7))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }

            // Search button
            Button(action: { viewModel.showingSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial.opacity(0.7))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 0) {

            // City name
            HStack(spacing: 5) {
                Image(systemName: viewModel.selectedCity == nil ? "location.fill" : "mappin.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text(viewModel.cityDisplayName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.bottom, 16)

            // Weather icon
            ConditionIconView(
                sfSymbol: viewModel.conditionStyle.sfSymbol,
                size: 100,
                color: viewModel.conditionStyle.accentColor
            )
            .padding(.bottom, 10)

            // Temperature
            Text(viewModel.temperatureString)
                .font(.system(size: 90, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

            // Condition description
            Text(viewModel.currentWeather.map {
                WeatherConditionHelper.shortDescription(for: $0.condition.id)
            } ?? "")
            .font(.system(size: 22, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.88))
            .padding(.top, 2)

            // Feels like · H · L
            HStack(spacing: 0) {
                Text(viewModel.feelsLikeString)
                    .foregroundStyle(.white.opacity(0.6))

                if let today = viewModel.dailyForecast.first {
                    Text("  ·  H:\(Int(today.temp.max.rounded()))\(viewModel.units.tempSymbol)")
                        .foregroundStyle(.white.opacity(0.75))
                    Text("  L:\(Int(today.temp.min.rounded()))\(viewModel.units.tempSymbol)")
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Preview

#Preview {
    HomeView(viewModel: WeatherViewModel())
        .preferredColorScheme(.dark)
}
