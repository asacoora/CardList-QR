//
//  ImageLoader.swift
//  LINE Fintech
//

import UIKit

enum ImageLoaderError: Error {
    case unknown
    case invalidURL
}

/// 이미지 URL을 받아 이미지를 불러옵니다.
struct ImageLoader {
    let url: String

    func load(completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) {
        if let url = URL(string: self.url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    completion(.failure(.unknown))
                    return
                }

                DispatchQueue.main.async {
                    completion(.success(image))
                }
            }.resume()
        } else {
            completion(.failure(.invalidURL))
        }
    }
}
