//
//  ContentViewModel.swift
//  KeychainSample
//
//  Created by Peter Kurzok on 12.01.22.
//

import Foundation
import KeychainAccess
import LocalAuthentication
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var showDetailView: Bool = false
    @Published var navigateTo: Destination?

    enum Destination: Equatable {
        case contentDetail
    }

    enum Keys: String {
        case username
        case password
    }

    var biometricsEnabled: Bool {
        guard let type = keychain.authenticationContext?.biometryType else { return false }
        return type != .none
    }

    var biometricIcon: String {
        keychain.authenticationContext?.biometryType == .faceID ? "faceid" : "touchid"
    }

    func onAppear() {
        fetchCredentials { email, password in
            guard
                let email = email,
                let password = password
            else {
                return
            }

            self.username = email
            self.password = password
        }
    }

    func login() {
        guard !username.isEmpty, !password.isEmpty else { return }

        saveCredentials(username: username, password: password) { success in
            if success {
                self.navigateTo = .contentDetail
            }
        }
    }

    func clearKeychain() {
        do {
            try keychain.removeAll()
        } catch {
            print("Keychain Error: \(error.localizedDescription)")
        }
    }

    private let keychain: Keychain = {
        let k = Keychain(service: "com.peterkurzok.de.KeychainSample")
            .authenticationContext(LAContext())

        k.authenticationContext?.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return k
    }()

    private func saveCredentials(username: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            do {
                try self.keychain.set(username, key: Keys.username.rawValue)
                try self.keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set(password, key: Keys.password.rawValue)
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Keychain Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private func fetchCredentials(completion: @escaping (_ email: String?, _ password: String?) -> Void) {
        DispatchQueue.global().async {
            do {
                let username = try self.keychain.get(Keys.username.rawValue)
                let password = try self.keychain
                    .authenticationUI
                    .authenticationPrompt("Authenticate to login to server")
                    .get(Keys.password.rawValue)

                DispatchQueue.main.async {
                    completion(username, password)
                }

            } catch {
                print("Keychain Error: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }
    }
}
