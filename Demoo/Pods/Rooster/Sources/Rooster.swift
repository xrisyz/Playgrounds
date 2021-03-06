//
//  Rooster.swift
//  C.K
//
//  Created by Christopher Karani on 03/06/2018.
//  Copyright © 2018 C.K. All rights reserved.
//

import Foundation

enum WebserviceError: Error {
    case notAuthenticated
    case other
    case general(String)
}

func logError<A>(_ result: Result<A>) {
    guard case .failure(let e) = result else { return }
    assert(false, "\(e)")
}

public final class Rooster<R: Resource> {
    func load(_ resource: R, completion: @escaping (Result<R.T>) -> ()) {
        let request = URLRequest(resource: resource)
        URLSession.shared.dataTask(with: request) { data, response, error in
            let result: Result<R.T>
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                result = Result(WebserviceError.notAuthenticated)
            } else {
                let parsed = data.flatMap (resource.parse)
                result = Result(value: parsed, or: WebserviceError.other)
            }
            DispatchQueue.main.async { completion(result) }
            }.resume()
    }
}
