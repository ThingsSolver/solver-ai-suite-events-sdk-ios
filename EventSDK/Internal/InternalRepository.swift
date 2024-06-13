//
//  Repository.swift
//  EventSDK
//
//  Created by Leon Tuček on 13.06.2024..
//

import Foundation

final class InternalRepository {
    private struct Constants {
        struct UserDefaultKeys {
            static let EventsKey: String = "com.asseco.EventSDK.user_defaults.events"
        }
    }
    
    static var events: [InternalObject] {
        get {
            if let savedData: Data = UserDefaults.standard.data(forKey: Constants.UserDefaultKeys.EventsKey), let decodedEvents: [InternalObject] = try? PropertyListDecoder().decode([InternalObject].self, from: savedData) {
                return decodedEvents
            }
            
            return []
        } set {
            if let encodedObject: Data = try? PropertyListEncoder().encode(newValue) {
                UserDefaults.standard.setValue(encodedObject, forKey: Constants.UserDefaultKeys.EventsKey)
            }
        }
    }
}
