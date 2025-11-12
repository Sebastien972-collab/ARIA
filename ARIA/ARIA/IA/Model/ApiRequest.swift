//
//  ApiRequest.swift
//  ARIA
//
//  Created by Sébastien DAGUIN on 12/11/2025.
//

import Foundation

struct APIRequest {
    let endpoint: String
    let httpMethod: HTTPMethod
    var body: Data? = nil
}


enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}
