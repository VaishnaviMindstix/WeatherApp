import Foundation
import CoreData

protocol WeatherHistoryInteractorProtocol {
    func fetchWeatherItems() -> [WeatherDataModel]
    func addWeatherItem(_ item: WeatherDataModel)
    func deleteItem(at offsets: IndexSet)
}

class WeatherHistoryInteractor: WeatherHistoryInteractorProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchWeatherItems() -> [WeatherDataModel] {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.city, ascending: true)]
        guard let results = try? context.fetch(request) else { return [] }

        return results.map {
            WeatherDataModel(
                city: $0.city ?? "--",
                date: $0.date ?? "--",
                isNight: $0.isNight,
                day: $0.day ?? "--",
                currentTemp: $0.currentTemp ?? "--",
                condition: $0.condition ?? "--",
                conditionId: Int($0.conditionId),
                symbolName: $0.symbolName ?? "cloud",
                forecastDay: [],
                forecastNight: []
            )
        }
    }

    func addWeatherItem(_ item: WeatherDataModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        guard let itemDate = dateFormatter.date(from: item.date) else {
            print("Invalid date format for item: \(item.date)")
            return
        }
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@ AND date == %@ AND isNight == %@", item.city, item.date, NSNumber(value: item.isNight))

        guard let existing = try? context.fetch(fetchRequest), existing.isEmpty else {
            print("Duplicate entry for city \(item.city) on \(item.date)")
            return
        }

        let newItem = Item(context: context)
        newItem.city = item.city
        newItem.date = item.date
        newItem.isNight = item.isNight
        newItem.day = item.day
        newItem.currentTemp = item.currentTemp
        newItem.condition = item.condition
        newItem.conditionId = Int32(item.conditionId)
        newItem.symbolName = item.symbolName

        try? context.save()
        
        let allItemsRequest: NSFetchRequest<Item> = Item.fetchRequest()
        if let allItems = try? context.fetch(allItemsRequest) {
            let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
            
            for item in allItems {
                if let dateStr = item.date, let date = dateFormatter.date(from: dateStr), date < tenDaysAgo {
                    context.delete(item)
                }
            }
            
            try? context.save()
        }
    }

    func deleteItem(at offsets: IndexSet) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.city, ascending: true)]

        if let results = try? context.fetch(request) {
            offsets.map { results[$0] }.forEach(context.delete)
            try? context.save()
        }
    }
}
