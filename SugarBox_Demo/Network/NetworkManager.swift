//
//  ApiHandler.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 26/09/23.
//

import Foundation

protocol NetworkManagerProtocol {
    func fetchData<T: Decodable>(from endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void)
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
}

class NetworkManager: NetworkManagerProtocol {
    func fetchData<T: Decodable>(from endpoint: APIEndpoint, completion: @escaping (Result<T, Error>) -> Void) {
        
        var urlPath: URL {
            var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: true)!
            components.path += endpoint.path
            components.queryItems = endpoint.queryItems
            return components.url!
        }

        var request = URLRequest(url: urlPath) 
        request.httpMethod = endpoint.httpMethod
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(.failure(NetworkError.requestFailed))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            let statusCode = httpResponse.statusCode

            switch statusCode {
            case 200...299:
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            default:
                completion(.failure(NetworkError.statusCode(statusCode)))
            }
        }
        task.resume()
    }
}
