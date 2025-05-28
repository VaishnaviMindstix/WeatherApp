//
//  Item+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 26/05/25.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var city: String?
    @NSManaged public var condition: String?
    @NSManaged public var conditionId: Int32
    @NSManaged public var currentTemp: String?
    @NSManaged public var date: String?
    @NSManaged public var day: String?
    @NSManaged public var isNight: Bool
    @NSManaged public var symbolName: String?
    @NSManaged public var id: UUID?

}

extension Item : Identifiable {

}
