//
//  VTClient.swift
//  VirtualTourist
//
//  Created by Malrasheed on 03/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
class VTClient {
    static let format = "json"
    static let extras = "url_n"
    static let safe_search = 1
    static let nojsoncallback = 1
    static let per_page = 20
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/?"
        static let key = "14703090898939b81bb00ffd884031e8"
        static let secret = "01e5857ea972c0ed"
        static let fetch = "method=flickr.photos.search"
        static let queryParameters = "&format=\(VTClient.format)&extras=\(VTClient.extras)&safe_search=\(VTClient.safe_search)&nojsoncallback=\(VTClient.nojsoncallback)&per_page=\(VTClient.per_page)"
        case fetchRequest
        
        var stringValue: String {
            switch self {
            case .fetchRequest: return Endpoints.base + Endpoints.fetch + "&api_key=\(Endpoints.key)" + Endpoints.queryParameters
                
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
}
