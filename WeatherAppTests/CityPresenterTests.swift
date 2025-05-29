//
//  CityPresenterTests.swift
//  WeatherAppTests
//
//  Created by Vaishnavi Deshmukh on 29/05/25.
//

import XCTest
@testable import WeatherApp

final class CitySearchPresenterTests: XCTestCase {
    var presenter: CitySearchPresenter!
    var mockInteractor: MockCitySearchInteractor!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockCitySearchInteractor()
        presenter = CitySearchPresenter(interactor: mockInteractor)
    }
    
    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        super.tearDown()
    }
    
    func testEmptyQueryClearsSuggestionsAndError() {
        self.presenter.query = ""
        
        let expectation = XCTestExpectation(description: "Wait for failure handling")
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.presenter.suggestions, [])
            XCTAssertNil(self.presenter.errorMessage)
            XCTAssertNil(self.mockInteractor.fetchCalledWith)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNonEmptyQueryFetchesSuggestionsSuccessfully() {
        let expectedCities = [
            CityModel(name: "London", localNames: LocalNamesModel(en: "London"), lat: 51.5074, lon: -0.1278, country: "UK", state: "England"),
            CityModel(name: "Los Angeles", localNames: LocalNamesModel(en: "Los Angeles"), lat: 34.0522, lon: -118.2437, country: "US", state: "California")
        ]
        
        mockInteractor.mockCities = expectedCities
        presenter.query = "Lo"
        
        let expectation = XCTestExpectation(description: "Wait for suggestions update")
        
        // Poll every 0.1s until suggestions match expected
        let timeout = 1.0
        let start = Date()
        
        func check() {
            if self.presenter.suggestions == expectedCities {
                XCTAssertEqual(self.mockInteractor.fetchCalledWith, "Lo")
                XCTAssertNil(self.presenter.errorMessage)
                expectation.fulfill()
            } else if Date().timeIntervalSince(start) > timeout {
                XCTFail("Suggestions not updated in time")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: check)
            }
        }
        
        check()
        wait(for: [expectation], timeout: timeout + 0.2)
    }

    
    func testNonEmptyQueryFetchesSuggestionsWithError() {
        mockInteractor.mockError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        presenter.query = "Pa"
        
        let expectation = XCTestExpectation(description: "Wait for error message")
        
        let timeout = 1.0
        let start = Date()
        
        func check() {
            if self.presenter.errorMessage == "Network error" {
                XCTAssertEqual(self.presenter.suggestions, [])
                expectation.fulfill()
            } else if Date().timeIntervalSince(start) > timeout {
                XCTFail("Error message not updated in time")
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: check)
            }
        }
        
        check()
        wait(for: [expectation], timeout: timeout + 0.2)
    }


    
    func testCityTappedUpdatesQueryAndClearsSuggestionsAndCallsCallback() {
        let city = CityModel(
            name: "Tokyo",
            localNames: LocalNamesModel(en: "Tokyo"),
            lat: 35.6762,
            lon: 139.6503,
            country: "JP",
            state: nil
        )
        
        var selectedCity: CityModel?
        presenter.suggestions = [city]
        presenter.onCitySelected = { selectedCity = $0 }
        
        presenter.cityTapped(city)
        
        XCTAssertEqual(presenter.query, "Tokyo")
        XCTAssertEqual(presenter.suggestions, [])
        XCTAssertEqual(selectedCity?.name, "Tokyo")
    }
}

class MockCitySearchInteractor: CitySearchInteractorProtocol {
    var fetchCalledWith: String?
    var mockCities: [CityModel] = []
    var mockError: Error?
    
    func fetchCitySuggestions(for query: String, completion: @escaping ([CityModel], Error?) -> Void) {
        fetchCalledWith = query
        DispatchQueue.main.async {
            completion(self.mockCities, self.mockError)
        }
    }
}

