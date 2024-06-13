//
//  Event.swift
//  EventSDK
//
//  Created by Leon Tuček on 13.06.2024..
//

import Foundation

public enum Event: String, Codable {
    case appOpen = "appOpen"
    case appClosed = "appClosed"
    case appCrashed = "appCrashed"
    case appUpdate = "appUpdate"
    case fingerScan = "fingerScan"
    case faceScan = "faceScan"
    case buttonTrigger = "buttonTrigger"
    case login = "login"
    case logout = "logout"
    case engagementServed = "engagementServed"
    case transaction = "transaction"
    case productView = "productView"
    case pageView = "pageView"
    case materialDownload = "materialDownload"
    case searchQuery = "searchQuery"
}
