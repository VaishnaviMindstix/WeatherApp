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
        
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)
        
        interactor.fetchCitySuggestions(for: "London") { result, error in
            XCTAssertTrue(result.isEmpty)
            XCTAssertNotNil(error)
            if let error = error as? URLError {
                XCTAssertEqual(error.code, .notConnectedToInternet)
            }
        }
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
        }
        
    }
}

//class CitySearchInteractorTests: XCTestCase {
//
//    func testFetchCitySuggestions_withEmptyQuery_returnsEmptyArray() {
//        let interactor = CitySearchInteractor(session: MockURLSession())
//
//        let expectation = self.expectation(description: "Completion called")
//
//        interactor.fetchCitySuggestions(for: "") { cities, error in
//            XCTAssertTrue(cities.isEmpty)
//            XCTAssertNil(error)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetchCitySuggestions_withInvalidURL_returnsBadURLError() {
//        // Setup a query that results in an invalid URL (e.g., encoding fails)
//        let mockSession = MockURLSession()
//        let interactor = CitySearchInteractor(session: mockSession)
//
//        let expectation = self.expectation(description: "Completion called")
//
//        // Use a query that will definitely produce an invalid URL
//        interactor.fetchCitySuggestions(for: "%%") { cities, error in
//            XCTAssertTrue(cities.isEmpty)
//            XCTAssertNotNil(error)
//            XCTAssertEqual((error as? URLError)?.code, .badURL)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetchCitySuggestions_networkError_returnsError() {
//        let mockSession = MockURLSession()
//        let expectedError = NSError(domain: "test", code: 123)
//        mockSession.error = expectedError
//
//        let interactor = CitySearchInteractor(session: mockSession)
//        let expectation = self.expectation(description: "Completion called")
//
//        interactor.fetchCitySuggestions(for: "London") { cities, error in
//            XCTAssertTrue(cities.isEmpty)
//            XCTAssertEqual(error as NSError?, expectedError)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetchCitySuggestions_noData_returnsBadServerResponse() {
//        let mockSession = MockURLSession()
//        mockSession.data = nil
//
//        let interactor = CitySearchInteractor(session: mockSession)
//        let expectation = self.expectation(description: "Completion called")
//
//        interactor.fetchCitySuggestions(for: "Paris") { cities, error in
//            XCTAssertTrue(cities.isEmpty)
//            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetchCitySuggestions_decodingSuccess_returnsCities() throws {
//        let mockSession = MockURLSession()
//        let city = CityModel(name: "Paris", localNames: nil, lat: 48.8566, lon: 2.3522, country: "FR", state: nil)
//        mockSession.data = try JSONEncoder().encode([city])
//
//        let interactor = CitySearchInteractor(session: mockSession)
//        let expectation = self.expectation(description: "Completion called")
//
//        interactor.fetchCitySuggestions(for: "Paris") { cities, error in
//            XCTAssertNil(error)
//            XCTAssertEqual(cities.count, 1)
//            XCTAssertEqual(cities.first?.name, "Paris")
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testFetchCitySuggestions_decodingFailure_returnsError() {
//        let mockSession = MockURLSession()
//        mockSession.data = "invalid json".data(using: .utf8)
//
//        let interactor = CitySearchInteractor(session: mockSession)
//        let expectation = self.expectation(description: "Completion called")
//
//        interactor.fetchCitySuggestions(for: "Paris") { cities, error in
//            XCTAssertTrue(cities.isEmpty)
//            XCTAssertNotNil(error)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 1)
//    }
//}


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




import XCTest
@testable import WeatherApp

class MockURLSession: URLSession {
    var data: Data?
    var error: Error?
    
    override func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    override func resume() {
        closure()
    }
}


