//
//  AliyunOSSModule.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/3/30.
//

import Foundation
import PerfectCURL
import PerfectCrypto





class OSSRequest {
    var accessKeyId = "LTAIP46PMViRaQCJ"
    var accessKeySecret = "T4eDGknsW2PBbDpQ9tcqTEks42tahs"
    var bucketName = "appdeliver"
    let endPoint = "oss-cn-hangzhou.aliyuncs.com"
    var objectKey = ""
    ///VERB表示HTTP 请求的Method，主要有PUT，GET，POST，HEAD，DELETE等
    var verb = ""
    ///host = bucketName + endPoint
    var host: String {
        return "\(bucketName).\(endPoint)"
    }    
    var contentMD5 = ""
    var contentType = ""
    
    ///计算获取授权信息
    func authorization() -> String? {
        //方法参考https://help.aliyun.com/document_detail/31951.html?spm=a2c4g.11186623.6.869.FWp9NK
        let data = "\(verb)\n\(contentMD5)\n\(contentType)\n\(GMTDate())\n\(canonicalizedOSSHeaders())\(canonicalizedResource())"
        if let signed = data.sign(.sha1, key: HMACKey(accessKeySecret))?.encode(.base64),
            let base64Str = String(validatingUTF8: signed) {
            return "OSS \(accessKeyId):\(base64Str)"
        }
        return nil
    }
    
    ///获取GMT格式date
    func GMTDate() -> String {
        return Date().description;
    }
    
    ///CanonicalizedOSSHeaders
    func canonicalizedOSSHeaders() -> String {
        return ""
    }
    
    ///CanonicalizedResource
    func canonicalizedResource() -> String {
        return ""
    }
}

class PutObjectRequest: OSSRequest {
    override init() {
        super.init()
        verb = "PUT"
    }
}


class OSSTask {

}


