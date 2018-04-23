//
//  InfoPlistHandler.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/19.
//

import PerfectLib
import PerfectHTTP
import PerfectThread

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
                    let body = failedBody(scode: "001", message: "上传文件不存在！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
            }            
            // iterate through the file uploads.
            for upload in uploads {
                let infoPlistFile = File(upload.tmpFileName)
                guard var info =  IPAFileUtils.parseInfoPlistFile(path: infoPlistFile.path) else {
                    let body = failedBody(scode: "001", message: "上传文件不存在！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
                }
                let ipaReqMaker = PostIPARequestMaker(ipaInfo: info, uuid: UUID().string)
                info.url = ipaReqMaker.downloadUrl
                guard let file = IPAFileUtils.createInstallPropertyList(info: info, toPath: "./webroot/uploads/\(upload.fileName)") else {
                    let body = failedBody(scode: "002", message: "上传文件解析失败！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
                }
                let request = PutObjectRequest(file:file,
                                               objectName:file.path.components(separatedBy: "/").last ?? "\(upload.fileName)")
                
                do {
                    let _ = try  OSSTask.start(request: request).then(closure: { (_) -> Void in
                        let body = successBody(sucessData: ipaReqMaker.transToMappable())
                        print(body.toJSONString() ?? "")
                        response.appendBody(string: body.toJSONString() ?? "")
                        response.completed()
                        file.delete()
                    }).wait()
                } catch let error {
                    var body = failedBody(scode: "402", message: "网络请求失败！")
                    if let error = error as? OSSTask.Error {
                        body = failedBody(scode: String(error.code), message: error.description)
                    }
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()                    
                }
            }
        }
    }
}
