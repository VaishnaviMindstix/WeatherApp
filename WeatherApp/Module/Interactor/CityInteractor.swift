//
//  CityInteractor.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation
import WeatherAppUI

protocol CitySearchInteractorProtocol {
    func fetchCitySuggestions(for query: String, completion: @escaping ([City], Error?) -> Void)
}

class CitySearchInteractor: CitySearchInteractorProtocol {
    private let apiKey = Secrets.apiKey
    
    func fetchCitySuggestions(for query: String, completion: @escaping ([City], Error?) -> Void) {
        guard !query.isEmpty else {
            completion([], nil)
            return
        }
        
        let limit = 5
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=\(limit)&appid=\(apiKey)"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion([], URLError(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let data = data else {
                completion([], URLError(.badServerResponse))
                return
            }
            
            do {
                let cities = try JSONDecoder().decode([City].self, from: data)
                completion(cities, nil)
            } catch {
                completion([], error)
            }
        }.resume()
    }
}
