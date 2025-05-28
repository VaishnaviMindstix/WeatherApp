import Foundation
import Combine

@available(iOS 13.0, *)
final class WeatherHistoryPresenter: ObservableObject {
    private let interactor: WeatherHistoryInteractorProtocol

    @Published var items: [WeatherDataSharedModel] = []

    init(interactor: WeatherHistoryInteractorProtocol) {
        self.interactor = interactor
    }

    func loadItems() {
        items = interactor.fetchWeatherItems()
    }

    func addItem(data: WeatherDataSharedModel){
        interactor.addWeatherItem(data)
        loadItems()
    }
    func addSampleItem() {
        let model = WeatherDataSharedModel(
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
