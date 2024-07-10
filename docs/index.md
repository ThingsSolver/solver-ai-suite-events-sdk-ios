# Documentation

## Overview
The `EventSDKFramework` is designed to manage and send events with flexible configuration options. This SDK allows for customization of event collection and transmission settings, ensuring optimal performance and frequency of event transmissions.

## Adding EventSDK to Your Xcode Project
1. Select the target to which you want to add the XCFramework
2. Click on the `General` tab at the top of the settings pane
3. Scroll down to the `Frameworks, Libraries, and Embedded Content` section
4. Click on the `+` button
5. Select the EventSDK XCFramework and click `Add`

### Import the Framework
In your Swift or Objective-C files, import the framework using the appropriate import statement:
```swift
import EventSDK
```
or in ObjC:
```objective-c
@import EventSDK;
```

## Authorization

### Bearer
A structure representing Bearer token authorization. This struct holds the credentials and endpoint for Bearer token-based authorization.  

**Properties **  
- `username` - The username used for authentication  
- `password` - The password used for authentication  
- `url` - The URL endpoint for the authorization request  

**Initializer**
```swift
Bearer(username: String, password: String, url: URL)
```

### API Key
A structure representing API key authorization. This struct holds the API key used for authorization.

**Properties **  
- `key` - The API key used for authentication  

**Initializer**
```swift
ApiKey(key: String)
```

## EventSDKFramework Constants
The Constants struct within the EventSDKFramework contains default values for various configuration parameters.

```swift
public struct Constants {
    /// The default number of maximum events collected before sending, default is 30.
    public static let DefaultNumberOfMaxEventsCollectedBeforeSending: Int = 30

    /// The default event send interval, default is 3 minutes.
    public static let DefaultEventSendInterval: TimeInterval = 3 * 60 // 3 minutes

    /// The default interval after which a new sessionID is generated, default is 30 minutes.
    public static let DefaultSessionIDRegenerateTimeInverval: TimeInterval = 30 * 60 // 30 minutes
}
```

#### Properties
- `DefaultNumberOfMaxEventsCollectedBeforeSending` - The maximum number of events collected before they are sent to the server.  
- `DefaultEventSendInterval` - The time interval (in seconds) at which events are sent to the server.  
- `DefaultSessionIDRegenerateTimeInverval` - The time interval (in seconds) after which a new sessionID is generated.  

## Initialization

To initialize the SDK, use the initialize method with the required parameters.

```swift
public static func initialize(
    tenantID: String, 
    baseUrl: URL, 
    authorization: Authorization, 
    apiKey: String, 
    numberOfMaxEventsCollectedBeforeSending: Int = Constants.DefaultNumberOfMaxEventsCollectedBeforeSending, 
    eventSendInterval: TimeInterval = Constants.DefaultEventSendInterval
)
```

