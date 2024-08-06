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
    let clientRequestId: String
    let batteryLevel: Float
    let eventArguments: [InternalEventArguments]
    
    init(publicObject: Object, timestamp: Date, sessionID: String, applicationName: String, applicationVersion: String, clientRequestId: String, batteryLevel: Float) {
        self.publicObject = publicObject
        self.timestamp = timestamp
        self.sessionID = sessionID
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion
        self.clientRequestId = clientRequestId
        self.batteryLevel = batteryLevel
        self.eventArguments = self.publicObject.eventArguments.flatMap({ $0 }).map({ InternalEventArguments(argumentName: $0, argumentValue: $1) })
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "device_token"
        case customerId = "customer_id"
        case loginStatus = "login_status"
        case pageType = "page_type"
        case pageName = "page_name"
        case event
        case eventValue = "event_value"
        case eventArguments = "event_arguments"
        case language
        case lat
        case lon
        
        case timestamp
        case sessionId = "session_id"
        case applicationName = "application_name"
        case applicationVersion = "application_version"
        case clientRequestId = "client_request_id"
        case batteryLevel = "battery_level"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(publicObject.deviceToken, forKey: .deviceToken)
        try container.encode(publicObject.customerId, forKey: .customerId)
        try container.encode(publicObject.loginStatus, forKey: .loginStatus)
        try container.encode(publicObject.pageName, forKey: .pageName)
        try container.encode(publicObject.pageType, forKey: .pageType)
        try container.encode(publicObject.event, forKey: .event)
        try container.encode(publicObject.eventValue, forKey: .eventValue)
        try container.encode(publicObject.language, forKey: .language)
        try container.encode(publicObject.lat, forKey: .lat)
        try container.encode(publicObject.lon, forKey: .lon)
        
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sessionID, forKey: .sessionId)
        try container.encode(applicationName, forKey: .applicationName)
        try container.encode(applicationVersion, forKey: .applicationVersion)
        try container.encode(clientRequestId, forKey: .clientRequestId)
        try container.encode(batteryLevel, forKey: .batteryLevel)
        try container.encode(eventArguments, forKey: .eventArguments)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.sessionID = try container.decode(String.self, forKey: .sessionId)
        self.applicationName = try container.decode(String.self, forKey: .applicationName)
        self.applicationVersion = try container.decode(String.self, forKey: .applicationVersion)
        self.clientRequestId = try container.decode(String.self, forKey: .clientRequestId)
        self.batteryLevel = try container.decode(Float.self, forKey: .batteryLevel)
        self.eventArguments = try container.decode([InternalEventArguments].self, forKey: .eventArguments)
        
        let deviceToken = try container.decode(String.self, forKey: .deviceToken)
        let customerId = try container.decode(String.self, forKey: .customerId)
        let loginStatus = try container.decode(Bool.self, forKey: .loginStatus)
        let pageType = try container.decode(String.self, forKey: .pageType)
        let pageName = try container.decode(String.self, forKey: .pageName)
        let event = try container.decode(Event.self, forKey: .event)
        let eventValue = try container.decode(String.self, forKey: .eventValue)
        let language = try container.decode(String.self, forKey: .language)
        let eventArguments = self.eventArguments.map({ [$0.argumentName: $0.argumentValue] })
        let lat = try container.decode(Double.self, forKey: .lat)
        let lon = try container.decode(Double.self, forKey: .lat)
        
        self.publicObject = Object(deviceToken: deviceToken, customerId: customerId, loginStatus: loginStatus, pageType: pageType, pageName: pageName, event: event, eventValue: eventValue, eventArguments: eventArguments, language: language, lat: lat, lon: lon)
    }
    
    static func == (lhs: InternalObject, rhs: InternalObject) -> Bool {
        return lhs.clientRequestId == rhs.clientRequestId
    }
}
