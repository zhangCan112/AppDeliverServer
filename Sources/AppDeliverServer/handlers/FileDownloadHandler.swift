//
//  FileDownloadHandler.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/2/8.
//

import PerfectLib
import PerfectHTTP

extension Handlers {
    static func fileDownload(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            response.setHeader(.contentType, value: "application/force-download")
            response.setHeader(.contentDisposition, value: "attachment; filename=\"ingage.plist\"")
            let file = File.init("\(request.documentRoot)/uploads/ingage.plist")
            response.appendBody(string: try! file.readString())
            response.completed()
        }
    }
    
    static func fileDownloadApp(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            response.setHeader(.contentType, value: "application/force-download")
            response.setHeader(.contentDisposition, value: "attachment; filename=\"ingage.ipa\"")
            let file = File.init("\(request.documentRoot)/uploads/ingage.ipa")
            response.appendBody(string: try! file.readString())
            response.completed()
        }
    }
}
