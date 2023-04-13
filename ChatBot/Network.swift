//
//  Network.swift
//  RadiusCare
//
//  Created by Riddhi Makwana on 24/08/21.
//

import Foundation
import UIKit
import Alamofire

enum NetworkRequestStatus {
    case success
    case failure(Error)
}

struct NetworkRequest {
    var url: String
    var requestType: HTTPMethod
    var parameater: [String:Any]?
}

class NetworkManager: NSObject {
    
    static let shared: NetworkManager = NetworkManager()
    
    private func callAPI1(request: NetworkRequest,
                          completionHandler: @escaping(_ response: String?, _ status: NetworkRequestStatus) -> Void){
        
        print("\n\n----------------")
        print(request.url,"\n")
        request.parameater?.forEach { print("\($0):\($1)") }
        print("----------------\n\n")
        
        let token = UserDefaults.standard.value(forKey: "token") as? String ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        guard let url = request.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            completionHandler(nil, .failure(NSError(domain: "", code:400, userInfo: [NSLocalizedDescriptionKey:"something went wrong"]) as Error))
            return
        }
        
        AF.request(
            url,
            method: request.requestType,
            parameters: request.parameater,
            headers: nil
        ).responseString { (response) in
            if response.response?.statusCode != 401{
                switch response.result {
                case .success:
                    let responseValue = response.value ?? ""
                    completionHandler(responseValue, .success)
                    
                case let .failure(error):
                    completionHandler(nil, .failure(error))
                }
            }else{
                //            Utils.unAuthorizedAccessAndLogOut()
            }
        }
    }
    private func callAPI(request: NetworkRequest,
                         completionHandler: @escaping(_ response: [String:Any]?, _ status: NetworkRequestStatus) -> Void){
        
        print("\n\n----------------")
        print(request.url,"\n")
        request.parameater?.forEach { print("\($0):\($1)") }
        print("----------------\n\n")
        
        let token = UserDefaults.standard.value(forKey: "token") as? String ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        guard let url = request.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            completionHandler(nil, .failure(NSError(domain: "", code:400, userInfo: [NSLocalizedDescriptionKey:"something went wrong"]) as Error))
            return
        }
        
        AF.request(
            url,
            method: request.requestType,
            parameters: request.parameater,
            headers: headers
        ).responseJSON { (response) in
            if response.response?.statusCode != 401{
                switch response.result {
                case .success:
                    let dict = response.value as! [String:Any]
                    completionHandler(dict, .success)
                    
                case let .failure(error):
                    completionHandler(nil, .failure(error))
                }
            }else{
                //Utils.unAuthorizedAccessAndLogOut()
            }
        }
    }
    
//    func requestWithPostJsonParamWithParseData(
//        endpointurl:String,
//        service:String,
//        parameters:NSDictionary,
//        keyname:NSString,
//        message:String,
//        showloader:Bool,
//        responseData:
//            @escaping  (_ error: NSError?,_ message: NSString?,_ responseDict: NSDictionary?) -> Void)
//    {
//            
//        
//        AF.request(endpointurl, method: .post, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseString) in
//            if let statusCode = responseString.response?.statusCode
//            {
//                switch statusCode {
//                case 200:
//                    let dict = responseString.value as! NSArray
//
//                    responseData(nil,"",dict as NSDictionary?)
//                    break
//                default:
//                    break
//                }
//            }
//        }
//    }
    
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        
        
        return nil
    }
    
    func convertDict(text: String){
        if let data = text.data(using: .utf8) {
            do {
                let myJson = try JSONSerialization.jsonObject(with: data,
                                                               options: JSONSerialization.ReadingOptions.allowFragments) as Any

                 if myJson is String {
                   print(myJson) // <-- This will not print anything as myJson is not a string
                 }

                 if let dict = myJson as? [String: Any] {
                   print(dict.keys) // <-- This will print a list of keys
                 }
                
                if let arr = myJson as? NSArray {
                    for dic in arr{
                        print(dic)
                    }
                }
            } catch {
                print("Something went wrong")
            }
        }
    }
    func getResponseDictionary(strString:String,complete:@escaping(_ isSuccess:Bool,_ dicResponse:NSDictionary?)->())
    {
        var strResponse = "\(strString)"
        strResponse = strResponse.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let arr = strResponse.components(separatedBy: "\n")
        var dict : [String:Any]?
        for jsonString in arr{
            var strResponse = jsonString
            
            if(strResponse.hasPrefix("["))
            {
                strResponse = String(strResponse.dropFirst())
                strResponse = String(strResponse.dropLast())
            }
            
            if let jsonDataToVerify = strResponse.data(using: String.Encoding.utf8)
            {
                do {
                    dict = try JSONSerialization.jsonObject(with: jsonDataToVerify) as? [String : Any]
                    complete(true,dict! as NSDictionary)
                } catch {
                    print("Error deserializing JSON: \(error.localizedDescription)")
                    complete(false,nil)
                }
            }
        }
    }
}
extension NetworkManager{
    func sendMessageAPI(url : String ,
                        param :[String : Any],
                        success: @escaping (_ response:  String) -> Void,
                        failure: @escaping (_ error: Error?) -> Void){
        
        let request = NetworkRequest(url: url, requestType: .post, parameater: param)
        callAPI1(request: request) { (data, status) in
            switch status {
            case .success:
                
                guard let data = data  else {
                    failure(nil)
                    return
                }
                
                success(data)
                break
                
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func sendMessageAPI1(url : String ,
                         param :[String : Any],
                         success: @escaping (_ response:  [String:Any]) -> Void,
                         failure: @escaping (_ error: Error?) -> Void){
        
        let request = NetworkRequest(url: url, requestType: .post, parameater: param)
        callAPI(request: request) { (data, status) in
            switch status {
            case .success:
                
                guard let data = data  else {
                    failure(nil)
                    return
                }
                
                success(data)
                break
                
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
}

