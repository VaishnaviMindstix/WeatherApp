//
//  ContentView.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 13/05/25.
//

import SwiftUI
import WeatherAppUI

struct ContentView: View {
    @State private var selectedCity: City?
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(
                    destination: navigationDestination,
                    isActive: Binding(
                        get: { selectedCity != nil },
                        set: { isActive in if !isActive { selectedCity = nil } }
                    )
                ) {
                    EmptyView()
                }
                
                CityRouter.build { city in
                    selectedCity = city
                }
            }
        }
    }
    
    @ViewBuilder
    private var navigationDestination: some View {
        if let city = selectedCity {
            WeatherRouter.createModule(city: city, apiKey: Secrets.apiKey)
                .foregroundColor(.white)
        } else {
            EmptyView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

