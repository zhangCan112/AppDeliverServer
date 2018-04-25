//
//  AppUrlModel.swift
//  AppDeliverServer
//
//  Created by 张爷 on 2018/4/26.
//

import ObjectMapper

class AppUrlModel: Mappable {
    var url = ""
    
    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
        url    <- map["url"]
    }
}
