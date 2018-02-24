//
//  Filters.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation
import PerfectHTTPServer
import PerfectHTTP




func getViewAllRequestFilter(data: [String:Any]) throws -> HTTPRequestFilter {
    
    struct ViewAllRequest: HTTPRequestFilter {
        func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
            print("收到请求==>Uri:\(request.uri);Method:\(request.method.description)")            
            callback(.continue(request, response))
        }
    }
    return ViewAllRequest()
}


func filters() -> [[String: Any]] {
    return [
        [
            "type":"response",
            "priority":"high",
            "name":PerfectHTTPServer.HTTPFilter.contentCompression,
            ],
        [
            "type":"request",
            "priority":"high",
            "name": getViewAllRequestFilter,
            ]
    ];
}
