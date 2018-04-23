//
//  BaseBody.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/19.
//


import ObjectMapper


class EmptyData: Mappable {
    required init?(map: Map) {
        
    }
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
    }
}

class BaseBody<T: Mappable>: Mappable {
    var scode = "0"
    var message = "success"
    var data: T?
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
        scode    <- map["scode"]
        message  <- map["message"]
        data     <- map["data"]
    }
}

func successBody<T: Mappable>(sucessData: T) -> BaseBody<T> {
    let body = BaseBody<T>()
    body.data = sucessData;
    return body;
}

func failedBody(scode: String, message: String) -> BaseBody<EmptyData> {
    let body = BaseBody<EmptyData>()
    body.scode = scode
    body.message = message;
    return body;
}


