//
//  APIClient.swift
//  CoffeeShopsList
//
//  Created by Venkat Madira on 25/01/2021.
//


import Foundation

public let APINetworkingErrorDomain = "NetworkingError"

public let MissingHTTPResponseError: Int = 10
public let UnexpectedHTTPResponseError: Int = 20

protocol JSONDecodable {
    init?(JSON: [String: AnyObject])
}

protocol Endpoint {
    var coffeeBaseURL: String { get }
    var coffeePath: String { get }
    var parameters: [String: AnyObject] { get }
}

extension Endpoint {
    var queryComponents: [URLQueryItem] {
        var components = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.append(queryItem)
        }
        
        return components
    }
    
    var request: URLRequest {
        var components = URLComponents(string: coffeeBaseURL)!
        components.path = coffeePath
        components.queryItems = queryComponents
        
        guard let url = components.url else {
            return URLRequest(url: URL(string: coffeeBaseURL)!)
        }
        print("Venkat \(url)")
        return URLRequest(url: url)
    }
}

typealias JSON = [String: AnyObject]
typealias JSONCompletion = (JSON?, HTTPURLResponse?, NSError?) -> Void
typealias JSONTask = URLSessionDataTask

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func jsonTask(withRequest request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask
    func fetch<T: JSONDecodable>(_ request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
    func jsonTask(withRequest request: URLRequest, completion: @escaping JSONCompletion) -> JSONTask {
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(" HTTP Response misssing", comment: "")]
                let error = NSError(domain: APINetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                if let error = error {
                    completion(nil, HTTPResponse, error as NSError?)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        completion(json, HTTPResponse, error as NSError?)
                        
                    } catch let error as NSError {
                        completion(nil, HTTPResponse, error)
                    }
                    
                default:
                    print(" HTTP code Response received: \(HTTPResponse.statusCode), not handled correctly..")
                }
            }
        })
        
        return task
    }
    
    func fetch<T>(_ request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
        let task = jsonTask(withRequest: request) { json, response, error in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                        
                    } else {
                        // TODO: Implement error handling
                    }
                    
                    return
                }
                
                if let resource = parse(json) {
                    completion(.success(resource))
                    
                } else {
                    let error = NSError(domain: APINetworkingErrorDomain, code: UnexpectedHTTPResponseError, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func fetch<T: JSONDecodable>(_ endpoint: Endpoint, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
        let request = endpoint.request
        let task = jsonTask(withRequest: request) { json, response, error in
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(.failure(error))
                        
                    } else {
                        // TODO: Implement error handling
                    }
                    
                    return
                }
                
                if let resource = parse(json) {
                    completion(.success(resource))
                    
                } else {
                    let error = NSError(domain: APINetworkingErrorDomain, code: UnexpectedHTTPResponseError, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}




