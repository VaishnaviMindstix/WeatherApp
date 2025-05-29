//
//  WeatherInteractorTests.swift
//
//
//  Created by Vaishnavi Deshmukh on 15/05/25.
//

import XCTest
@testable import WeatherApp

final class WeatherInteractorTests: XCTestCase {
    var interactor: WeatherInteractor!
    var mockPresenter: MockWeatherPresenter!
    var mockHistoryInteractor: MockWeatherHistoryInteractor!
    let context = PersistenceController.shared.container.viewContext
    
    override func setUp() {
        super.setUp()
        interactor = WeatherInteractor()
        mockPresenter = MockWeatherPresenter()
        mockHistoryInteractor = MockWeatherHistoryInteractor(context: context)
        interactor.presenter = mockPresenter
        interactor.interactorHistory = mockHistoryInteractor
        interactor.apiKey = Secrets.apiKey
    }
    
    // MARK: - URL Tests
    
    func testMakeWeatherURL() {
        let url = interactor.makeWeatherURL()
        XCTAssertNotNil(url, "URL should not be nil")
        XCTAssertTrue(url?.absoluteString.contains("lat=18.5204") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("appid=") ?? false)
    }
    
    func testMakeWeatherURL_missingAPIKey() {
        interactor.apiKey = nil
        let url = interactor.makeWeatherURL()
        XCTAssertNil(url, "URL should be nil when API key is missing")
    }
    
    // MARK: - Networking Tests
    
    func testFetchWeather_Success() {
        let jsonData = loadMockJSONData(named: "weather_response")!
        let url = interactor.makeWeatherURL()!
        
        URLProtocolMock.testURLs = [url: jsonData]
        URLProtocolMock.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        interactor.urlSession = URLSession(configuration: config)
        
        mockPresenter.didFetchWeatherHandler = { data, city in
            XCTAssertEqual(data.city, "Pune")
            XCTAssertNotNil(self.mockHistoryInteractor.addedWeather)
        }
        
        interactor.fetchWeather()
    }
    
    func testFetchWeather_NetworkFailure() {
        let url = interactor.makeWeatherURL()!
        URLProtocolMock.error = NSError(domain: "network", code: -1009, userInfo: nil)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        interactor.urlSession = URLSession(configuration: config)
        
        let expectation = self.expectation(description: "Error received")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            XCTAssertEqual((error as NSError).code, -1009)
            expectation.fulfill()
        }
        
