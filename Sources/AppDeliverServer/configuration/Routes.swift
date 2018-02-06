//
//  Routes.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation
import PerfectHTTPServer

func routes() -> [[String: Any]] {
    var routes: [[String: Any]] = [[String: Any]]()
    
    //默认主接口
    routes.append(["method": "get",
                   "uri":"/",
                   "handler":Handlers.main])
    
    //文件上传
    routes.append(["method": "get",
                   "uri":"/fileUpload",
                   "handler":Handlers.fileUpload])
    
    routes.append(["method": "post",
                   "uri":"/fileUpload",
                   "handler":Handlers.fileUpload])
    
    routes.append(["method": "get",
                   "uri": "/**",
                   "handler": PerfectHTTPServer.HTTPHandler.staticFiles,
                   "documentRoot": "./webroot",
                   "allowResponseFilters": true])
    return routes;
}
