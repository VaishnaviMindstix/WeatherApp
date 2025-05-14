//
//  WeatherRouter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

final class WeatherRouter {
    static func createModule() -> ContentView {
        let presenter = WeatherPresenter()
        let interactor = WeatherInteractor()
        presenter.interactor = interactor
        interactor.presenter = presenter
        return ContentView(presenter: presenter)
    }
}

