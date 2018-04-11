//
//  AliyunOSSModule.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/3/30.
//

import Foundation
import PerfectCURL
import PerfectCrypto
import PerfectLib
import PerfectHTTP



class OSSRequest {
    var accessKeyId: String = aliyunAccessKeyInfo().accessKeyId
    var accessKeySecret = aliyunAccessKeyInfo().accessKeySecret
    var bucketName = "appdeliver"
    let endPoint = "oss-cn-hangzhou.aliyuncs.com"
    var objectKey = ""
    ///VERB表示HTTP 请求的Method，主要有PUT，GET，POST，HEAD，DELETE等
    var verb = ""
    ///host = bucketName + endPoint
    var host: String {
        return "\(bucketName).\(endPoint)"
    }
    
    var url: String {
        return "http://\(self.host)"
    }
    
    
    var data: [UInt8]?
    var date = Date()
    
    var contentMD5: String? {
        if let data = data,
           let md5 = data.digest(.md5)?.encode(.base64),
           let md5Str = String(validatingUTF8: md5) {
            return md5Str
        }
        return nil
    }
    var contentType = "multipart/form-data; boundary=9431149156168"
    
    ///计算获取授权信息
    func authorization() -> String? {
        let data = signature()
        //方法参考https://help.aliyun.com/document_detail/31951.html?spm=a2c4g.11186623.6.869.FWp9NK
        if let signed = data.sign(.sha1, key: HMACKey(accessKeySecret))?.encode(.base64),
            let base64Str = String(validatingUTF8: signed) {
            let authorization = "OSS \(accessKeyId):\(base64Str)"
            return authorization
        }
        return nil
    }
    
    ///签名
    func signature() -> String {
        var commentmd5 = ""
        if let md5 = self.contentMD5 {
            commentmd5 = md5 + "\n"
        }
        let data = "\(verb)" + "\n"
            + "\(commentmd5)"
            + "\(contentType)" + "\n"
            + "\(GMTDate())" + "\n"
            + "\(canonicalizedOSSHeaders())"
            + "\(canonicalizedResource())"
        return data
    }
    
    
    ///获取GMT格式date
    func GMTDate() -> String {
        let date = self.date
        let dateFormatter = DateFormatter()
        //Wed, 05 Sep. 2012 23:00:00 GMT        
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    ///CanonicalizedOSSHeaders
    func canonicalizedOSSHeaders() -> String {
        return ""
    }
    
    ///CanonicalizedResource
    func canonicalizedResource() -> String {
        return "" + "/\(bucketName)" + "/\(objectKey)"
    }
    
    func policy() -> String {
        let dic: [String : Any] = ["expiration": "2019-12-01T12:00:00.000Z",
                   "conditions": [["bucket": bucketName]]]
        return String(validatingUTF8: (try! dic.jsonEncodedString()).encode(.base64) ?? [UInt8]()) ?? ""
    }
}

class PutObjectRequest: OSSRequest {
    var file: File
    
    init(file: File ,objectName name: String) {
        self.file = file
        super.init()
        do {
            self.data = try file.readSomeBytes(count: file.size)
        } catch  {}
        self.objectKey = name
        verb = "POST"
    }
    
    func postString() -> String {
        let data = self.policy()
        //方法参考https://help.aliyun.com/document_detail/31951.html?spm=a2c4g.11186623.6.869.FWp9NK
        let signed = String(validatingUTF8:data.sign(.sha1, key: HMACKey(self.accessKeySecret))?.encode(.base64) ?? [UInt8]()) ?? ""
        let dic: [String: String] = ["OSSAccessKeyId":self.accessKeyId,
                   "policy": self.policy(),
                   "signature": signed,
                   "ResourceType": "Object", "key":self.objectKey,
                   "x-oss-object-acl": "public-read",
                   "success_action_status": "200",
                   "file": String(describing: self.data ?? [UInt8]())]
        let fileds =  dic.map({ filed -> String in
            return "Content-Disposition: form-data; name=\"" + filed.key + "\"" + "\r\n\r\n" + filed.value + "\r\n--9431149156168"
        })
        let string = fileds.joined(separator: "\r\n")
        print(string)
        return "\r\n--9431149156168" +  string
    }
    
}

class OSSTask {
    class func start(request: PutObjectRequest) {
        print("GMT时间格式：\(request.GMTDate())\n")
        print("签名格式：\(request.signature())\n")
        print("验证格式：\(request.authorization() ?? "")\n")
        
        let curlRequest =  CURLRequest(request.url,
                                         .addHeader(.contentLength, String.init(((request.data ?? [UInt8]()).count))),
                                         .addHeader(.contentType, request.contentType),
                                         .addHeader(.host, request.host),
//                                         .postField(CURLRequest.POSTField(name: "OSSAccessKeyId", value: "request.accessKeyId\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "policy", value: request.policy() + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "signature", value: signed + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "ResourceType", value: "Object" + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "key", value: request.objectKey + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "x-oss-object-acl", value: "public-read" + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "success_action_status", value: "200" + "\r\n--9431149156168")),
//                                         .postField(CURLRequest.POSTField(name: "file", value: String(describing: request.data ?? [UInt8]()) + "\r\n--9431149156168")),
                                         .postString(request.postString()),
                                         .httpMethod(HTTPMethod.from(string: request.verb))
            )     
            curlRequest.perform {
                (confirmation: CURLResponse.Confirmation) in
                        do {
                            let response = try confirmation()
                            let json: [String:Any] = response.bodyJSON
                            print("Success：\(response.responseCode) \n \(response.bodyString) \n \(json)")
                        } catch let error as CURLResponse.Error {
                            print("出错，响应代码为： \(error.response.responseCode)")
                        } catch {
                            print("致命错误： \(error)")
                        }

             }
    }
    
}


