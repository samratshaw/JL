//
//  BaseService.swift
//  JustLogin_MECS
//
//  Created by Samrat on 16/2/17.
//  Copyright © 2017 SMRT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 * The response of the network adapter.
 */
enum NetworkAdapterResponse {
    case Success(response : [String: Any], headers : [String:String])
    case Errors([String: Any])
    case Failure(String)
}

/**
 * Enum that will be returned from the service class to the manager.
 */
enum Result<T> {
    case Success(T)
    case Error(ServiceError)
    case Failure(String)
}

/**
 * The error received from the server.
 */
struct ServiceError {
    let errorCode: String
    let errorMessage: String
    
    init(_ json:JSON) {
        errorCode = json[Constants.ResponseParameters.ErrorCode].exists() ? json[Constants.ResponseParameters.ErrorCode].stringValue : Constants.General.EmptyString
        
        errorMessage = json[Constants.ResponseParameters.ErrorMessage].exists() ? json[Constants.ResponseParameters.ErrorMessage].stringValue : Constants.General.EmptyString
    }
}

/**
 * The adapter protocol that allows to call web services.
 */
protocol NetworkAdapter {
    
    func post(destination: String, payload: [String: Any], headers: [String : String],responseHandler: @escaping (NetworkAdapterResponse) -> Void)
}

/**
 * The AlamofireNetworkAdapter that implements the NetworkAdapter using Alamofire.
 */
struct AlamofireNetworkAdapter: NetworkAdapter {
    
    func post(destination: String, payload: [String : Any], headers: [String : String], responseHandler: @escaping (NetworkAdapterResponse) -> Void) {
        
        log.debug("*****************************")
        log.debug("**** Web Service Request ****")
        log.debug("*****************************")
        log.debug("Request url -> \(destination)")
        log.debug("Request type -> HTTP POST")
        log.debug("Request headers -> \(headers)")
        log.debug("Request payload -> \(payload)")
        
        Alamofire.request(destination, method: .post, parameters: payload, encoding: JSONEncoding.default)
            .responseJSON { response in responseHandler(response.networkAdapterResponse) }
    }
}

/**
 * Extending the library response to be according to our custom response.
 */
extension Alamofire.DataResponse {
    
    var networkAdapterResponse: NetworkAdapterResponse {
        
        log.debug("*****************************")
        log.debug("**** Web Service Reponse ****")
        log.debug("*****************************")
        log.debug("Response url -> \((self.request?.url?.absoluteString)!)")
        
        if let message = self.result.error?.localizedDescription {
            log.error("Response failure -> \(message)")
            return NetworkAdapterResponse.Failure(message)
        }
        
        let headers = self.response?.allHeaderFields as! [String: String]
        
        log.debug("Response status code -> \((self.response?.statusCode)!)")
        log.debug("Response headers -> \(headers)")
        log.debug("Response payload -> \((self.result.value)!)")
        
        // Check the success status code first.
        guard self.response?.statusCode == Constants.ResponseParameters.StatusCode else {
            log.error("Invalid status code -> \((self.response?.statusCode)!)")
            return NetworkAdapterResponse.Failure("Server returned status code != 200")
        }
        
        guard let json = self.result.value as? [String: Any] else {
            log.error("Invalid json received -> \(self.result.value)")
            return NetworkAdapterResponse.Failure("Invalid JSON response")
        }
        
        if let errors = json[Constants.ResponseParameters.Errors] as? [String: Any] {
            return NetworkAdapterResponse.Errors(errors)
        }
        
        let data = json[Constants.ResponseParameters.Data] as! [String: Any]
        return NetworkAdapterResponse.Success(response: data, headers: headers)
    }
}
