//
//  EventSDK.swift
//  EventSDK
//
//  Created by Leon Tuček on 12.06.2024..
//

import Foundation

public enum AuthorizationType {
    case Bearer
    case XApiKey
}

public final class EventSDKFramework {
    /// Default constant values
    public struct Constants {
        /// The default number of maximum events collected before sending, default is 30.
        /// This constant defines the default limit on the number of events that can be collected before they are sent to the server. Adjusting this value can affect the performance and frequency of event transmissions. To change this value call the `initialize` method with custom `numberOfMaxEventsCollectedBeforeSending`.
        public static let DefaultNumberOfMaxEventsCollectedBeforeSending: Int = 30
        /// The default event send interval, default is 3 minutes.
        /// This constant defines the default time interval (in seconds) at which events are sent to the server. Adjusting this value can affect the performance and frequency of event transmissions. A lower interval results in more frequent transmissions, while a higher interval results in less frequent transmissions.  To change this value call the `initialize` method with custom `eventSendInterval`.
        public static let DefaultEventSendInterval: TimeInterval = 3 * 60 // 3 minutes
        /// The default  interval after which new sessionID is generated
        /// This constant defines the default time interval (in seconds) after which a new sessionID is generated. To change this value call the `initialize` method with custom `sessionRegenerateTimeInverval`.
        public static let DefaultSessionIDRegenerateTimeInverval: TimeInterval = 30 * 60 // 30 minutes
    }
    
    private init() {}
    
    /// Controlls if user opted out for data collection
    var optOut: Bool = false {
        didSet {
            InternalDataUtility.shared.setOptOut(optOut)
        }
    }
    
    /// User session ID, new session ID is automatically generated every 30 minutes
    public static var sessionID: String {
        return InternalDataUtility.shared.sessionId
    }
    
    /// Initializes the SDK with the given parameters.
    /// - Parameters:
    ///   - tenantID: The tenant identifier.
    ///   - baseUrl: The base URL for the API
    ///   - apiKey: The API key used for authentication
    ///   - authorizationType: Type of authorization used, see `AuthorizationType` enum for options
    ///   - numberOfMaxEventsCollectedBeforeSending: The maximum number of events to collect before sending. Default is `Constants.DefaultNumberOfMaxEventsCollectedBeforeSending`.
    ///   - eventSendInterval: The interval at which events are sent. Default is `Constants.DefaultEventSendInterval`.
    public static func initialize(tenantID: String, baseUrl: URL, authorizationType: AuthorizationType, apiKey: String, numberOfMaxEventsCollectedBeforeSending: Int = Constants.DefaultNumberOfMaxEventsCollectedBeforeSending, eventSendInterval: TimeInterval = Constants.DefaultEventSendInterval) {
        
        InternalDataUtility.shared.configure(
            tenantID: tenantID,
            baseUrl: baseUrl,
            authorizationType: authorizationType,
            apiKey: apiKey,
            numberOfMaxEventsCollectedBeforeSending: numberOfMaxEventsCollectedBeforeSending,
            eventSendInterval: eventSendInterval,
            sessionIDRegenerateTimeInverval: Constants.DefaultSessionIDRegenerateTimeInverval
        )
    }
    
    /// Collects the given object for processing or storage.
    /// - Parameter object: The object to be collected. This object will be processed or stored.
    public static func collect(_ object: Object) {
        InternalDataUtility.shared.collect(object)
    }
    
    /// Regenerates tye user session ID
    public static func generateSessionID() {
        InternalDataUtility.shared.generateSessionID()
    }
}
