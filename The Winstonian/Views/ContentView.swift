// ContentView.swift
// The Winstonian
// Created by Sumit on 04/02/26.

import SwiftUI

// MARK: - Root View

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        HomeView(viewModel: viewModel)
            .preferredColorScheme(.dark)   // Force dark mode app-wide
    }
}

#Preview {
    ContentView()
}
