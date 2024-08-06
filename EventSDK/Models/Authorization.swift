//
//  Authorization.swift
//  EventSDK
//
//  Created by Leon Tuček on 04.07.2024..
//

import Foundation

public protocol Authorization {}


/// A structure representing Bearer token authorization. This struct holds the credentials and endpoint for Bearer token-based authorization.
public struct Bearer: Authorization {
    let username: String
    let password: String
    let url: URL
    var expiryDate: Date = Date()
    
    
    /// A structure representing Bearer token authorization. This struct holds the credentials and endpoint for Bearer token-based authorization.
    /// - Parameters:
    ///   - username: The username used for authentication.
    ///   - password: The password used for authentication.
    ///   - url: The URL endpoint for the authorization request.
    public init(username: String, password: String, url: URL) {
        self.username = username
        self.password = password
        self.url = url
    }
}

/// A structure representing API key authorization. This struct holds the API key used for authorization.
public struct ApiKey: Authorization {
    let key: String
    
    
    /// A structure representing API key authorization. This struct holds the API key used for authorization.
    /// - Parameter key: The API key used for authentication.
    public init(key: String) {
        self.key = key
    }
}
