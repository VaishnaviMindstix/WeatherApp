//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

protocol WeatherPresenterProtocol {
    func didFetchWeather(_ data: WeatherDataSharedModel, city: City)
    func didFailFetchingWeather(_ error: Error)
}

@available(iOS 14.0, *)
class WeatherPresenter: ObservableObject, WeatherPresenterProtocol {
    @Published var cityNameText              = "--"
    @Published var countryNameText           = "--"
    @Published var dateText                  = "--"
    @Published var isNight                   = false
    @Published var dayText                   = "--"
    @Published var tempText                  = "--"
    @Published var conditionText             = "Error"
    @Published var symbolNameText            = "--"
    @Published var forecastDay: [ForecastSharedModel]?
    @Published var forecastNight: [ForecastSharedModel]?
    
    var interactor: WeatherInteractorProtocol?
    
    func didFetchWeather(_ data: WeatherDataSharedModel, city: City) {
        cityNameText    = city.name
        countryNameText = city.country ?? ""
        dateText        = data.date
        isNight         = data.isNight
        dayText         = data.day
        tempText        = data.currentTemp
        conditionText   = data.condition
        symbolNameText  = data.symbolName
        forecastDay     = data.forecastDay
        forecastNight   = data.forecastNight
    }
    
    func didFailFetchingWeather(_ error: Error) {
        cityNameText    = "--"
        countryNameText = "--"
        dateText        = "--"
        isNight         = false
        dayText         = "--"
        tempText        = "--"
        conditionText   = "Error"
        symbolNameText  = "--"
        forecastDay     = []
        forecastNight   = []
    }
}
