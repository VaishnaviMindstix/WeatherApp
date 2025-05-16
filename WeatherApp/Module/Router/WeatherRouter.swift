//
//  CityRouter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation
import SwiftUI
import WeatherAppUI

final class CityRouter {
    static func build(onCitySelected: @escaping (City) -> Void) -> some View {
        let interactor = CitySearchInteractor()
        let presenter = CitySearchPresenter(interactor: interactor)
        presenter.onCitySelected = onCitySelected
        return CitySearchView(presenter: presenter)
    }
}

