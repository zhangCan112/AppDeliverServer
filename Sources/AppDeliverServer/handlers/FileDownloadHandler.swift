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
            response.setHeader(.contentDisposition, value: "attachment; filename=\"ingage.ipa\"")
            let file = File.init("\(request.documentRoot)/uploads/ingage.ipa")
            response.appendBody(string: try! file.readString())
            response.completed()
        }
    }
}
