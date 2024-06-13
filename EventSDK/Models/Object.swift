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
    /// An event enum containing details about a specific event.
    let event: Event
    /// The value associated with the event.
    let eventValue: String
    /// A collection of key-value pairs providing additional arguments for the event.
    let eventArguments: [[String: String]]
    /// The language preference of the user.r
    let language: String
}

