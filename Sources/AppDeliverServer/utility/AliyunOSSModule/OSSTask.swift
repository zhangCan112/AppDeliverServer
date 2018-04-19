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

class OSSTask {
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
    
}
