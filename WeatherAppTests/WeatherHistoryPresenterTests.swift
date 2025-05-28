//
//  WeatherHistoryPresenterTests.swift
//  
//
//  Created by Vaishnavi Deshmukh on 27/05/25.
//

import XCTest
@testable import WeatherApp

final class WeatherHistoryPresenterTests: XCTestCase {
    
    final class MockWeatherHistoryInteractor: WeatherHistoryInteractorProtocol {
        var weatherItems: [WeatherDataModel] = []
        var addItemCalled = false
        var deleteItemCalled = false
        
        func fetchWeatherItems() -> [WeatherDataModel] {
            return weatherItems
        }
        
        func addWeatherItem(_ item: WeatherDataModel) {
            addItemCalled = true
            weatherItems.append(item)
        }
        
        func deleteItem(at offsets: IndexSet) {
            deleteItemCalled = true
            weatherItems.remove(atOffsets: offsets)
        }
    }
    
    var presenter: WeatherHistoryPresenter!
    var mockInteractor: MockWeatherHistoryInteractor!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockWeatherHistoryInteractor()
        presenter = WeatherHistoryPresenter(interactor: mockInteractor)
    }
    
    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        super.tearDown()
    }
    
    func testLoadItems() {
        let mockItem = sampleItem()
        mockInteractor.weatherItems = [mockItem]
        presenter.loadItems()
        XCTAssertEqual(presenter.items.count, 1)
        XCTAssertEqual(presenter.items.first?.city, "Test City")
    }
    
    func testAddItem() {
        let item = sampleItem()
        presenter.addItem(data: item)
        XCTAssertTrue(mockInteractor.addItemCalled)
        XCTAssertEqual(presenter.items.count, 1)
        XCTAssertEqual(presenter.items.first?.city, "Test City")
    }
    
    func testAddSampleItem() {
        presenter.addSampleItem()
        XCTAssertTrue(mockInteractor.addItemCalled)
        XCTAssertEqual(presenter.items.count, 1)
        XCTAssertEqual(presenter.items.first?.city, "--")
    }
    
    func testDeleteItem() {
        let item1 = sampleItem(city: "City 1")
        let item2 = sampleItem(city: "City 2")
        mockInteractor.weatherItems = [item1, item2]
        presenter.loadItems()
        presenter.deleteItem(at: IndexSet(integer: 0))
        XCTAssertTrue(mockInteractor.deleteItemCalled)
        XCTAssertEqual(presenter.items.count, 1)
        XCTAssertEqual(presenter.items.first?.city, "City 2")
    }

    private func sampleItem(city: String = "Test City") -> WeatherDataModel {
        WeatherDataModel(
            city: city,
            date: "May 27, 2025",
            isNight: false,
            day: "Tuesday",
            currentTemp: "25",
            condition: "Clear",
            conditionId: 800,
            symbolName: "sun.max",
            forecastDay: nil,
            forecastNight: nil
        )
    }
}

