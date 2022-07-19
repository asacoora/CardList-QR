//
//  Network.swift
//  LINE Fintech
//

import Foundation

enum NetworkError: Error {
    case unknown
    case invalidRequest
    case jsonError
    case serverError
}

struct NetworkRequest<T: Codable & NetworkResponse> {

    private let path: String

    init(path: String) {
        self.path = path
    }

    func send(completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: API.host + path) else {
            completion(.failure(.invalidRequest))
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(.serverError))
                return
            }

            if let data = data {
                do {
                    let json: T = try JSONDecoder().decode(T.self, from: data)
                    if json.statusCode == 200 {
                        DispatchQueue.main.async {
                            completion(.success(json))
                        }
                    } else {
                        completion(.failure(.serverError))
                    }
                } catch {
                    completion(.failure(.jsonError))
                }
            } else {
                completion(.failure(.unknown))
            }
        }).resume()
    }
}
