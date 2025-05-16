//
//  Secrets.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 16/05/25.
//

import Foundation

enum Secrets {
    static var apiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["OpenWeatherAPIKey"] as? String
        else {
            fatalError("API Key missing in Secrets.plist")
        }
        return key
    }
    }
