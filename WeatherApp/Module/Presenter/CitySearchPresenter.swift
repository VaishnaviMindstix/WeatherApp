//
//  CitySearchPresenter.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation
import Combine
import Foundation
import WeatherAppUI

protocol CitySearchPresenterProtocol: ObservableObject {
    var query: String { get set }
    var suggestions: [City] { get }
    func cityTapped(_ city: City)
}

class CitySearchPresenter: CitySearchPresenterProtocol, ObservableObject {
    @Published var query: String = ""
    @Published var suggestions: [City] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    var onCitySelected: ((City) -> Void)?
    
    private let interactor: CitySearchInteractorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: CitySearchInteractorProtocol) {
        self.interactor = interactor
        setupQuerySubscriber()
    }
    
    private func setupQuerySubscriber() {
        $query
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.fetchSuggestions(for: query)
            }
            .store(in: &cancellables)
    }
    
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            self.suggestions = []
            self.errorMessage = nil
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil

        interactor.fetchCitySuggestions(for: query) { [weak self] cities, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.suggestions = []
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.suggestions = cities
                }
            }
        }
    }
    
    func cityTapped(_ city: City) {
        query = city.name
        suggestions = []
        onCitySelected?(city)
    }
}

