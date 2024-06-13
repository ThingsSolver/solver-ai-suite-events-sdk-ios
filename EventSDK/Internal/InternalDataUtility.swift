//
//  InternalDataUtility.swift
//  EventSDK
//
//  Created by Leon Tuček on 13.06.2024..
//

import Foundation

final class InternalDataUtility: DataUtility {
    static let shared: DataUtility = InternalDataUtility()
    private var isOptOut: Bool = false
    
    // MARK: Session variables
    var sessionId: String {
        if Date().timeIntervalSince(self.sessionSetDate) > self.sessionIDRegenerateTimeInverval {
            self.generateSessionID()
        }
        
        return self.internalSessionId
    }
    
    private var internalSessionId: String = UUID().uuidString
    private var sessionSetDate: Date = Date()
    private var sessionIDRegenerateTimeInverval: TimeInterval = EventSDK.Constants.DefaultSessionIDRegenerateTimeInverval
    
    // MARK: Data collection variables
    private var dataSendingTimer: Timer?
    private var numberOfMaxEventsCollectedBeforeSending: Int = EventSDK.Constants.DefaultNumberOfMaxEventsCollectedBeforeSending
    
    private var collectedEvents: [InternalObject] = [] {
        didSet {
            if self.collectedEvents.count > self.numberOfMaxEventsCollectedBeforeSending {
                self.sendEventsToServer()
            }
        }
    }
    
    private init() {
        // Load old events that were never sent to backend
        self.collectedEvents = InternalRepository.events
    }
    
    func configure(tenantID: String, baseUrl: URL, apiKey: String, numberOfMaxEventsCollectedBeforeSending: Int, eventSendInterval: TimeInterval, sessionIDRegenerateTimeInverval: TimeInterval) {
        self.numberOfMaxEventsCollectedBeforeSending = numberOfMaxEventsCollectedBeforeSending
        self.sessionIDRegenerateTimeInverval = sessionIDRegenerateTimeInverval
        
        InternalNetworkUtility.shared.configure(tenantID: tenantID, baseURL: baseUrl, apiKey: apiKey)
        
        self.dataSendingTimer?.invalidate()
        self.dataSendingTimer = Timer(timeInterval: eventSendInterval, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self, strongSelf.collectedEvents.isEmpty == false else { return }
            
            strongSelf.sendEventsToServer()
        })
    }
    
    func collect(_ object: Object) {
        guard self.isOptOut == false else {
            print("Not collecting any data since user opted out!")
            return
        }
        
        let applicationName: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        let applicationVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        let internalObject: InternalObject = InternalObject(publicObject: object, timestamp: Date(), sessionID: self.sessionId, applicationName: applicationName, applicationVersion: applicationVersion)
        
        self.collectedEvents.append(internalObject)
        InternalRepository.events = self.collectedEvents
    }
    
    func generateSessionID() {
        self.internalSessionId = UUID().uuidString
        self.sessionSetDate = Date()
    }
    
    func setOptOut(_ optOut: Bool) {
        self.isOptOut = optOut
    }
    
    private func sendEventsToServer() {
        Task(priority: .medium, operation: { @MainActor [weak self] in
            guard let strongSelf = self else { return }
            do {
                // "Snapshot" events that are going to be sent
                let eventsSnapshot: [InternalObject] = strongSelf.collectedEvents
                try await InternalNetworkUtility.shared.post(data: eventsSnapshot)
                
                // It's possible that new events came while snapshotted events were being sent
                var eventsToSend: [InternalObject] = []
                for event in strongSelf.collectedEvents {
                    if eventsSnapshot.contains(event) == false {
                        eventsToSend.append(event)
                    }
                }
                
                strongSelf.collectedEvents = eventsToSend
                InternalRepository.events = eventsToSend
            } catch {
                print("Error while sending events to backend. Error: \(error.localizedDescription)")
            }
        })
    }
}


protocol DataUtility {
    var sessionId: String { get }
    
    func configure(tenantID: String, baseUrl: URL, apiKey: String, numberOfMaxEventsCollectedBeforeSending: Int, eventSendInterval: TimeInterval, sessionIDRegenerateTimeInverval: TimeInterval)
    func collect(_ object: Object)
    func generateSessionID()
    func setOptOut(_ optOut: Bool)
}