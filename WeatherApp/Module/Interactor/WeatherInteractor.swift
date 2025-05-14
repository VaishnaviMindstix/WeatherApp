//
//  WeatherInteractor.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

protocol WeatherInteractorProtocol {
    func fetchWeather()
}

class WeatherInteractor: WeatherInteractorProtocol {
    var presenter: WeatherPresenterProtocol?
    
    private let apiKey = "7680173a10a51e4c9f257d3c59a84f9c"
    private let city = "Pune"
    
    func fetchWeather() {
        let urlString =
        "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                self.presenter?.didFailFetchingWeather(error!)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                let entries = decoded.list
                
                let now = Date()
                
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                inputFormatter.timeZone = TimeZone.current
                
                let currentEntry = entries.min(by: {
                    guard let date1 = inputFormatter.date(from: $0.dt_txt),
                          let date2 = inputFormatter.date(from: $1.dt_txt) else { return false }
                    return abs(date1.timeIntervalSince(now)) < abs(date2.timeIntervalSince(now))
                })
                
                guard let current = currentEntry,
                      let currentDateInfo = self.parseDateInfo(from: current.dt_txt),
                      let currentCondition = current.weather.first?.main else {
                    DispatchQueue.main.async {
                        self.presenter?.didFailFetchingWeather(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to determine current forecast"]))
                    }
                    return
                }
                
                var groupedByDate: [String: [WeatherEntry]] = [:]
                for entry in entries {
                    if let date = inputFormatter.date(from: entry.dt_txt) {
                        let keyFormatter = DateFormatter()
                        keyFormatter.dateFormat = "yyyy-MM-dd"
                        keyFormatter.timeZone = TimeZone.current
                        let dayKey = keyFormatter.string(from: date)
                        
                        groupedByDate[dayKey, default: []].append(entry)
                    }
                }
                
                let sortedDays = groupedByDate.keys.sorted().prefix(5) // Next 5 days
                var forecastDay: [Forecast] = []
                var forecastNight: [Forecast] = []
                
                for day in sortedDays {
                    let entriesForDay = groupedByDate[day] ?? []
                    
                    let dayEntry = entriesForDay.first(where: {
                        if let date = inputFormatter.date(from: $0.dt_txt) {
                            let hour = Calendar.current.component(.hour, from: date)
                            return hour >= 6 && hour < 18
                        }
                        return false
                    })
                    
                    let nightEntry = entriesForDay.first(where: {
                        if let date = inputFormatter.date(from: $0.dt_txt) {
                            let hour = Calendar.current.component(.hour, from: date)
                            return hour < 6 || hour >= 18
                        }
                        return false
                    })
                    
                    if let dayEntry = dayEntry,
                       let info = self.parseDateInfo(from: dayEntry.dt_txt) {
                        forecastDay.append(Forecast(
                            date: info.formattedDate,
                            isNight: info.isNight,
                            day: info.shortDayOfWeek,
                            temp: "\(Int(dayEntry.main.temp))°",
                            condition: dayEntry.weather.first?.main ?? "N/A",
                            symbolName: self.sfSymbolName(for: dayEntry.weather.first?.main ?? "N/A")
                        ))
                    }
                    
                    if let nightEntry = nightEntry,
                       let info = self.parseDateInfo(from: nightEntry.dt_txt) {
                        forecastNight.append(Forecast(
                            date: info.formattedDate,
                            isNight: info.isNight,
                            day: info.shortDayOfWeek,
                            temp: "\(Int(nightEntry.main.temp))°",
                            condition: nightEntry.weather.first?.main ?? "N/A",
                            symbolName: self.sfSymbolName(for: nightEntry.weather.first?.main ?? "N/A")
                        ))
                    }
                }
                
                let weatherData = WeatherData(
                    date: currentDateInfo.formattedDate,
                    isNight: currentDateInfo.isNight,
                    day: currentDateInfo.shortDayOfWeek,
                    currentTemp: "\(Int(current.main.temp))°",
                    condition: currentCondition,
                    symbolName: self.sfSymbolName(for: currentCondition),
                    forecastDay: forecastDay,
                    forecastNight: forecastNight
                )
                
                DispatchQueue.main.async {
                    self.presenter?.didFetchWeather(weatherData)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.presenter?.didFailFetchingWeather(error)
                }
            }
            
        }.resume()
    }
    
    func parseDateInfo(from dateTimeString: String) -> (formattedDate: String, isNight: Bool, shortDayOfWeek: String)? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = TimeZone.current
        
        guard let date = inputFormatter.date(from: dateTimeString) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy"
        let formattedDate = outputFormatter.string(from: date)
        
        let shortDayFormatter = DateFormatter()
        shortDayFormatter.dateFormat = "E" // short day format
        let shortDayOfWeek = shortDayFormatter.string(from: date)
        
        let hour = Calendar.current.component(.hour, from: date)
        let isNight = (hour >= 6 && hour < 18) ? false : true
        
        return (formattedDate, isNight, shortDayOfWeek)
    }
    
    func sfSymbolName(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        case "smoke":
            return "smoke.fill"
        case "dust", "sand", "ash":
            return "sun.dust.fill"
        case "squall":
            return "wind"
        case "tornado":
            return "tornado"
        default:
            return "questionmark.circle"
        }
    }

}