#### Parameters
- `tenantID` - The tenant identifier.  
- `baseUrl` - The base URL for the API.  
- `authorization` - `Bearer` or  `ApiKey` struct used for authorization. See [`Authorization`](#authorization) structs for more details
- `apiKey` - The API key used for authentication.  
- `numberOfMaxEventsCollectedBeforeSending` - The maximum number of events to collect before sending.  
- `eventSendInterval` - The interval at which events are sent.


#### Example
```swift
EventSDKFramework.initialize(
    tenantID: "your-tenant-id",
    baseUrl: URL(string: "https://api.example.com")!,
    authorization: Bearer(username: "YOUR-USERNAME", password: "PASSWORD", url: URL(string: "https://auth.example.com")!),
    apiKey: "your-api-key"
)
```

If you want to change `numberOfMaxEventsCollectedBeforeSending` or `eventSendInterval` pass your custom value to `initialize` method:
```swift
EventSDKFramework.initialize(
    tenantID: "your-tenant-id",
    baseUrl: URL(string: "https://api.example.com")!,
    authorization: ApiKey(key: "API-KEY"),
    apiKey: "your-api-key",
    numberOfMaxEventsCollectedBeforeSending: 5,
    eventSendInterval: 60
)
```

## Collecting Events
### Object struct
The `Object` struct represents an object used for sending events to the backend with various properties related to device and user information, login status, page type, event details, and other relevant data. It conforms to the `Codable` protocol, making it easy to encode and decode.

```swift
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
    /// The language preference of the user.
    let language: String
    /// An optional representing the latitude coordinate. Default value is `nil`
    let lat: Double?
    /// An optional representing the longitude coordinate. Default value is `nil`
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
    ///   - language: The language preference of the user.
    ///   - lat: An optional representing the latitude coordinate. Default value is `nil`
    ///   - lon: An optional representing the longitude coordinate. Default value is `nil`
    public init(deviceToken: String, customerId: String, loginStatus: Bool, pageType: String, pageName: String, event: Event, eventValue: String, eventArguments: [[String : String]], language: String, lat: Double? = nil, lon: Double? = nil) {
        self.deviceToken = deviceToken
        self.customerId = customerId
        self.loginStatus = loginStatus
        self.pageType = pageType
        self.event = event
        self.eventValue = eventValue
        self.eventArguments = eventArguments
        self.language = language
        self.lat = lat
        self.lon = lon
    }
}
```
#### Properties
- `deviceToken` - The device token associated with the device.  
- `customerId` - The customer ID associated with the user.  
- `loginStatus` - The login status of the user.  
- `pageType` - The type of the page being accessed.  
- `pageName` - The name  of the page being accessed.
- `event` - An Event enum containing details about a specific event.  
- `eventValue` - The value associated with the event.  
- `eventArguments` - A collection of key-value pairs providing additional arguments for the event.  
- `language` - The language preference of the user.  
- `lat` - An optional Double representing the latitude coordinate. Default value is nil.  
- `lon` - An optional Double representing the longitude coordinate. Default value is nil. 

### Event
The `Event` enum represents different types of events that can be tracked using the SDK. Each event has a corresponding string value, making it easy to encode and decode for various uses, such as logging or sending to a server.  
  
Default provided Event enums are:  
- `appOpen` - Represents the event when an app is opened.  
- `appClosed` - Represents the event when an app is closed.  
- `appCrashed` - Represents the event when an app crashes.  
- `appUpdate` - Represents the event when an app is updated.  
- `fingerScan` - Represents the event of a finger scan.  
- `faceScan` - Represents the event of a face scan.  
- `buttonTrigger` - Represents the event when a button is triggered.  
- `login` - Represents the event of a user login.  
- `logout` - Represents the event of a user logout.  
- `engagementServed` - Represents the event when an engagement is served.  
- `transaction` - Represents the event of a transaction.  
- `productView` - Represents the event when a product is viewed.  
- `pageView` - Represents the event when a page is viewed.  
- `materialDownload` - Represents the event when material is downloaded.  
- `searchQuery` - Represents the event of a search query.  

#### Using Custom Value Events
You can also create an Event instance using a custom string value.
```swift
Event(rawValue: "customEventValue")
```

### Sending Object struct to SDK
Use the `collect` method to collect an object for processing or storage.  

```swift
public static func collect(_ object: Object)
```
#### Example
```swift
let event = EventSDK.Object(deviceToken: "device-token", customerId: "cusomer-id", loginStatus: true, pageType: "page-type", event: EventSDK.Event.appOpen, eventValue: "event-value", eventArguments: [["arg-key-1": "arg-val-1"], ["arg-key-2": "arg-val-2"]], language: "en", lat: 48.858093, lon: 2.294694)
EventSDKFramework.collect(event)
```

## Session Management

### Opt-Out Control
Control whether the user has opted out of data collection. Setting this value to `true` disables all event collecting.

#### Example
To disable user data collection:
```swift
EventSDKFramework.optOut = true
```

### User Session ID
New user session ID is generated every 30 minutes.

#### Example
To retrieve the current session ID:
```swift
EventSDKFramework.sessionID
```

If you want to manually generate new session ID before 30 minutes have expired:
```swift
EventSDKFramework.generateSessionID()
```

