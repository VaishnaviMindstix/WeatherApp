import SwiftUI
import CoreData

@available(iOS 14.0, *)
public final class WeatherHistoryRouter {
    public static func createModule() -> WeatherHistoryView {
        let context = PersistenceController.shared.container.viewContext
        let interactor = WeatherHistoryInteractor(context: context)
        let presenter = WeatherHistoryPresenter(interactor: interactor)
        return WeatherHistoryView(presenter: presenter)
    }
}
