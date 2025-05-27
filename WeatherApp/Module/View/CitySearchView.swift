//
//  CitySearchView.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 16/05/25.
//

import SwiftUI
import WeatherAppUI

struct CitySearchView: View {
    @ObservedObject var presenter: CitySearchPresenter
    @State private var showHistory: Bool = false // Step 1: Navigation state
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color("BlueColor"), Color("LightBlueColor"), Color("WhiteBlueColor")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // TextField with white background
                TextField("Search for a city", text: $presenter.query)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                
                if presenter.isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                if let error = presenter.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // List with white background
                if !presenter.suggestions.isEmpty {
                    List(presenter.suggestions) { city in
                        VStack(alignment: .leading) {
                            Text(city.name)
                                .font(.headline)
                            Text("\(city.state ?? ""), \(city.country ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle()) // Better tap area
                        .onTapGesture {
                            presenter.cityTapped(city)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(radius: 3)
                }
                
                Spacer()
                
                // Step 3: Add History Button + NavigationLink
                NavigationLink(
                    destination: WeatherHistoryRouter.createModule(),
                    isActive: $showHistory
                ) {
                    EmptyView()
                }
                
                Button {
                    showHistory = true
                } label: {
                    WeatherButton(
                        title: "Show\nWeather History",
                        backgroundColor: Color("BlueColor"),
                        textColor: Color.white, height: 80
                    )
                }
            }
            .padding(.top)
        }
    }
}



struct CitySearchView_Previews: PreviewProvider {
    static var previews: some View {
        let interactor = CitySearchInteractor()
        let presenter = CitySearchPresenter(interactor: interactor)
        CitySearchView(presenter: presenter)
    }
}

