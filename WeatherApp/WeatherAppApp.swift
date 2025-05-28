//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 09/05/25.
//

import SwiftUI
import netfox

@main
struct WeatherAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
