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
            static let ApiKey: String = "x-api-key"
            static let TenantId: String = "tenant_id"
        }
    }
    
    enum Endpoint: String {
        case collect = "/collect"
    }
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    
    var tenantID: String?
    var baseURL: URL?
    var apiKey: String?
    
    private init() {
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder.outputFormatting = .withoutEscapingSlashes
    }
    
    func configure(tenantID: String, baseURL: URL, apiKey: String) {
        self.tenantID = tenantID
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    func post(data: [InternalObject]) async throws {
        if let baseURL = self.baseURL {
            let request: Request = Request(scheme: .https, baseUrl: baseURL, endpoint: .collect, method: .post, headers: [Constants.HeaderKeys.ApiKey: self.apiKey ?? "", Constants.HeaderKeys.TenantId: self.tenantID ?? ""], body: data)
            _ = try await send(request)
        } else {
            throw RequestError.invalidURL
        }
    }
    
    private func send(_ request: Request) async throws -> Data {
        var urlComponents: URLComponents = URLComponents()
        urlComponents.scheme = request.scheme.rawValue
        urlComponents.host = request.baseUrl.absoluteString
        urlComponents.path = request.endpoint.rawValue
        
       
        guard let url = urlComponents.url else {
            throw RequestError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
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

    enum Scheme: String {
        case http = "http"
        case https = "https"
    }

    enum RequestError: Error {
        case invalidURL // Unable to construct URL from Endpoint
        case noResponse // Got empty response from server
        case unexpectedStatusCode // Got unexpected reponse code from server
        case badRequest // Server returned status 400, for example a request withot all required form data was made
        case unauthorized // Got unauthorized response from server
    }

    struct Request {
        let scheme: Scheme
        let baseUrl: URL
        let endpoint: Endpoint
        let method: RequestMethod
        let headers: [String: String]
        let body: Encodable?
    }
}

protocol NetworkUtility {
    func configure(tenantID: String, baseURL: URL, apiKey: String)
    func post(data: [InternalObject]) async throws
}

