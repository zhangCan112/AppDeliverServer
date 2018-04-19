//
//  BaseBody.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/19.
//


import ObjectMapper

class BaseBody: Mappable {
    var scode = "0"
    var message = "success"
    var data: Mappable?
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    
   static func successBody() -> BaseBody {
        let body = BaseBody()
        return body;
    }
    static func failedBody(scode: String, message: String) -> BaseBody {
        let body = BaseBody()
        body.scode = scode
        body.message = message;
        return body;
    }
    
    // Mappable
    func mapping(map: Map) {
        scode    <- map["scode"]
        message  <- map["message"]
        data     <- map["data"]
    }
}


