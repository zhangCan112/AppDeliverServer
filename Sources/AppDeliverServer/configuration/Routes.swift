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
    
    //App下载链接地址
    routes.append(["method": "get",
                   "uri":"/ios/appurl",
                   "handler":Handlers.iOS.appUrl.get])
    
    //infoplist文件
    routes.append(["method": "post",
                   "uri":"/iOS/infoPlist",
                   "handler":Handlers.iOS.infoPlist.post])
    
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
    //文件下载
    routes.append(["method": "get",
                   "uri":"/fileDownload",
                   "handler":Handlers.fileDownload])
    routes.append(["method": "get",
                   "uri":"/fileDownloadApp",
                   "handler":Handlers.fileDownloadApp])
    
    return routes;
}
