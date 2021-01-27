//
//  FoursquareClient.swift
//  CoffeeShopsList
//
//  Created by Venkat Madira on 25/01/2021.
//


import UIKit

enum Foursquare: Endpoint {
    case venues(CoffeeVenueEndpoint)
    
    enum CoffeeVenueEndpoint: Endpoint {
        case search(clientID: String, clientSecret: String, coordinate: Coordinate, category: Category, query: String?, searchRadius: Int?, limit: Int?)
        
        enum Category {
            case coffee([CoffeeCategory]?)
            
            enum CoffeeCategory: String {
                case Global = "4bf58dd8d48988d1e0931735"
            }
            
            var description: String {
                switch self {
                case .coffee(let categories):
                    if let categories = categories {
                        let commaSeperatedString = categories.reduce("") { categoryString, category in
                            "\(categoryString),\(category.rawValue)"
                        }
                        print(commaSeperatedString)
                        // TODO format catogories.
                        return ""//commaSeperatedString.substring(from: commaSeperatedString.characters.index(commaSeperatedString.startIndex, offsetBy: 1))
                        
                        
                    } else {
                        return "4bf58dd8d48988d1e0931735"
                    }
                }
            }
        }
        
        // MARK: - Venue Endpoint - Endpoint
        
        var coffeeBaseURL: String {
            return "https://api.foursquare.com"
        }
        
        var coffeePath: String {
            switch self {
            case .search: return "/v2/venues/search"
            }
        }
        
        fileprivate struct ParameterKeys {
            static let clientID = "client_id"
            static let clientSecret = "client_secret"
            static let version = "v"
            static let category = "categoryId"
            static let location = "ll"
            static let query = "query"
            static let limit = "limit"
            static let searchRadius = "radius"
        }
        
        fileprivate struct DefaultValues {
            static let version = "20180101"
            static let limit = "50"
            static let searchRadius = "2000"
        }
        
        var parameters: [String : AnyObject] {
            switch self {
            case .search(let clientID, let clientSecret, let coordinate, let category, let query, let searchRadius, let limit):
                
                var parameters: [String: AnyObject] = [
                    ParameterKeys.clientID: clientID as AnyObject,
                    ParameterKeys.clientSecret: clientSecret as AnyObject,
                    ParameterKeys.version: DefaultValues.version as AnyObject,
                    ParameterKeys.location: coordinate.description as AnyObject,
                    ParameterKeys.category: category.description as AnyObject
                ]
                
                if let searchRadius = searchRadius {
                    parameters[ParameterKeys.searchRadius] = searchRadius as AnyObject?
                } else {
                    parameters[ParameterKeys.searchRadius] = DefaultValues.searchRadius as AnyObject?
                }
                
                if let limit = limit {
                    parameters[ParameterKeys.limit] = limit as AnyObject?
                } else {
                    parameters[ParameterKeys.limit] = DefaultValues.limit as AnyObject?
                }
                
                if let query = query {
                    parameters[ParameterKeys.query] = query as AnyObject?
                }
                
                return parameters
            }
        }
    }
    
    // MARK: - Foursquare - Endpoint
    
    var coffeeBaseURL: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.coffeeBaseURL
        }
    }
    
    var coffeePath: String {
        switch self {
        case .venues(let endpoint):
            return endpoint.coffeePath
        }
    }
    
    var parameters: [String: AnyObject] {
        switch self {
        case .venues(let endpoint):
            return endpoint.parameters
        }
    }
}

final class FoursquareClient: APIClient {
    let configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    let clientID: String
    let clientSecret: String
    
    init(configuration: URLSessionConfiguration, clientID: String, clientSecret: String) {
        self.configuration = configuration
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    convenience init(clientID: String, clientSecret: String) {
        self.init(configuration: .default, clientID: clientID, clientSecret: clientSecret)
    }
    
    func fetchCoffeeResturantsFor(_ location: Coordinate, category: Foursquare.CoffeeVenueEndpoint.Category, query: String? = nil, searchRadius: Int? = nil, limit: Int? = nil, completion: @escaping (APIResult<[Venue]>) -> Void) {
        
        let searchEndpoint = Foursquare.CoffeeVenueEndpoint.search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
        
        let endpoint = Foursquare.venues(searchEndpoint)
        
        fetch(endpoint, parse: { json -> [Venue]? in
            guard let venues = json["response"]?["venues"] as? [[String: AnyObject]] else {
                return nil
            }
            print(venues)
            return venues.compactMap{ venueDict in
                return Venue(JSON: venueDict)
            }
        }, completion: completion)
    }
    
}

