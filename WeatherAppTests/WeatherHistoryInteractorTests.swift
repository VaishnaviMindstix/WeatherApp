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
    
    var context: NSManagedObjectContext!
    var interactor: WeatherHistoryInteractor!
    
    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "WeatherHistoryPackage")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        let expectation = self.expectation(description: "Load persistent stores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        context = container.viewContext
        interactor = WeatherHistoryInteractor(context: context)
    }

    
    override func tearDown() {
        interactor = nil
        context = nil
        super.tearDown()
    }
    
    func testAddWeatherItem_addsNewItem() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let today = formatter.string(from: Date())
        
        let model = WeatherDataModel(
            city: "New York",
            date: today,
            isNight: false,
            day: "Monday",
            currentTemp: "25",
            condition: "Clear",
            conditionId: 800,
            symbolName: "sun.max",
            forecastDay: [],
            forecastNight: []
        )
        
        interactor.addWeatherItem(model)
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.city, "New York")
        XCTAssertEqual(results?.first?.date, today)
    }
    
    func testAddWeatherItem_doesNotAddDuplicate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let today = formatter.string(from: Date())
        
        let model = WeatherDataModel(
            city: "New York",
            date: today,
            isNight: false,
            day: "Monday",
            currentTemp: "25",
            condition: "Clear",
            conditionId: 800,
            symbolName: "sun.max",
            forecastDay: [],
            forecastNight: []
        )
        
        interactor.addWeatherItem(model)
        interactor.addWeatherItem(model) // try adding again
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        
        XCTAssertEqual(results?.count, 1)
    }
    
    func testAddWeatherItem_deletesItemsOlderThan10Days() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let oldDate = formatter.string(from: Calendar.current.date(byAdding: .day, value: -11, to: Date())!)
        let newDate = formatter.string(from: Date())
        
        let oldItem = WeatherDataModel(
            city: "OldCity",
            date: oldDate,
            isNight: false,
            day: "OldDay",
            currentTemp: "10",
            condition: "Cloudy",
            conditionId: 801,
            symbolName: "cloud",
            forecastDay: [],
            forecastNight: []
        )
        
        let newItem = WeatherDataModel(
            city: "NewCity",
            date: newDate,
            isNight: false,
            day: "Today",
            currentTemp: "20",
            condition: "Sunny",
            conditionId: 800,
            symbolName: "sun.max",
            forecastDay: [],
            forecastNight: []
        )
        
        interactor.addWeatherItem(oldItem)
        interactor.addWeatherItem(newItem)
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let results = try? context.fetch(fetchRequest)
        
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.city, "NewCity")
    }
}
