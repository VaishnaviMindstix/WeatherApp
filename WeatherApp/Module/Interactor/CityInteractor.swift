//
//  CityInteractor.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import Foundation

protocol CitySearchInteractorProtocol {
    func fetchCitySuggestions(for query: String, completion: @escaping ([CityModel], Error?) -> Void)
}

class CitySearchInteractor: CitySearchInteractorProtocol {
    private let apiKey = Secrets.apiKey
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchCitySuggestions(for query: String, completion: @escaping ([CityModel], Error?) -> Void) {
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
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion([], error)
                return
            }
            
            guard let data = data else {
                completion([], URLError(.badServerResponse))
                return
            }
            
            do {
                let cities = try JSONDecoder().decode([CityModel].self, from: data)
                completion(cities, nil)
            } catch {
                completion([], error)
            }
        }.resume()
    }
}
