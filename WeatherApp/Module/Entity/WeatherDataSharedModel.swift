import Foundation

public struct WeatherDataSharedModel:Identifiable {
    public let id = UUID()
    public let city: String
    public let date: String
    public let isNight: Bool
    public let day: String
    public let currentTemp: String
    public let condition: String
    public let conditionId: Int
    public let symbolName: String
    public let forecastDay: [ForecastSharedModel]?
    public let forecastNight: [ForecastSharedModel]?
    
    public init(city: String, date: String, isNight: Bool, day: String, currentTemp: String, condition: String, conditionId: Int, symbolName: String, forecastDay: [ForecastSharedModel]?, forecastNight: [ForecastSharedModel]?) {
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

public struct ForecastSharedModel: Identifiable {
    public let id = UUID()
    public let date: String
    public let isNight: Bool
    public let day: String
    public let temp: String
    public let condition: String
    public let conditionId: Int
    public let symbolName: String

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

