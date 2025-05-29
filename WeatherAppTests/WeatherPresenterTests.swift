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
        self.presenter = WeatherPresenter()
    }
    
    override func tearDown() {
        self.presenter = nil
        super.tearDown()
    }
    
    func testDidFetchWeatherUpdatesPropertiesCorrectly() {
        let expectation = XCTestExpectation(description: "Wait for main thread update")
        
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
            localNames: LocalNamesModel(en: "Pune"),
            lat: 18.5204,
            lon: 73.8567,
            country: "IN",
            state: "Maharashtra"
        )
        
        DispatchQueue.main.async {
            self.presenter.didFetchWeather(weatherData, city: city)
            
            XCTAssertEqual(self.presenter.cityNameText, "Pune")
            XCTAssertEqual(self.presenter.countryNameText, "IN")
            XCTAssertEqual(self.presenter.dateText, "May 15")
            XCTAssertEqual(self.presenter.isNight, false)
            XCTAssertEqual(self.presenter.dayText, "Thursday")
            XCTAssertEqual(self.presenter.tempText, "22°C")
            XCTAssertEqual(self.presenter.conditionText, "Sunny")
            XCTAssertEqual(self.presenter.symbolNameText, "sun.max")
            XCTAssertEqual(self.presenter.forecastDay?.count, 1)
            XCTAssertEqual(self.presenter.forecastNight?.count, 1)
            XCTAssertEqual(self.presenter.forecastDay?.first?.symbolName, "sun.max")
            XCTAssertEqual(self.presenter.forecastNight?.first?.symbolName, "moon.stars")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    func testDidFailFetchingWeatherResetsProperties() {
        let expectation = XCTestExpectation(description: "Wait for failure handling")
        
        let error = NSError(domain: "WeatherError", code: 500, userInfo: nil)
        
        DispatchQueue.main.async {
            self.presenter.didFailFetchingWeather(error)
            
            XCTAssertEqual(self.presenter.cityNameText, "--")
            XCTAssertEqual(self.presenter.countryNameText, "--")
            XCTAssertEqual(self.presenter.dateText, "--")
            XCTAssertEqual(self.presenter.isNight, false)
            XCTAssertEqual(self.presenter.dayText, "--")
            XCTAssertEqual(self.presenter.tempText, "--")
            XCTAssertEqual(self.presenter.conditionText, "Error")
            XCTAssertEqual(self.presenter.symbolNameText, "--")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

}
