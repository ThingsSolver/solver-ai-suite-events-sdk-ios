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
        case login = "/api/latest/auth/login"
    }
    
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    
    private var tenantID: String?
    private var baseURL: URL?
    
    private var authorizationHeader: (key: String, value: String)?
    private var authorization: Authorization?
    private var retryRequestOnUnauthorizedError: Bool = true
    
    private init() {
        self.jsonEncoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder.outputFormatting = .withoutEscapingSlashes
    }
    
    func configure(tenantID: String, baseURL: URL, authorization: Authorization) {
        self.tenantID = tenantID
        self.baseURL = baseURL
        self.authorization = authorization
        
        if let apiKeyAuthorization: ApiKey = authorization as? ApiKey {
            self.authorizationHeader = (key: Constants.HeaderKeys.XApiKey, value: apiKeyAuthorization.key)
        } else if authorization is Bearer {
            Task(priority: .high, operation: { [weak self] in
                try await self?.generateBearerToken()
            })
        }
    }
    
    private func generateBearerToken() async throws {
        guard var bearerAuthorization: Bearer = self.authorization as? Bearer else { return }
        
        do {
            let requestBody: [String: String] = ["username": bearerAuthorization.username, "password": bearerAuthorization.password]
            
            let request: Request = Request(baseUrl: bearerAuthorization.url, endpoint: .login, method: .post, headers: [Constants.HeaderKeys.ContentType: Constants.HeaderValues.ApplicationJson], body: requestBody)
            let reponseData: Data = try await send(request)
            let responseObject: BearerAuthorizationResponse = try self.jsonDecoder.decode(BearerAuthorizationResponse.self, from: reponseData)
            
            bearerAuthorization.expiryDate = Date().addingTimeInterval(responseObject.expiresIn)
            
            self.authorizationHeader = (key: Constants.HeaderKeys.BearerAuthorization, value: "Bearer \(responseObject.accessToken)")
            self.authorization = bearerAuthorization
            
            print("Generated new Bearer token. Token: \(responseObject.accessToken), expires: \(bearerAuthorization.expiryDate)")
        } catch {
            print("Error while generating a Bearer token. Error: \(error.localizedDescription)")
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
        case 500:
            throw RequestError.internalServerError
        default:
            throw RequestError.unexpectedStatusCode
        }
    }
    
    func post(data: InternalApiObject) async throws {
        // Check if new bearer token needs to be created
        if let bearerAuthorization: Bearer = authorization as? Bearer, bearerAuthorization.expiryDate <= Date() {
            try await generateBearerToken()
        }
        
        if let baseURL = self.baseURL {
            let requestHeaders: [String: String] = [
                Constants.HeaderKeys.ContentType: Constants.HeaderValues.ApplicationJson,
                Constants.HeaderKeys.TenantId: self.tenantID ?? "",
                self.authorizationHeader?.key ?? "": self.authorizationHeader?.value ?? ""
            ]
            
            do {
                let request: Request = Request(baseUrl: baseURL, endpoint: .bulk, method: .post, headers: requestHeaders, body: data)
                _ = try await send(request)
                
                retryRequestOnUnauthorizedError = true
            } catch RequestError.unauthorized {
                if var bearerAuthorization: Bearer = authorization as? Bearer {
                    // Force generating a new bearer token on next request
                    bearerAuthorization.expiryDate = Date(timeIntervalSince1970: 0)
                    self.authorization = bearerAuthorization
                    
                    if retryRequestOnUnauthorizedError {
                        retryRequestOnUnauthorizedError = false // Try to resend request only once
                        do {
                            try await post(data: data)
                        } catch {
                            throw error
                        }
                    } else {
                        throw RequestError.unauthorized
                    }
                }
            } catch {
                throw error
            }
            
        } else {
            throw RequestError.invalidURL
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
        case internalServerError
        
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
            case .internalServerError:
                return "Server returned internal server error"
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
    func configure(tenantID: String, baseURL: URL, authorization: Authorization)
    func post(data: InternalApiObject) async throws
}

