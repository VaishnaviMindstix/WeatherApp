//
//  WeatherEntity.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//
import Foundation

struct OpenWeatherResponse: Codable {
    let list: [WeatherEntry]
}

struct WeatherEntry: Codable {
    let dt_txt: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
    let description: String
}

    
public struct City: Identifiable, Decodable {
    public let id = UUID()
    public let name: String
    public let localNames: LocalNames?
    public let lat, lon: Double
    public let country, state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}


public struct LocalNames: Codable {
    public let kn, mr, ru, ta, ur, ja, pa, hi, en, ar, ml, uk: String?
}
