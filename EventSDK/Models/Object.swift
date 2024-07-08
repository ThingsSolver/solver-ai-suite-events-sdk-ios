//
//  Object.swift
//  EventSDK
//
//  Created by Leon Tuček on 12.06.2024..
//

import Foundation

/// A struct representing an object used for sending events to the backend with various properties related to device and user information, login status, page type, event details, and other relevant data.
public struct Object: Codable {
    /// The device token associated with the device.
    let deviceToken: String
    /// The customer ID associated with the user.
    let customerId: String
    /// The login status of the user.
    let loginStatus: Bool
    /// The type of the page being accessed.
    let pageType: String
    /// The name of the page being accessed.
    let pageName: String
    /// An event enum containing details about a specific event.
    let event: Event
    /// The value associated with the event.
    let eventValue: String
    /// A collection of key-value pairs providing additional arguments for the event.
    let eventArguments: [[String: String]]
    /// The language preference of the user.r
    let language: String
    /// An optional  representing the latitude coordinate. Default value is `nil`
    let lat: Double?
    /// An optional  representing the longitude coordinate. Default value is `nil`
    let lon: Double?
    
    /// A struct representing an object used for sending events to the backend with various properties related to device and user information, login status, page type, event details, and other relevant data.
    /// - Parameters:
    ///   - deviceToken: The device token associated with the device.
    ///   - customerId: The customer ID associated with the user.
    ///   - loginStatus: The login status of the user.
    ///   - pageType: The type of the page being accessed.
    ///   - pageName: The name  of the page being accessed.
    ///   - event: An event enum containing details about a specific event.
    ///   - eventValue: The value associated with the event.
    ///   - eventArguments: A collection of key-value pairs providing additional arguments for the event.
    ///   - language: The language preference of the user.r
    ///   - lat: An optional  representing the latitude coordinate. Default value is `nil`
    ///   - lon: An optional  representing the longitude coordinate. Default value is `nil`
    public init(deviceToken: String, customerId: String, loginStatus: Bool, pageType: String, pageName: String, event: Event, eventValue: String, eventArguments: [[String : String]], language: String, lat: Double? = nil, lon: Double? = nil) {
        self.deviceToken = deviceToken
        self.customerId = customerId
        self.loginStatus = loginStatus
        self.pageType = pageType
        self.pageName = pageName
        self.event = event
        self.eventValue = eventValue
        self.eventArguments = eventArguments
        self.language = language
        self.lat = lat
        self.lon = lon
    }
}

