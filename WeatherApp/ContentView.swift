//
//  ContentView.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 13/05/25.
//

import SwiftUI
import WeatherAppUI

struct ContentView: View {
    @State private var isNavigating = false
    
    var body: some View {
        NavigationView{ // for ios version 16+ use NavigationStack
            VStack {
                NavigationLink(destination: WeatherRouter.createModule(), isActive: $isNavigating) {
                    EmptyView()
                }
                
                Button {
                    isNavigating = true
                } label: {
                    WeatherButton(title: "Check Weather", backgroundColor: .green, textColor: .white)
                }
            }
        }
        .foregroundColor(.white)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
