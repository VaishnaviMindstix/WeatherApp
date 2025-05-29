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
    var interactorHistory: WeatherHistoryInteractor?
    
    var apiKey: String?
    var urlSession: URLSession = .shared
    
    var city: CityModel = CityModel(
        name: "Pune",
        localNames: LocalNamesModel(en: "Pune"),
        lat: 18.5204,
        lon: 73.8567,
        country: "IN",
        state: "Maharashtra"
    )
    
//    func fetchWeather() {
//        guard let url = makeWeatherURL() else { return }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.presenter?.didFailFetchingWeather(error)
//                }
//                return
//            }
//
//            guard let data = data else { return }
//
//            do {
//                let response = try JSONDecoder().decode(OpenWeatherResponseModel.self, from: data)
//                self.handleWeatherResponse(response)
//            } catch {
//                DispatchQueue.main.async {
//                    self.presenter?.didFailFetchingWeather(error)
//                }
//            }
//        }.resume()
//    }
    
    func fetchWeather() {
        guard let url = makeWeatherURL() else {
            presenter?.didFailFetchingWeather(WeatherError.invalidURL)
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.presenter?.didFailFetchingWeather(error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.presenter?.didFailFetchingWeather(WeatherError.invalidResponse)
                }
                return
            }
            
            self.handleWeatherAPIResponse(data: data)
        }
        
        task.resume()
    }
    
    func handleWeatherAPIResponse(data: Data?) {
        guard let data = data else {
            DispatchQueue.main.async {
                self.presenter?.didFailFetchingWeather(WeatherError.noData)
            }
            return
        }
        
        do {
            let response = try JSONDecoder().decode(OpenWeatherResponseModel.self, from: data)
            self.handleWeatherResponse(response)
        } catch {
            DispatchQueue.main.async {
                self.presenter?.didFailFetchingWeather(WeatherError.parsingError(error))
            }
        }
    }

    // MARK: - Helpers
    
    func makeWeatherURL() -> URL? {
        guard let apiKey = apiKey else { return nil }
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(city.lat)&lon=\(city.lon)&appid=\(apiKey)&units=metric"
        return URL(string: urlString)
    }
    
    func handleWeatherResponse(_ response: OpenWeatherResponseModel) {
        let entries = response.list
        let now = Date()
        
        guard
            let currentEntry = entries.min(by: { abs($0.date.timeIntervalSince(now)) < abs($1.date.timeIntervalSince(now)) }),
            let firstWeather = currentEntry.weather.first,
            let dateInfo = parseDateInfo(from: currentEntry.dtTxt)
        else {
            DispatchQueue.main.async {
                self.presenter?.didFailFetchingWeather(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to determine current forecast"]))
            }
            return
        }
        
        let groupedEntries = Dictionary(grouping: entries, by: { $0.dateString })
        let sortedKeys = groupedEntries.keys.sorted().prefix(5)
        
        let forecastDay = sortedKeys.compactMap { self.makeForecast(from: groupedEntries[$0], isNight: false) }
        let forecastNight = sortedKeys.compactMap { self.makeForecast(from: groupedEntries[$0], isNight: true) }
        
        let weatherData = WeatherDataModel(
            city: city.name,
            date: dateInfo.formattedDate,
            isNight: dateInfo.isNight,
            day: dateInfo.shortDayOfWeek,
            currentTemp: "\(Int(currentEntry.main.temp))°",
            condition: firstWeather.description,
            conditionId: firstWeather.id,
            symbolName: sfSymbolName(for: firstWeather.id, isNight: dateInfo.isNight),
            forecastDay: forecastDay,
            forecastNight: forecastNight
        )
        
        DispatchQueue.main.async {
            self.presenter?.didFetchWeather(weatherData, city: self.city)
            self.interactorHistory?.addWeatherItem(weatherData)
        }
    }
    
    func makeForecast(from entries: [WeatherEntryModel]?, isNight: Bool) -> ForecastModel? {
        guard
            let entry = entries?.first(where: {
                let hour = Calendar.current.component(.hour, from: $0.date)
                return isNight ? (hour < 6 || hour >= 18) : (hour >= 6 && hour < 18)
            }),
            let weather = entry.weather.first,
            let info = parseDateInfo(from: entry.dtTxt)
        else {
            return nil
        }
        
        return ForecastModel(
            date: info.formattedDate,
            isNight: info.isNight,
            day: info.shortDayOfWeek,
            temp: "\(Int(entry.main.temp))°",
            condition: weather.description,
            conditionId: weather.id,
            symbolName: sfSymbolName(for: weather.id, isNight: info.isNight)
        )
    }
    
    func parseDateInfo(from dateTimeString: String) -> (formattedDate: String, isNight: Bool, shortDayOfWeek: String)? {
        guard let date = Self.inputFormatter.date(from: dateTimeString) else { return nil }
        
        let formattedDate = Self.outputFormatter.string(from: date)
        let shortDayOfWeek = Self.shortDayFormatter.string(from: date)
        let hour = Calendar.current.component(.hour, from: date)
        let isNight = !(6...17).contains(hour)
        
        return (formattedDate, isNight, shortDayOfWeek)
    }
    
    // MARK: - Static Date Formatters
    
    static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    static let shortDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
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

