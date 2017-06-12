//
//  RequestOperation.swift
//  Ascents
//
//  Created by Theophile on 06.02.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import HTTPStatusCodes

// localization check:disable

/// This class is responsibible to sent the request to the server through the Alamofire api
class RequestOperation<ReturnedObject: Mockable & Mappable>: AsynchronousOperation {
    
    typealias CompletionHandler = ((ReturnedObject?, _ headers: [AnyHashable: Any]?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void)
    typealias CompletionHandlerArray = (([ReturnedObject]?, _ headers: [AnyHashable: Any]?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void)
    typealias CompletionHandlerJSON = (([String: Any]?, _ headers: [AnyHashable: Any]?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void)
    
    var endpoint: Endpoint
    var headers: HTTPHeaders?
    
    private var completion: CompletionHandler?
    private var completionArray: CompletionHandlerArray?
    private var completionJSON: CompletionHandlerJSON?
    
    
    fileprivate var request: Alamofire.DataRequest?
    fileprivate var response: DataResponse<ReturnedObject>?
    fileprivate var responseArray: DataResponse<[ReturnedObject]>?
    fileprivate var responseServerMessage: String?
    
    private init(_ apiCall: Endpoint, _ headers: HTTPHeaders? = nil) {
        
        self.endpoint = apiCall
        self.headers = headers
        
        super.init()
        
        self.name = "Generic request operation"
    }
    
    ///  Initializer for the APIRequestOperation when the response is expected to be an object
    ///
    ///  - parameter apiCall:           An object conform to the APIRequestConvertible protocol use to create the request
    ///  - parameter returningClass:    The Type of object we expect to have in return, nil if we dont expect any object in return
    ///  - parameter completionHandler: A closure called once the request operation finished its execution.
    ///
    ///  - returns: A new APIRequestOperation object
    convenience init(apiCall: Endpoint, headers: HTTPHeaders? = nil, completionHandler:@escaping CompletionHandler) {
        
        self.init(apiCall, headers)
        
        self.completion = completionHandler
    }
    
    
    ///  Initializer for the APIRequestOperation when the response is expected to be an array of objects
    ///
    ///  - parameter apiCall:           An object conform to the APIRequestConvertible protocol use to create the request
    ///  - parameter returningClass:    The Type of object we expect to have in return, nil if we dont expect any object in return
    ///  - parameter completionHandler: A closure called once the request operation finished its execution.
    ///
    ///  - returns: A new APIRequestOperation object
    convenience init(apiCall: Endpoint, headers: HTTPHeaders? = nil, completionHandler:@escaping CompletionHandlerArray) {
        
        self.init(apiCall, headers)
        
        self.completionArray = completionHandler
    }
    
    ///  Initializer for the APIRequestOperation when the response is expected to be a JSON
    ///
    ///  - parameter apiCall:           An object conform to the APIRequestConvertible protocol use to create the request
    ///  - parameter returningClass:    The Type of object we expect to have in return, nil if we dont expect any object in return
    ///  - parameter completionHandler: A closure called once the request operation finished its execution.
    ///
    ///  - returns: A new APIRequestOperation object
    convenience init(apiCall: Endpoint, headers: HTTPHeaders? = nil, returnedObject: ReturnedObject, completionHandler:@escaping CompletionHandlerJSON) {
        
        self.init(apiCall, headers)
        
        self.completionJSON = completionHandler
    }
    
    override func main() {
        
        switch endpoint.requiredLevel {
        case .none: break
        case .levelOne: break
        case .levelTwo: break
        }
        
        var url: URL
        do {
            url = try encodedURL(from: endpoint)
        } catch let error {
            self.completeOperation(completeOperation(with: nil, headers: nil, statusCode: nil, error: error))
            return
        }
        
        if let headerParameters = endpoint.query.headerParameters {
            if case .some = headers {
                headerParameters.forEach { (key: String, value: String) in self.headers?[key] = value }
            } else { self.headers = headerParameters}
        }
        
        // Create the request
        if case .some = endpoint.query.attachedImages {
            sendMultipartRequest(for: endpoint, to: url)
        } else {
            self.request = Service.networkManager.request(url, method: endpoint.method, parameters: endpoint.query.bodyParameters,
                                                          encoding:endpoint.query.encoding, headers: headers)
            sendRequest()
        }
    }
    
    override func cancel() {
        self.request?.cancel()
    }
    
    private func sendRequest() {
        /* Uncomment the next line to have the request in textual representation used when written to an output stream, in the form of a cURL command. */
        LogRequest.debug(self.request?.debugDescription)
        
        guard Environment.server != .mock else {
            
            // Delay to illustrate the request
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                
                self.completeOperation(with: ReturnedObject.mock(), arrayValue: [ReturnedObject.mock()], headers: nil, statusCode: nil, error: nil)
            }
            return
        }
        
        if case .some = completionJSON {
            
            self.request?.responseJSON { response in
                if let data = response.data {self.responseServerMessage = String(data: data, encoding: .utf8)}
                self.completeOperation(jsonValue: response.result.value as? [String: Any], headers: response.response?.allHeaderFields,
                                       statusCode: HTTPStatusCode(HTTPResponse: response.response), error: response.result.error)
            }
        } else if ReturnedObject.self == Service.NullObject.self {
            
            self.request?.response { response in
                if let data = response.data {self.responseServerMessage = String(data: data, encoding: .utf8)}
                self.completeOperation(with: nil, headers: response.response?.allHeaderFields,
                                       statusCode: HTTPStatusCode(HTTPResponse: response.response), error: response.error)
            }
            
        } else if case .some = completion {
            
            self.request?.responseObject { (response: DataResponse<ReturnedObject>) in
                self.response = response
                if let data = response.data {self.responseServerMessage = String(data: data, encoding: .utf8)}
                self.completeOperation(with: response.result.value, headers: response.response?.allHeaderFields,
                                       statusCode: HTTPStatusCode(HTTPResponse: response.response), error: response.result.error)
            }
        } else if case .some = completionArray {
            
            self.request?.responseArray { (response: DataResponse<[ReturnedObject]>) in
                self.responseArray = response
                if let data = response.data {self.responseServerMessage = String(data: data, encoding: .utf8)}
                self.completeOperation(arrayValue: response.result.value, headers: response.response?.allHeaderFields,
                                       statusCode: HTTPStatusCode(HTTPResponse: response.response), error: response.result.error)
            }
            
        }
    }
    
    private func sendMultipartRequest(for endpoint: Endpoint, to url: URL) {
        
        Service.networkManager.upload(multipartFormData: { (multipartFormData) in
            endpoint.query.attachedImages?.forEach { image in
                guard let imageData = UIImageJPEGRepresentation(image, 1.0) else { return }
                multipartFormData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
            }
        }, to: url, method: endpoint.method, headers: endpoint.query.headerParameters) { (encodingCompletion) in
            switch encodingCompletion {
            case .success(let request, _, _):
                self.request = request
                self.sendRequest()
            case .failure(let error): print(error)
            self.completeOperation(headers: nil, statusCode: nil, error: error)
            }
        }
    }
    
    private func completeOperation(with value: ReturnedObject? = nil, arrayValue: [ReturnedObject]? = nil, jsonValue: [String:Any]? = nil, headers: [AnyHashable:Any]?, statusCode: HTTPStatusCode?, error: Error?) {
        
        var error = APIError(error: error, status: statusCode)
        if case .none = error, let statusCode = statusCode, !statusCode.isSuccess {
            error = APIError(serverMessage: responseServerMessage, status: statusCode)
        }
        
        if case .none = error {
            LogRequest.info { return self.requestDescription }
            
        } else {
            LogRequest.warning { return self.requestDescription }
        }
        
        self.completion?(value, headers, statusCode, error)
        self.completionArray?(arrayValue, headers, statusCode, error)
        self.completionJSON?(jsonValue, headers, statusCode, error)
        
        var userInfo = [AnyHashable: Any]()
        if let value = value { userInfo["value"] = value }
        if let headers = headers { userInfo["headers"] = headers }
        if let statusCode = statusCode { userInfo["statusCode"] = statusCode }
        if let error = error { userInfo["error"] = error }
        
        NotificationCenter.default.post(name: Service.requestDidCompleteNotification, object: self, userInfo: userInfo)
        
        completeOperation()
    }
    
    private func encodedURL(from endpoint: Endpoint) throws -> URL {
        
        //Serialization
        var urlComponents = URLComponents()
        urlComponents.scheme = Environment.urlScheme(endpoint.category)
        urlComponents.host = endpoint.baseHost
        urlComponents.port = endpoint.port as Int?
        urlComponents.path = endpoint.query.path
        
        guard let url = urlComponents.url else { throw AFError.parameterEncodingFailed(reason: .missingURL) }
        
        var urlRequest = URLRequest(url: url)
        
        // Serialization of the request
        if let urlParameters = endpoint.query.urlParameters {
            urlRequest = try Alamofire.URLEncoding.`default`.encode(urlRequest, with: urlParameters)
        }
        
        guard let encodedURL = urlRequest.url else { throw AFError.parameterEncodingFailed(reason: .missingURL) }
        
        return encodedURL
    }
    
    fileprivate func errorDescription(result: Result<ReturnedObject>?, status: Int?) -> String? {
        
        var errorDescription: String?
        if let result = result, case let .failure(error) = result {
            if let error = error as? AFError {
                errorDescription = error.description
            } else if let error = error as? URLError {
                errorDescription = "URLError occurred: \(error)"
            } else {
                errorDescription = "Unknown error: \(error)"
            }
        }
        
        var serverErrorDescription: String?
        if let status = status, !(200..<300 ~= status) {
            serverErrorDescription = responseServerMessage
        }
        
        switch (errorDescription, serverErrorDescription) {
        case (.some(let errorDescription), .some(let serverErrorDescription)): return "\(errorDescription)\n\(serverErrorDescription)"
        case (.none, .none): return nil
        default: return "\(errorDescription ?? "")\(serverErrorDescription ?? "")"
        }
    }
}

extension AFError {
    
    public var description: String {
        return debugDescription
    }
    
    public var debugDescription: String {
        
        var description = ""
        
        switch self {
            
        case .invalidURL(let url):
            description =  "Invalid URL: \(url) - \(localizedDescription)\n"
        case .parameterEncodingFailed(let reason):
            description =  "Parameter encoding failed: \(localizedDescription)\n"
            description += "Failure Reason: \(reason)\n"
        case .multipartEncodingFailed(let reason):
            description =  "Multipart encoding failed: \(localizedDescription)\n"
            description += "Failure Reason: \(reason)\n"
        case .responseValidationFailed(let reason):
            description =  "Response validation failed: \(localizedDescription)\n"
            description += "Failure Reason: \(reason)\n"
            
            switch reason {
                
            case .dataFileNil, .dataFileReadFailed:
                description += "Downloaded file could not be read\n"
            case .missingContentType(let acceptableContentTypes):
                description += "Content Type Missing: \(acceptableContentTypes)\n"
            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                description += "Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)\n"
            case .unacceptableStatusCode(let code):
                description += "Response status code was unacceptable: \(code)\n"
            }
        case .responseSerializationFailed(let reason):
            description =  "Response serialization failed: \(localizedDescription)\n"
            description += "Failure Reason: \(reason)\n"
        }
        if let underlyingError = underlyingError { description += "Underlying error: \(underlyingError)" }
        
        return description
    }
}


extension RequestOperation {
    
    public var requestDescription: String {
        
        guard let url = request?.request?.url else {return ""}
        
        var logRequest = "- - - - - - - \(endpoint.description)  - - - - - - -"
        let firstLineCharNumber = logRequest.characters.count
        
        logRequest = "REQUEST\n" + logRequest
        
        logRequest += "\n    Request : \(endpoint.method) - \(url)"
        
        if let headerFields = request?.request?.allHTTPHeaderFields, !headerFields.isEmpty {
            logRequest += "\n    Headers : \(headerFields)"
        }
        if let body = endpoint.query.bodyParameters {
            logRequest += "\n    Body    : \(body)"
        }
        if let statusCode = request?.response?.statusCode {
            logRequest += "\n    Response: (\(statusCode))"
        }
        if let responseObject = response?.result.value,
            let responseJSON = response?.result.value?.toJSONString(prettyPrint: true) {
            logRequest += "\n\(responseObject) :\n\(responseJSON)"
        }
        if let responseObjectArray = responseArray?.result.value,
            let responseJSON = responseArray?.result.value?.toJSONString(prettyPrint: true) {
            logRequest += "\n\(responseObjectArray) :\n\(responseJSON)"
        }
        if let errorDescription = errorDescription(result: response?.result, status: request?.response?.statusCode) {
            logRequest += "\n    Error:\n\(errorDescription)"
        }
        
        
        var lastLine: String = ""
        var lenght = 0
        while lenght < firstLineCharNumber {
            lastLine += "- "
            lenght = lastLine.characters.count
        }
        
        return logRequest + "\n" + lastLine
    }
}
 

public struct APIError: Error {
    
    var title: String
    var description: String
    var statusCode: HTTPStatusCode?
    
    private init(title: String, description: String, statusCode: HTTPStatusCode?) {
        self.title = title
        self.description = description
        self.statusCode = statusCode
    }
    
    init(serverMessage: String?, status: HTTPStatusCode?) {
        
        var title = "Server Error"
        var description = "Failed to complete request. An unknown error occured"
        
        if let serverMessage = serverMessage,
            let data = serverMessage.data(using: .utf8),
            let dic = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            title = dic?["message"] as? String ?? "Server Error"
            let objects = dic?["fieldErrors"] as? [[String:String]]
            var descriptionMessage = ""
            objects?.forEach {
                guard let fieldName = $0["fieldName"], let message = $0["message"] else { return }
                descriptionMessage += "\(fieldName): \(message)\n"
            }
            description = descriptionMessage
        } else if let status = status {
            description = status.description
        }
        self.init(title: title, description: description, statusCode: status)
    }
    
    init?(error: Error?, status: HTTPStatusCode?) {
        
        guard let error = error else { return nil }
        self.init(title:"Server Error", description: error.localizedDescription, statusCode: status)
    }
}
