//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 13/05/25.
//

import SwiftUI
import netfox

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
#if DEBUG
        NFX.sharedInstance().start()
#endif
        return true
    }
}
