//
//  WeatherHistoryInteractorTests.swift
//  
//
//  Created by Vaishnavi Deshmukh on 27/05/25.
//

import XCTest
import CoreData
@testable import WeatherApp

final class WeatherHistoryInteractorTests: XCTestCase {
    var interactor: WeatherHistoryInteractor!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "WeatherHistoryPackage")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        let exp = expectation(description: "Load persistent stores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        
        context = container.viewContext
        interactor = WeatherHistoryInteractor(context: context)
    }
    
    override func tearDown() {
        context = nil
        interactor = nil
        super.tearDown()
    }
    
    func testFetchWeatherItems_whenNoItems_returnsEmptyArray() {
        let items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 0)
    }
    
    func testAddWeatherItem_withValidData_addsItem() {
        let model = WeatherDataModel(city: "Paris", date: "May 20, 2025", isNight: false, day: "Tuesday", currentTemp: "22", condition: "Clear", conditionId: 800, symbolName: "sun.max", forecastDay: [], forecastNight: [])
        
        interactor.addWeatherItem(model)
        
        let items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.city, "Paris")
    }
    
    func testAddWeatherItem_withDuplicate_doesNotAdd() {
        let model = WeatherDataModel(city: "Paris", date: "May 20, 2025", isNight: false, day: "Tuesday", currentTemp: "22", condition: "Clear", conditionId: 800, symbolName: "sun.max", forecastDay: [], forecastNight: [])
        
        interactor.addWeatherItem(model)
        interactor.addWeatherItem(model)
        
        let items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 1)
    }
    
    func testAddWeatherItem_withInvalidDate_doesNotAdd() {
        let model = WeatherDataModel(city: "London", date: "Invalid Date", isNight: false, day: "Tuesday", currentTemp: "18", condition: "Rain", conditionId: 500, symbolName: "cloud.rain", forecastDay: [], forecastNight: [])
        
        interactor.addWeatherItem(model)
        
        let items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 0)
    }
    
    func testAddWeatherItem_removesOldItems() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        let oldDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -11, to: Date())!)
        let recentDate = formatter.string(from: Date())
        
        let oldModel = WeatherDataModel(city: "OldCity", date: oldDate, isNight: false, day: "OldDay", currentTemp: "5", condition: "Snow", conditionId: 600, symbolName: "snow", forecastDay: [], forecastNight: [])
        let newModel = WeatherDataModel(city: "NewCity", date: recentDate, isNight: false, day: "Today", currentTemp: "20", condition: "Cloudy", conditionId: 802, symbolName: "cloud", forecastDay: [], forecastNight: [])
        
        interactor.addWeatherItem(oldModel)
        interactor.addWeatherItem(newModel)
        
        let items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.city, "NewCity")
    }
    
    func testDeleteItem_removesCorrectItem() {
        let model1 = WeatherDataModel(city: "A", date: "May 20, 2025", isNight: false, day: "Monday", currentTemp: "20", condition: "Clear", conditionId: 800, symbolName: "sun.max", forecastDay: [], forecastNight: [])
        let model2 = WeatherDataModel(city: "B", date: "May 21, 2025", isNight: false, day: "Tuesday", currentTemp: "21", condition: "Cloudy", conditionId: 801, symbolName: "cloud", forecastDay: [], forecastNight: [])
        
        interactor.addWeatherItem(model1)
        interactor.addWeatherItem(model2)
        
        var items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 2)
        
        interactor.deleteItem(at: IndexSet(integer: 0))
        
        items = interactor.fetchWeatherItems()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.city, "B")
    }
}
