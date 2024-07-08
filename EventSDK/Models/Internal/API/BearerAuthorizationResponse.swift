//
//  BearerAuthorizationResponse.swift
//  EventSDK
//
//  Created by Leon Tuček on 04.07.2024..
//

import Foundation

struct BearerAuthorizationResponse: Decodable {
    let accessToken: String
    let expiresIn: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}
