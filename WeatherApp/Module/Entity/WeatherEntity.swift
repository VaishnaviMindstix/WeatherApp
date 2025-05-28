//
//  WeatherEntity.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//
import Foundation

struct WeatherDataModel:Identifiable {
    let id = UUID()
    let city: String
    let date: String
    let isNight: Bool
    let day: String
    let currentTemp: String
    let condition: String
    let conditionId: Int
    let symbolName: String
    let forecastDay: [ForecastModel]?
    let forecastNight: [ForecastModel]?
    
    public init(city: String, date: String, isNight: Bool, day: String, currentTemp: String, condition: String, conditionId: Int, symbolName: String, forecastDay: [ForecastModel]?, forecastNight: [ForecastModel]?) {
        self.city = city
        self.date = date
        self.isNight = isNight
        self.day = day
        self.currentTemp = currentTemp
        self.condition = condition
        self.conditionId = conditionId
        self.symbolName = symbolName
        self.forecastDay = forecastDay
        self.forecastNight = forecastNight
    }
}

struct ForecastModel: Identifiable {
    let id = UUID()
    let date: String
    let isNight: Bool
    let day: String
    let temp: String
    let condition: String
    let conditionId: Int
    let symbolName: String
    
    public init(date: String, isNight: Bool, day: String, temp: String, condition: String, conditionId: Int, symbolName: String) {
        self.date = date
        self.isNight = isNight
        self.day = day
        self.temp = temp
        self.condition = condition
        self.conditionId = conditionId
        self.symbolName = symbolName
    }
}



struct OpenWeatherResponseModel: Codable {
    let list: [WeatherEntryModel]
}


struct WeatherEntryModel: Codable {
    let main: MainModel
    let weather: [WeatherModel]
    let dtTxt: String
    var date: Date {
        WeatherInteractor.inputFormatter.date(from: dtTxt) ?? Date()
    }
    
    var dateString: String {
        let date = WeatherInteractor.inputFormatter.date(from: dtTxt) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case main, weather
        case dtTxt = "dt_txt"
    }
}

struct MainModel: Codable {
    let temp: Double
}

struct WeatherModel: Codable {
    let id: Int
    let description: String
}

    
struct CityModel: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let localNames: LocalNamesModel?
    let lat, lon: Double
    let country, state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}


struct LocalNamesModel: Codable {
    let kn, mr, ru, ta, ur, ja, pa, hi, en, ar, ml, uk: String?
}

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case parsingError(Error)
}
