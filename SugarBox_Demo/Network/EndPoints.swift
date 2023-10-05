//
//  EndPoints.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 26/09/23.
//

import Foundation

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}

enum FeedEndpoint: APIEndpoint {
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getFeed(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "perPage", value: "\(perPage)")
            ]
        }
    }
    
    case getFeed(page: Int, perPage: Int)
    
    var baseURL: URL {
        return URL(string: "https://apigw.sboxdc.com/ecm/v2/super/feeds/zee5-home/details")!
    }
    
    var path: String {
        switch self {
        case .getFeed:
            return ""
        }
    }
    
    var httpMethod: String {
        return "GET"
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        return nil
    }
}

