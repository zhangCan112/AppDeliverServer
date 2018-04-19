//
//  InfoPlistHandler.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/19.
//

import PerfectLib
import PerfectHTTP

extension Handlers {
  static var infoPlistHandler: InfoPlistHandler.Type {
        return InfoPlistHandler.self
    }
    
}

class InfoPlistHandler {
    static func post(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            // Process only if request.postFileUploads is populated
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // iterate through the file uploads.
                for upload in uploads {
                    // move file
                    let infoPlistFile = File(upload.tmpFileName)
                    if let info =  IPAFileUtils.parseInfoPlistFile(path: infoPlistFile.path) {
                        if let file = IPAFileUtils.createInstallPropertyList(info: info, toPath: "./webroot/uploads/\(upload.fileName).plist") {
                            let request = PutObjectRequest(file: file, objectName:file.path.components(separatedBy: "/").last ?? "\(upload.fileName).plist")
                            OSSTask.start(request: request, result: { (isSuccess, errormsg) in
                                if isSuccess {
                                    let body = BaseBody.successBody()
                                    response.appendBody(string: body.toJSONString() ?? "")
                                    response.completed()
                                } else {
                                    let body = BaseBody.failedBody(scode: "002", message: "上传文件解析失败！")
                                    response.appendBody(string: body.toJSONString() ?? "")
                                    response.completed()
                                }
                            })
                        } else {
                            let body = BaseBody.failedBody(scode: "002", message: "上传文件解析失败！")
                            response.appendBody(string: body.toJSONString() ?? "")
                            response.completed()
                        }
                    } else {
                        let body = BaseBody.failedBody(scode: "001", message: "上传文件不存在！")
                        response.appendBody(string: body.toJSONString() ?? "")
                        response.completed()
                    }
                }
            } else {
                let body = BaseBody.failedBody(scode: "001", message: "上传文件不存在！")
                response.appendBody(string: body.toJSONString() ?? "")
                response.completed()
            }
        }
    }
}
