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

@available(iOS 13.0, *)
class WeatherInteractor: WeatherInteractorProtocol {
    var presenter: WeatherPresenterProtocol?
    var presenterHistory: WeatherHistoryPresenter?
    
    var apiKey: String = ""
    var city: City = City(name: "Pune", localNames: LocalNames(kn: "", mr: "", ru: "", ta: "", ur: "", ja: "", pa: "", hi: "", en: "", ar: "", ml: "", uk: ""), lat: 18.5204, lon: 73.8567, country: "IN", state: "Maharashtra")
    
    func fetchWeather() {
        let urlString =
        "https://api.openweathermap.org/data/2.5/forecast?lat=\(city.lat)&lon=\(city.lon)&appid=\(apiKey)&units=metric"

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
                      let currentConditionId = current.weather.first?.id,
                      let currentCondition = current.weather.first?.description else {
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
                var forecastDay: [ForecastSharedModel] = []
                var forecastNight: [ForecastSharedModel] = []
                
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
                        forecastDay.append(ForecastSharedModel(
                            date: info.formattedDate,
                            isNight: info.isNight,
                            day: info.shortDayOfWeek,
                            temp: "\(Int(dayEntry.main.temp))°",
                            condition: dayEntry.weather.first?.description ?? "N/A",
                            conditionId: dayEntry.weather.first?.id ?? 0,
                            symbolName: self.sfSymbolName(for: dayEntry.weather.first?.id ?? 0, isNight: info.isNight)
                        ))
                    }
                    
                    if let nightEntry = nightEntry,
                       let info = self.parseDateInfo(from: nightEntry.dt_txt) {
                        forecastNight.append(ForecastSharedModel(
                            date: info.formattedDate,
                            isNight: info.isNight,
                            day: info.shortDayOfWeek,
                            temp: "\(Int(nightEntry.main.temp))°",
                            condition: nightEntry.weather.first?.description ?? "N/A",
                            conditionId: nightEntry.weather.first?.id ?? 0,
                            symbolName: self.sfSymbolName(for: nightEntry.weather.first?.id ?? 0, isNight: info.isNight)
                        ))
                    }
                }
                
                let weatherData = WeatherDataSharedModel(
                    city: self.city.name,
                    date: currentDateInfo.formattedDate,
                    isNight: currentDateInfo.isNight,
                    day: currentDateInfo.shortDayOfWeek,
                    currentTemp: "\(Int(current.main.temp))°",
                    condition: currentCondition,
                    conditionId: currentConditionId,
                    symbolName: self.sfSymbolName(for: currentConditionId, isNight: currentDateInfo.isNight),
                    forecastDay: forecastDay,
                    forecastNight: forecastNight
                )
                
                
                
