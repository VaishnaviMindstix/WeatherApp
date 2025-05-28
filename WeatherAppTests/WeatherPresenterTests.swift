//
//  WeatherPresenterTests.swift
//  
//
//  Created by Vaishnavi Deshmukh on 15/05/25.
//

import XCTest
@testable import WeatherApp


@available(iOS 14.0, *)
final class WeatherPresenterTests: XCTestCase {
    
    var presenter: WeatherPresenter!
    
    override func setUp() {
        super.setUp()
        presenter = WeatherPresenter()
    }
    
    override func tearDown() {
        presenter = nil
        super.tearDown()
    }
    
    func testDidFetchWeatherUpdatesPropertiesCorrectly() {
        let sampleForecastDay = [
            ForecastModel(
                date: "2025-05-15 09:00:00",
                isNight: false,
                day: "Thursday",
                temp: "22°C",
                condition: "Sunny",
                conditionId: 800,
                symbolName: "sun.max"
            )
        ]
        
        let sampleForecastNight = [
            ForecastModel(
                date: "2025-05-15 21:00:00",
                isNight: true,
                day: "Thursday",
                temp: "15°C",
                condition: "Clear Night",
                conditionId: 800,
                symbolName: "moon.stars"
            )
        ]
        
        let weatherData = WeatherDataModel(
            city: "Pune",
            date: "May 15",
            isNight: false,
            day: "Thursday",
            currentTemp: "22°C",
            condition: "Sunny",
            conditionId: 800,
            symbolName: "sun.max",
            forecastDay: sampleForecastDay,
            forecastNight: sampleForecastNight
        )
        
        let city = CityModel(
            name: "Pune",
            localNames: LocalNamesModel(kn: "", mr: "", ru: "", ta: "", ur: "", ja: "", pa: "", hi: "", en: "", ar: "", ml: "", uk: ""),
            lat: 18.5204,
            lon: 73.8567,
            country: "IN",
            state: "Maharashtra"
        )
        
        presenter.didFetchWeather(weatherData, city: city)
        
        XCTAssertEqual(presenter.cityNameText, "Pune")
        XCTAssertEqual(presenter.countryNameText, "IN")
        XCTAssertEqual(presenter.dateText, "May 15")
        XCTAssertEqual(presenter.isNight, false)
        XCTAssertEqual(presenter.dayText, "Thursday")
        XCTAssertEqual(presenter.tempText, "22°C")
        XCTAssertEqual(presenter.conditionText, "Sunny")
        XCTAssertEqual(presenter.symbolNameText, "sun.max")
        XCTAssertEqual(presenter.forecastDay?.count, 1)
        XCTAssertEqual(presenter.forecastNight?.count, 1)
        XCTAssertEqual(presenter.forecastDay?.first?.symbolName, "sun.max")
        XCTAssertEqual(presenter.forecastNight?.first?.symbolName, "moon.stars")
    }
    
    func testDidFailFetchingWeatherResetsProperties() {
        let error = NSError(domain: "WeatherError", code: 500, userInfo: nil)
        
        presenter.didFailFetchingWeather(error)
        XCTAssertEqual(presenter.cityNameText, "--")
        XCTAssertEqual(presenter.countryNameText, "--")
        XCTAssertEqual(presenter.dateText, "--")
        XCTAssertEqual(presenter.isNight, false)
        XCTAssertEqual(presenter.dayText, "--")
        XCTAssertEqual(presenter.tempText, "--")
        XCTAssertEqual(presenter.conditionText, "Error")
        XCTAssertEqual(presenter.symbolNameText, "--")
        XCTAssertTrue(((presenter.forecastDay?.isEmpty) != nil))
        XCTAssertTrue(((presenter.forecastNight?.isEmpty) != nil))
    }
}