        interactor.fetchWeather()
        waitForExpectations(timeout: 2)
    }
    
    func testFetchWeather_JSONDecodingFailure() {
        let invalidData = Data("Invalid JSON".utf8)
        let url = interactor.makeWeatherURL()!
        URLProtocolMock.testURLs = [url: invalidData]
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        interactor.urlSession = URLSession(configuration: config)
        
        let expectation = self.expectation(description: "Decoding error received")
        
        mockPresenter.didFailFetchingWeatherHandler = { _ in
            expectation.fulfill()
        }
        
        interactor.fetchWeather()
        waitForExpectations(timeout: 2)
    }
    
    // MARK: - Parsing Tests
    
    func testParseDateInfo_validFormat() {
        let result = interactor.parseDateInfo(from: "2025-05-28 20:00:00")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.shortDayOfWeek.count, 3)
    }
    
    func testParseDateInfo_invalidFormat() {
        let result = interactor.parseDateInfo(from: "not-a-date")
        XCTAssertNil(result, "Should return nil for invalid date string")
    }
    
    // MARK: - Symbol Mapping
    
    func testSfSymbolName_forClearDay() {
        let symbol = interactor.sfSymbolName(for: 800, isNight: false)
        XCTAssertEqual(symbol, "sun.max.fill")
    }
    
    func testSfSymbolName_forClearNight() {
        let symbol = interactor.sfSymbolName(for: 800, isNight: true)
        XCTAssertEqual(symbol, "moon.stars.fill")
    }
    
    // MARK: - Forecast Creation
    
    func testMakeForecastDayAndNight() {
        let data = loadMockJSONData(named: "weather_response")!
        let decoded = try! JSONDecoder().decode(OpenWeatherResponseModel.self, from: data)
        
        let grouped = Dictionary(grouping: decoded.list, by: { $0.dateString })
        let key = grouped.keys.sorted().first!
        let forecastDay = interactor.makeForecast(from: grouped[key], isNight: false)
        let forecastNight = interactor.makeForecast(from: grouped[key], isNight: true)
        
        XCTAssertNotNil(forecastDay)
        XCTAssertNotNil(forecastNight)
    }
    
    func testMakeForecast_withEmptyList() {
        let forecast = interactor.makeForecast(from: [], isNight: false)
        XCTAssertNil(forecast, "Forecast should be nil for empty data")
    }

    // MARK: - Helpers
    
    func loadMockJSONData(named name: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }
    
    // MARK: - Response Handling Tests
    

    func testHandleWeatherResponse_validData() {
        let data = loadMockJSONData(named: "weather_response")!
        let response = try! JSONDecoder().decode(OpenWeatherResponseModel.self, from: data)
        
        interactor.city = CityModel(name: "Pune", localNames: LocalNamesModel(en: "Pune"), lat: 48.8566, lon: 2.3522, country: "FR", state: "Mh")
        
        let expectation = self.expectation(description: "Valid response processed")
        
        mockPresenter.didFetchWeatherHandler = { weather, city in
            XCTAssertEqual(city.name, "Pune")
            XCTAssertEqual(weather.city, "Pune")
            expectation.fulfill()
        }
        
        interactor.handleWeatherResponse(response)
        
        waitForExpectations(timeout: 1)
    }

    
    func testHandleWeatherResponse_emptyList_shouldFail() {
        let response = OpenWeatherResponseModel(list: [])
        
        let expectation = self.expectation(description: "Failed due to missing current entry")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            XCTAssertEqual(error.localizedDescription, "Unable to determine current forecast")
            expectation.fulfill()
        }
        
        interactor.handleWeatherResponse(response)
        
        waitForExpectations(timeout: 1)
    }

    func testHandleWeatherResponse_missingWeather_shouldFail() {
        let main = MainModel(temp: 25)
        let now = Date()
        let entry = WeatherEntryModel(main: main,
                                         weather: [],
                                      dtTxt: WeatherInteractor.outputFormatter.string(from: now))
        let response = OpenWeatherResponseModel(list: [entry])
        
        let expectation = self.expectation(description: "Failed due to missing weather")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            XCTAssertEqual(error.localizedDescription, "Unable to determine current forecast")
            expectation.fulfill()
        }
        
        interactor.handleWeatherResponse(response)
        
        waitForExpectations(timeout: 1)
    }

    
    func testHandleWeatherResponse_invalidDateString_shouldFail() {
        
        let weather = WeatherModel(id: 800, description: "Clear")
        let main = MainModel(temp: 20)
        let now = Date()
        let entry = WeatherEntryModel(main: main,
                                         weather: [weather],
                                         dtTxt: "Invalid-Date")
        let response = OpenWeatherResponseModel(list: [entry])
        
        let expectation = self.expectation(description: "Failed due to invalid date string")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            XCTAssertEqual(error.localizedDescription, "Unable to determine current forecast")
            expectation.fulfill()
        }
        
        interactor.handleWeatherResponse(response)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchWeather_dataIsNil_shouldReturnNoDataError() {
        let expectation = self.expectation(description: "Expecting noData error")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            if case WeatherError.noData = error {
                expectation.fulfill()
            } else {
                XCTFail("Expected noData error")
            }
        }
        
        interactor.presenter = mockPresenter
        interactor.handleWeatherAPIResponse(data: nil)
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchWeather_invalidJSON_shouldReturnParsingError() {
        let expectation = self.expectation(description: "Expecting parsing error")
        
        mockPresenter.didFailFetchingWeatherHandler = { error in
            if case WeatherError.parsingError = error {
                expectation.fulfill()
            } else {
                XCTFail("Expected parsingError")
            }
        }
        
        let invalidData = Data("Invalid JSON".utf8)
        interactor.presenter = mockPresenter
        interactor.handleWeatherAPIResponse(data: invalidData)
        
        waitForExpectations(timeout: 1)
    }



}

// MARK: - Mocks

class MockWeatherPresenter: WeatherPresenterProtocol {
    var didFetchWeatherHandler: ((WeatherDataModel, CityModel) -> Void)?
    var didFailFetchingWeatherHandler: ((Error) -> Void)?
    
    func didFetchWeather(_ weatherData: WeatherDataModel, city: CityModel) {
        didFetchWeatherHandler?(weatherData, city)
    }
    
    func didFailFetchingWeather(_ error: Error) {
        didFailFetchingWeatherHandler?(error)
    }
}

class MockWeatherHistoryInteractor: WeatherHistoryInteractor {
    var addedWeather: WeatherDataModel?
    
    override func addWeatherItem(_ data: WeatherDataModel) {
        addedWeather = data
    }
}

class URLProtocolMock: URLProtocol {
    static var testURLs = [URL?: Data]()
    static var response: URLResponse?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        if let error = URLProtocolMock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let data = URLProtocolMock.testURLs[request.url] ?? Data()
            client?.urlProtocol(self, didReceive: URLProtocolMock.response ?? URLResponse(), cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
