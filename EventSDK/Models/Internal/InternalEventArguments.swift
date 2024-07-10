//
//  InternalEventArguments.swift
//  EventSDK
//
//  Created by Leon Tuček on 26.06.2024..
//

import Foundation

struct InternalEventArguments: Codable {
    let argumentName: String
    let argumentValue: String
    
    enum CodingKeys: String, CodingKey {
        case argumentName = "arg_name"
        case argumentValue = "arg_value"
    }
}
