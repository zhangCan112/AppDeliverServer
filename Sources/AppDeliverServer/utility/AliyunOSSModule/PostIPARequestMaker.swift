//
//  PostObjectRequestMaker.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/23.
//

import Foundation
import PerfectLib
import PerfectCrypto


class PostIPARequestMaker {
    var accessKeyId: String = aliyunAccessKeyInfo().accessKeyId
    var accessKeySecret = aliyunAccessKeyInfo().accessKeySecret
    var bucketName = "appdeliver"
    let endPoint = "oss-cn-hangzhou.aliyuncs.com"
    let success_action_status = 200
    var objectKey = ""
    var host: String {
        return "\(bucketName).\(endPoint)"
    }
    var policy: String = ""
    var signature: String = ""
    var downloadUrl: String {
        return "https://\(self.host)/\(self.objectKey)"
    }
    
    
    init(ipaInfo: IpaInfo, uuid: String) {
        self.objectKey = getObjectKey(ipaInfo: ipaInfo, uuid: uuid)
        self.policy = getPolicy()
        self.signature = getSignature()
    }
    
    func getObjectKey(ipaInfo: IpaInfo, uuid: String) -> String {
        return "ipa/\(uuid)-\(ipaInfo.displayName)"
    }
    
    func getPolicy() -> String {
        let  policyDic: [String: Any] = ["expiration": "2020-01-01T12:00:00.000Z",
                                        "conditions": [["content-length-range", 0, 1048576000]]]
        let jsonString = try! policyDic.jsonEncodedString()
        return String(validatingUTF8: jsonString.encode(.base64) ?? [UInt8]()) ?? ""
    }
    
    func getSignature() -> String {
        let encoded = self.policy
        //方法参考https://help.aliyun.com/document_detail/31951.html?spm=a2c4g.11186623.6.869.FWp9NK
        if let signed = encoded.sign(.sha1, key: HMACKey(accessKeySecret))?.encode(.base64),
            let base64Str = String(validatingUTF8: signed) {
            let authorization = base64Str
            return authorization
        }
        return ""
    }
}
