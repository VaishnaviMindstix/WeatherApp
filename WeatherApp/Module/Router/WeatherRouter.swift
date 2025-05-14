//
//  CityRouter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

final class CityRouter {
    static func createModule() -> ContentView {
        let presenter = CityPresenter()
        let interactor = CityInteractor()
//        presenter.interactor = interactor
//        interactor.presenter = presenter
        return ContentView()
    }
}

