//
//  OSSTask.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/12.
//

import Foundation
import PerfectCURL
import PerfectCrypto
import PerfectLib
import PerfectHTTP
import PerfectThread

class OSSTask {
    
    public struct Error: Swift.Error {
        /// The curl specific request response code.
        public let code: Int
        /// The string message for the curl response code.
        public let description: String
    }
    
    class func start(request: OSSRequest, result: @escaping ((_: Bool, _: String) -> Void)) {
//        print("GMT时间格式：\(request.GMTDate())\n")
//        print("签名格式：\(request.signature())\n")
//        print("验证格式：\(request.authorization() ?? "")\n")
        
        let curlRequest =  request.curlRequest()
        curlRequest.perform {
            (confirmation: CURLResponse.Confirmation) in
            do {
                 let response = try confirmation()
//                let json: [String:Any] = response.bodyJSON
//                print("Success：\(response.responseCode) \n \(response.bodyString) \n \(json)")
                if response.responseCode == 200 {
                     result(true, "")
                } else {
                    result(false, response.bodyString)
                }
            } catch let error as CURLResponse.Error {
                result(true, error.response.bodyString)
//                print("出错，响应代码为： \(error.response.responseCode)")
            } catch {
                result(true, "致命错误： \(error)")
//                print("致命错误： \(error)")
            }
            
        }
    }
    
    class func start(request: OSSRequest) -> Promise<[String:Any]> {
        
        let promise = Promise<[String:Any]> { (prom)  in
            let curlRequest =  request.curlRequest()
            curlRequest.perform {
                (confirmation: CURLResponse.Confirmation) in
                do {
                    let response = try confirmation()
                    if response.responseCode == 200 {
                        prom.set(response.bodyJSON)
                    } else {
                        prom.fail(Error(code: response.responseCode, description: response.bodyString))
                    }
                } catch let error as CURLResponse.Error {
                    prom.fail(error)
                } catch {
                    prom.fail(Error(code: 400, description: "response解析失败！"))
                }
                
            }
        }
        return promise
    }
    
}
