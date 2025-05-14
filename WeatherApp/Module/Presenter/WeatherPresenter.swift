//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

protocol WeatherPresenterProtocol {
    func didFetchWeather(_ data: WeatherData)
    func didFailFetchingWeather(_ error: Error)
}

class WeatherPresenter: ObservableObject, WeatherPresenterProtocol {
    @Published var dateText                  = "--"
    @Published var isNight                   = false
    @Published var dayText                   = "--"
    @Published var tempText                  = "--"
    @Published var conditionText             = "--"
    @Published var symbolNameText            = "--"
    @Published var forecastDay: [Forecast]   = []
    @Published var forecastNight: [Forecast] = []
    
    var interactor: WeatherInteractorProtocol?
    
    func didFetchWeather(_ data: WeatherData) {
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
        dateText       = "--"
        isNight        = false
        dayText        = "--"
        tempText       = "--"
        conditionText  = "Error"
        symbolNameText = "--"
        forecastDay    = []
        forecastNight  = []
    }
}
