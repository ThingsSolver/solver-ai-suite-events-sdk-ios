//
//  InternalNetworkUtility.swift
//  EventSDK
//
//  Created by Leon Tuček on 13.06.2024..
//

import Foundation

final class InternalNetworkUtility: NetworkUtility {
    static let shared: NetworkUtility = InternalNetworkUtility()
    
    private struct Constants {
        static let TimeoutIntervalForRequest: TimeInterval = 30
        
        struct HeaderKeys {
            static let XApiKey: String = "x-api-key"
            static let BearerAuthorization: String = "Authorization"
            static let TenantId: String = "tenant_id"
            static let ContentType: String = "Content-Type"
        }
        
        struct HeaderValues {
            static let ApplicationJson: String = "application/json"
        }
    }
    
    enum Endpoint: String {
        case bulk = "/bulk"
    }
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    
    var tenantID: String?
    var baseURL: URL?
    var apiKey: String?
    
    private var authorizationType: AuthorizationType?
    
    private init() {
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder.outputFormatting = .withoutEscapingSlashes
    }
    
    func configure(tenantID: String, baseURL: URL, authorizationType: AuthorizationType, apiKey: String) {
        self.tenantID = tenantID
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.authorizationType = authorizationType
    }
    
    func post(data: InternalApiObject) async throws {
        if let baseURL = self.baseURL {
            let requestHeaders: [String: String] = [
                Constants.HeaderKeys.ContentType: Constants.HeaderValues.ApplicationJson,
                Constants.HeaderKeys.TenantId: self.tenantID ?? "",
                (authorizationType == .Bearer ? Constants.HeaderKeys.BearerAuthorization : Constants.HeaderKeys.XApiKey): (authorizationType == .Bearer ? "Bearer \(apiKey ?? "")" : apiKey ?? "")
            ]
            
            let request: Request = Request(baseUrl: baseURL, endpoint: .bulk, method: .post, headers: requestHeaders, body: data)
            _ = try await send(request)
        } else {
            throw RequestError.invalidURL
        }
    }
    
    private func send(_ request: Request) async throws -> Data {
        var urlRequest = URLRequest(url: request.baseUrl.appending(path: request.endpoint.rawValue))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if let body = request.body {
            urlRequest.httpBody = try self.jsonEncoder.encode(body)
        }
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.TimeoutIntervalForRequest
        
        let urlSession: URLSession = URLSession(configuration: configuration)
        
        let (data, response) = try await urlSession.data(for: urlRequest, delegate: nil)
        guard let response = response as? HTTPURLResponse else {
            throw RequestError.noResponse
        }
        
        switch response.statusCode {
        case 200...299:
            return data
        case 400:
            throw RequestError.badRequest
        case 401:
            throw RequestError.unauthorized
        default:
            throw RequestError.unexpectedStatusCode
        }
    }
    
}

extension InternalNetworkUtility {
    enum RequestMethod: String {
        case delete = "DELETE"
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
    }

    enum RequestError: Error {
        case invalidURL
        case noResponse
        case unexpectedStatusCode
        case badRequest
        case unauthorized
        
        public var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Unable to construct URL from Endpoint"
            case .noResponse:
                return "Got empty response from server"
            case .unexpectedStatusCode:
                return "Got unexpected reponse code from server"
            case .badRequest:
                return "Server returned status 400, for example a request withot all required form data was made"
            case .unauthorized:
                return "Got unauthorized response from server"
            }
        }
    }

    struct Request {
        let baseUrl: URL
        let endpoint: Endpoint
        let method: RequestMethod
        let headers: [String: String]
        let body: Encodable?
    }
}

protocol NetworkUtility {
    func configure(tenantID: String, baseURL: URL, authorizationType: AuthorizationType, apiKey: String)
    func post(data: InternalApiObject) async throws
}

