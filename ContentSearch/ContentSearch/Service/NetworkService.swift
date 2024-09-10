//
//  NetworkService.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 09.09.2024.
//

import Foundation

class NetworkService {
    
    func request(searchTearm: String, complition: @escaping (Data?, Error?) -> Void) {
        let parameters = self.prepareParameters(searchTearm: searchTearm)
        let url = self.url(params: parameters)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareHeader()
        request.httpMethod = "get"
        
        let task = createDataTask(from: request, completion: complition)
        task.resume()
    }
    
    private func prepareHeader() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID s0VLQXOOCtZUFFqdMV4BEbniCEmErusosdyz0dZvFds"
        return headers
        
    }
    
    private func prepareParameters(searchTearm: String?) -> [String: String] {
        var parametrs = [String: String]()
        parametrs["query"] = searchTearm
        parametrs["page"] = String(1)
        parametrs["per_page"] = String(30)
        return parametrs
    }
    
    private func url(params: [String: String]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/search/photos"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1)}
        return components.url!
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
}
