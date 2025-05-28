//
//  CityInteractorTests.swift
//  WeatherAppTests
//
//  Created by Vaishnavi Deshmukh on 29/05/25.
//

import XCTest
@testable import WeatherApp

final class CitySearchInteractorTests: XCTestCase {
    var interactor: CitySearchInteractor!

    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)
        
        interactor = CitySearchInteractor(session: mockSession)
    }

    
    override func tearDown() {
        interactor = nil
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubError = nil
        super.tearDown()
    }
    
    func testFetchCitySuggestions_withEmptyQuery_returnsEmptyList() {
        let expectation = self.expectation(description: "Empty Query")
        
        interactor.fetchCitySuggestions(for: "") { result, error in
            XCTAssertTrue(result.isEmpty)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchCitySuggestions_withInvalidURL_returnsBadURLError() {
        let badQuery = String(repeating: "😃", count: 10000) // Very long, non-ASCII
        
        interactor.fetchCitySuggestions(for: badQuery) { result, error in
            XCTAssertTrue(result.isEmpty)
            XCTAssertNotNil(error)
            if let error = error as? URLError {
                XCTAssertEqual(error.code, .badURL)
            }
        }
    }

    
    func testFetchCitySuggestions_withNetworkError_returnsError() {
        let expectation = self.expectation(description: "Network Error")
        
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)
        
        interactor.fetchCitySuggestions(for: "London") { result, error in
            XCTAssertTrue(result.isEmpty)
            XCTAssertNotNil(error)
            if let error = error as? URLError {
                XCTAssertEqual(error.code, .notConnectedToInternet)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testFetchCitySuggestions_withInvalidJSON_returnsDecodingError() {
        let expectation = self.expectation(description: "Decoding Error")
        
        MockURLProtocol.stubResponseData = "invalid json".data(using: .utf8)
        
        interactor.fetchCitySuggestions(for: "London") { result, error in
            XCTAssertTrue(result.isEmpty)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testFetchCitySuggestions_withValidResponse_returnsCities() {
        let expectation = self.expectation(description: "Valid Response")
        
        let mockJSON = """
        [
            { "name": "London", "lat": 51.5074, "lon": -0.1278, "country": "GB" }
        ]
        """
        
        MockURLProtocol.stubResponseData = mockJSON.data(using: .utf8)
        
        interactor.fetchCitySuggestions(for: "London") { result, error in
            XCTAssertNil(error)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.name, "London")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
}


class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            let data = MockURLProtocol.stubResponseData ?? Data()
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {}
}
