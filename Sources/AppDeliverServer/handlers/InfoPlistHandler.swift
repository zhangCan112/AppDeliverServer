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
            guard let uploads = request.postFileUploads, uploads.count > 0
                else {
                    let body = BaseBody.failedBody(scode: "001", message: "上传文件不存在！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
            }
            // iterate through the file uploads.
            for upload in uploads {
                let infoPlistFile = File(upload.tmpFileName)
                guard let info =  IPAFileUtils.parseInfoPlistFile(path: infoPlistFile.path) else {
                    let body = BaseBody.failedBody(scode: "001", message: "上传文件不存在！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
                }
                guard let file = IPAFileUtils.createInstallPropertyList(info: info, toPath: "./webroot/uploads/\(upload.fileName).plist") else {
                    let body = BaseBody.failedBody(scode: "002", message: "上传文件解析失败！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
                }
                let request = PutObjectRequest(file:file,
                                               objectName:file.path.components(separatedBy: "/").last ?? "\(upload.fileName).plist")
                
                do {
                    let _ = try  OSSTask.start(request: request).then(closure: { (_) -> Void in
                        let body = BaseBody.successBody()
                        response.appendBody(string: body.toJSONString() ?? "")
                        response.completed()
                    }).when(closure: { (error) in
                        var body: BaseBody
                        if let error = error as? OSSTask.Error {
                            body = BaseBody.failedBody(scode: String(error.code), message: error.description)
                        } else {
                            body = BaseBody.failedBody(scode: "402", message: "网络请求失败！")
                        }
                        response.appendBody(string: body.toJSONString() ?? "")
                        response.completed()
                    }).wait()
                } catch {
                    let body = BaseBody.failedBody(scode: "404", message: "上传文件请求报错！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                }
            }
        }
    }
}
