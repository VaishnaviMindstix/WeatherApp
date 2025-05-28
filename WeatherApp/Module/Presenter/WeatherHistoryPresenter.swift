import Foundation
import Combine

final class WeatherHistoryPresenter: ObservableObject {
    private let interactor: WeatherHistoryInteractorProtocol

    @Published var items: [WeatherDataModel] = []

    init(interactor: WeatherHistoryInteractorProtocol) {
        self.interactor = interactor
    }

    func loadItems() {
        items = interactor.fetchWeatherItems()
    }

    func addItem(data: WeatherDataModel){
        interactor.addWeatherItem(data)
        loadItems()
    }
    func addSampleItem() {
        let model = WeatherDataModel(
            city: "--",
            date: "--- 00, 0000",
            isNight: true,
            day: "---",
            currentTemp: "00°",
            condition: "--",
            conditionId: 000,
            symbolName: "--",
            forecastDay: nil,
            forecastNight: nil
        )
        interactor.addWeatherItem(model)
        loadItems()
    }

    func deleteItem(at offsets: IndexSet) {
        interactor.deleteItem(at: offsets)
        loadItems()
    }
}
