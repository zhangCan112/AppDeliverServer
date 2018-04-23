//
//  PostIPARequestData.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/23.
//

import ObjectMapper

class PostIPARequestData: Mappable {
    var host = ""
    var oSSAccessKeyId = ""
    var key = ""
    var success_action_status = ""
    var policy = ""
    var signature = ""
    
    
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        host    <- map["host"]
        oSSAccessKeyId  <- map["OSSAccessKeyId"]
        key     <- map["key"]
        success_action_status     <- map["success_action_status"]
        policy     <- map["policy"]
        signature     <- map["Signature"]
    }
}


extension PostIPARequestMaker {
    func transToMappable() -> PostIPARequestData {
        let data = PostIPARequestData()
        data.host = self.host
        data.oSSAccessKeyId = self.accessKeyId
        data.key = self.objectKey
        data.success_action_status = String(self.success_action_status)
        data.policy = self.policy
        data.signature = self.signature
        return data
    }
}
