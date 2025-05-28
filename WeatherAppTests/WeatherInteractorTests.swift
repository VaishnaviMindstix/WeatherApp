//
//  WeatherInteractorTests.swift
//  
//
//  Created by Vaishnavi Deshmukh on 15/05/25.
//

import XCTest
@testable import WeatherApp

@available(iOS 13.0, *)
final class WeatherInteractorTests: XCTestCase {

    func testParseDateInfo_returnsCorrectValues() {
        let interactor = WeatherInteractor()
        let testDateTime = "2025-05-15 20:00:00"
        
        let result = interactor.parseDateInfo(from: testDateTime)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.formattedDate, "May 15, 2025")
        XCTAssertEqual(result?.shortDayOfWeek.count, 3)
        XCTAssertTrue(result!.isNight)
    }
    
    func testSfSymbolName_forClearDay() {
        let interactor = WeatherInteractor()
        let symbol = interactor.sfSymbolName(for: 800, isNight: false)
        XCTAssertEqual(symbol, "sun.max.fill")
    }
    
    func testSfSymbolName_forClearNight() {
        let interactor = WeatherInteractor()
        let symbol = interactor.sfSymbolName(for: 800, isNight: true)
        XCTAssertEqual(symbol, "moon.stars.fill")
    }
}
