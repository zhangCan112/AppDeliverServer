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
    var accessKeyId = aliyunAccessKeyInfo().accessKeyId
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
    var contentType = "application/octet-stream"
    
    ///计算获取授权信息
    func authorization() -> String? {
        var commentmd5 = ""
        if let md5 = self.contentMD5 {
            commentmd5 = md5 + "\n"
        }
        //方法参考https://help.aliyun.com/document_detail/31951.html?spm=a2c4g.11186623.6.869.FWp9NK
        let data = "\(verb)" + "\n"
            + "\(commentmd5)"
            + "\(contentType)" + "\n"
            + "\(GMTDate())" + "\n"
            + "\(canonicalizedOSSHeaders())"
            + "\(canonicalizedResource())"
        if let signed = data.sign(.sha1, key: HMACKey(accessKeySecret))?.encode(.base64),
            let base64Str = String(validatingUTF8: signed) {
            let authorization = "OSS \(accessKeyId):\(base64Str)"
            return authorization
        }
        return nil
    }
    
    ///获取GMT格式date
    func GMTDate() -> String {
        let date = self.date
        let dateFormatter = DateFormatter()
        //Wed, 05 Sep. 2012 23:00:00 GMT        
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
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
        verb = "PUT"
    }
}

class OSSTask {
    class func start(request: OSSRequest) {
        CURLRequest(request.url,
                    .httpMethod(HTTPMethod.from(string: request.verb)),
                    .addHeader(.contentLength, String.init(((request.data ?? [UInt8]()).count))),
                    .addHeader(.contentMD5, request.contentMD5 ?? ""),
                    .addHeader(.contentType, request.contentType),
                    .addHeader(.date, request.GMTDate()),
                    .addHeader(.authorization, request.authorization() ?? ""),
                    .addHeader(.host, request.host))
            .perform {
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


