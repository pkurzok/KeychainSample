//
//  ContentView.swift
//  KeychainSample
//
//  Created by Peter Kurzok on 12.01.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Username", text: $viewModel.username)

                SecureField("Password", text: $viewModel.password)

                Button("Login", action: viewModel.login)

                Button("Clear Keychain", action: viewModel.clearKeychain)

                if viewModel.biometricsEnabled {
                    Button(action: viewModel.onAppear) {
                        Image(systemName: viewModel.biometricIcon)
                            .resizable()
                            .frame(width: 48, height: 48)
                    }
                }
            }
            .padding(15)
            .onAppear(perform: viewModel.onAppear)
            .navigation(selection: $viewModel.navigateTo, destination: navigate)
        }
    }

    @ViewBuilder
    private func navigate(selection: ContentViewModel.Destination) -> some View {
        switch selection {
        case .contentDetail: ContentDetailView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
