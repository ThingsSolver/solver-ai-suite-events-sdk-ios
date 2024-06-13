//
//  InternalObject.swift
//  EventSDK
//
//  Created by Leon Tuček on 13.06.2024..
//

import Foundation

struct InternalObject: Codable, Equatable {
    let publicObject: Object
    let timestamp: Date
    let sessionID: String
    let applicationName: String
    let applicationVersion: String
    let id: String = UUID().uuidString // Used for internal event differentiation
    
    init(publicObject: Object, timestamp: Date, sessionID: String, applicationName: String, applicationVersion: String) {
        self.publicObject = publicObject
        self.timestamp = timestamp
        self.sessionID = sessionID
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceToken
        case customerId
        case loginStatus
        case pageType
        case event
        case eventValue
        case eventArguments
        case language
        
        case timestamp
        case sessionID
        case applicationName
        case applicationVersion
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(publicObject.deviceToken, forKey: .deviceToken)
        try container.encode(publicObject.customerId, forKey: .customerId)
        try container.encode(publicObject.loginStatus, forKey: .loginStatus)
        try container.encode(publicObject.pageType, forKey: .customerId)
        try container.encode(publicObject.event, forKey: .event)
        try container.encode(publicObject.eventValue, forKey: .eventValue)
        try container.encode(publicObject.eventArguments, forKey: .eventArguments)
        try container.encode(publicObject.language, forKey: .language)
        
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sessionID, forKey: .sessionID)
        try container.encode(applicationName, forKey: .applicationName)
        try container.encode(applicationVersion, forKey: .applicationVersion)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let deviceToken = try container.decode(String.self, forKey: .deviceToken)
        let customerId = try container.decode(String.self, forKey: .customerId)
        let loginStatus = try container.decode(Bool.self, forKey: .loginStatus)
        let pageType = try container.decode(String.self, forKey: .pageType)
        let event = try container.decode(Event.self, forKey: .event)
        let eventValue = try container.decode(String.self, forKey: .eventValue)
        let eventArguments = try container.decode([[String: String]].self, forKey: .eventArguments)
        let language = try container.decode(String.self, forKey: .language)
        
        self.publicObject = Object(deviceToken: deviceToken, customerId: customerId, loginStatus: loginStatus, pageType: pageType, event: event, eventValue: eventValue, eventArguments: eventArguments, language: language)
        
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.sessionID = try container.decode(String.self, forKey: .sessionID)
        self.applicationName = try container.decode(String.self, forKey: .applicationName)
        self.applicationVersion = try container.decode(String.self, forKey: .applicationVersion)
    }
    
    static func == (lhs: InternalObject, rhs: InternalObject) -> Bool {
        return lhs.id == rhs.id
    }
}