                DispatchQueue.main.async {
                    self.presenter?.didFetchWeather(weatherData, city: self.city)
                    self.presenterHistory?.addItem(data: weatherData)
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
    
    func sfSymbolName(for id: Int, isNight: Bool) -> String {
        if isNight {
            // 🌙 Night symbols
            switch id {
                // Thunderstorm
            case 200, 201, 230, 231:
                return "cloud.bolt.rain"
            case 202, 232:
                return "cloud.bolt.rain.fill"
            case 210, 211:
                return "cloud.bolt"
            case 212:
                return "cloud.bolt.fill"
            case 221:
                return "cloud.bolt.rain"
                
                // Drizzle
            case 300, 301, 310:
                return "cloud.drizzle"
            case 302, 311, 313, 321:
                return "cloud.drizzle.fill"
            case 312, 314:
                return "cloud.heavyrain.fill"
                
                // Rain
            case 500:
                return "cloud.rain"
            case 501:
                return "cloud.rain.fill"
            case 502, 503, 504:
                return "cloud.heavyrain.fill"
            case 511:
                return "snowflake"
            case 520:
                return "cloud.showers"
            case 521, 531:
                return "cloud.showers.fill"
            case 522:
                return "cloud.heavyrain.fill"
                
                // Snow
            case 600:
                return "cloud.snow"
            case 601, 621:
                return "cloud.snow.fill"
            case 602, 622:
                return "cloud.snow.fill"
            case 611, 616, 613:
                return "cloud.sleet.fill"
            case 612:
                return "cloud.sleet"
            case 615:
                return "cloud.snow"
            case 620:
                return "cloud.snow"
                
                // Atmosphere
            case 701:
                return "cloud.fog"
            case 711:
                return "smoke"
            case 721:
                return "moon.haze.fill"
            case 731, 751, 761, 771:
                return "wind"
            case 741:
                return "cloud.fog.fill"
            case 762:
                return "smoke.fill"
            case 781:
                return "tornado"
                
                // Clear
            case 800:
                return "moon.stars.fill"
                
                // Clouds
            case 801:
                return "cloud.moon"
            case 802:
                return "cloud.moon.fill"
            case 803:
                return "cloud.fill"
            case 804:
                return "smoke.fill"
                
            default:
                return "questionmark.circle"
            }
        } else {
            // ☀️ Day symbols
            switch id {
                // Thunderstorm
            case 200, 201, 230, 231:
                return "cloud.bolt.rain"
            case 202, 232:
                return "cloud.bolt.rain.fill"
            case 210, 211:
                return "cloud.bolt"
            case 212:
                return "cloud.bolt.fill"
            case 221:
                return "cloud.bolt.rain"
                
                // Drizzle
            case 300, 301, 310:
                return "cloud.drizzle"
            case 302, 311, 313, 321:
                return "cloud.drizzle.fill"
            case 312, 314:
                return "cloud.heavyrain.fill"
                
                // Rain
            case 500:
                return "cloud.rain"
            case 501:
                return "cloud.rain.fill"
            case 502, 503, 504:
                return "cloud.heavyrain.fill"
            case 511:
                return "snowflake"
            case 520:
                return "cloud.showers"
            case 521, 531:
                return "cloud.showers.fill"
            case 522:
                return "cloud.heavyrain.fill"
                
                // Snow
            case 600:
                return "cloud.snow"
            case 601, 621:
                return "cloud.snow.fill"
            case 602, 622:
                return "cloud.snow.fill"
            case 611, 616, 613:
                return "cloud.sleet.fill"
            case 612:
                return "cloud.sleet"
            case 615:
                return "cloud.snow"
            case 620:
                return "cloud.snow"
                
                // Atmosphere
            case 701:
                return "cloud.fog"
            case 711:
                return "smoke"
            case 721:
                return "sun.haze.fill"
            case 731, 751, 761, 771:
                return "wind"
            case 741:
                return "cloud.fog.fill"
            case 762:
                return "smoke.fill"
            case 781:
                return "tornado"
                
                // Clear
            case 800:
                return "sun.max.fill"
                
                // Clouds
            case 801:
                return "cloud.sun"
            case 802:
                return "cloud.sun.fill"
            case 803:
                return "cloud.fill"
            case 804:
                return "smoke.fill"
                
            default:
                return "questionmark.circle"
            }
        }
    }
}


/*
 Group 2xx: Thunderstorm
 200    thunderstorm with light rain
 201    thunderstorm with rain
 202    thunderstorm with heavy rain
 210    light thunderstorm
 211    thunderstorm
 212    heavy thunderstorm
 221    ragged thunderstorm
 230    thunderstorm with light drizzle
 231    thunderstorm with drizzle
 232    thunderstorm with heavy drizzle
 Group 3xx: Drizzle
 300    light intensity drizzle
 301    drizzle
 302    heavy intensity drizzle
 310    light intensity drizzle rain
 311    drizzle rain
 312    heavy intensity drizzle rain
 313    shower rain and drizzle
 314    heavy shower rain and drizzle
 321    shower drizzle
 Group 5xx: Rain
 500    light rain
 501    moderate rain
 502    heavy intensity rain
 503    very heavy rain
 504    extreme rain
 511    freezing rain
 520    light intensity shower rain
 521    shower rain
 522    heavy intensity shower rain
 531    ragged shower rain
 Group 6xx: Snow
 600    light snow
 601    snow
 602    heavy snow
 611    sleet
 612    light shower sleet
 613    shower sleet
 615    light rain and snow
 616    rain and snow
 620    light shower snow
 621    shower snow
 622    heavy shower snow
 Group 7xx: Atmosphere
 701    mist
 711    smoke
 721    haze
 731    sand/dust whirls
 741    fog
 751    sand
 761    dust
 762    volcanic ash
 771    squalls
 781    tornado
 Group 800: Clear
 800    clear sky
 Group 80x: Clouds
 801    few clouds: 11-25%
 802    scattered clouds: 25-50%
 803    broken clouds: 51-84%
 804    overcast clouds: 85-100%
 */
