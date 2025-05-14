//
//  WeatherEntity.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//
import Foundation

struct Forecast: Identifiable {
    let id = UUID()
    let date: String
    let isNight: Bool
    let day: String
    let temp: String
    let condition: String
    let symbolName: String
}

struct WeatherData {
    let date: String
    let isNight: Bool
    let day: String
    let currentTemp: String
    let condition: String
    let symbolName: String
    let forecastDay: [Forecast]
    let forecastNight: [Forecast]
}

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
    let main: String
}
