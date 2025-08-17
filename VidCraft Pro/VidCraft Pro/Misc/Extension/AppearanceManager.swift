//
//  AppearanceManager.swift
//  VidCraft Pro
//
//  Created by Shahzaman Khan on 25/01/24.
//

import UIKit

class AppearanceManager {

    // Create a shared instance of the class
    static let shared = AppearanceManager()

    // Key for UserDefaults
    private let modeKey = "AppAppearanceMode"

    // Enum to represent appearance modes
    enum AppearanceMode: String {
        case light, dark, system
    }

    // Property to store the current appearance mode
    var currentMode: AppearanceMode {
        didSet {
            // Save the selected mode to UserDefaults
            UserDefaults.standard.set(currentMode.rawValue, forKey: modeKey)
        }
    }

    // Private initializer to ensure it's a singleton
    private init() {
        // Retrieve the saved mode from UserDefaults or default to .system
        if let savedMode = UserDefaults.standard.string(forKey: modeKey),
           let mode = AppearanceMode(rawValue: savedMode) {
            currentMode = mode
        } else {
            currentMode = .system
        }
    }

    // Function to set the appearance mode
    func setAppearanceMode(_ mode: AppearanceMode) {
        currentMode = mode

        // Set the appearance mode globally
            switch mode {
            case .light:
                if #available(iOS 13.0, *) {
                    UIApplication.shared.connectedScenes.forEach { scene in
                        if let windowScene = scene as? UIWindowScene {
                            windowScene.windows.forEach { window in
                                window.overrideUserInterfaceStyle = .light
                            }
                        }
                    }
                } else {
                    UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = .light }
                }
            case .dark:
                if #available(iOS 13.0, *) {
                    UIApplication.shared.connectedScenes.forEach { scene in
                        if let windowScene = scene as? UIWindowScene {
                            windowScene.windows.forEach { window in
                                window.overrideUserInterfaceStyle = .dark
                            }
                        }
                    }
                } else {
                    UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = .dark }
                }
            case .system:
                if #available(iOS 13.0, *) {
                    // Iterate through all connected scenes
                    UIApplication.shared.connectedScenes.forEach { scene in
                        // Check if the scene is a UIWindowScene
                        if let windowScene = scene as? UIWindowScene {
                            // Iterate through all windows in that window scene
                            windowScene.windows.forEach { window in
                                window.overrideUserInterfaceStyle = .unspecified
                            }
                        }
                    }
                } else {
                    // Fallback for iOS versions prior to 13 (though the original code was deprecated in iOS 15,
                    // the 'windows' property was available before iOS 13, and 'overrideUserInterfaceStyle'
                    // on UIWindow was introduced in iOS 13. For the exact original code, this else block
                    // would only be relevant if you explicitly supported < iOS 13 and needed to handle
                    // the style there, which is less common for this specific deprecation context).
                    // The original code `UIApplication.shared.windows.forEach` works on iOS 13 and 14
                    // but is deprecated from iOS 15.
                    UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = .unspecified }
                }
        }
    }
}
