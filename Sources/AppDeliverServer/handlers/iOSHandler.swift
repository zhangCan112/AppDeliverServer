//
//  InfoPlistHandler.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/19.
//

import PerfectLib
import PerfectHTTP
import PerfectThread
import StORM
import Foundation

extension Handlers {
    static var iOS: iOSCategory.Type {
        return iOSCategory.self
    }
}

struct iOSCategory {
    static var infoPlist: infoPlistHandler.Type {
        return infoPlistHandler.self
    }
    
    static var appUrl: appUrlHandler.Type {
        return appUrlHandler.self
    }
}

struct infoPlistHandler {
    
    static func post(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            // Process only if request.postFileUploads is populated
            guard let uploads = request.postFileUploads, uploads.count > 0 else {
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
                let uuid = UUID().string
                let ipaReqMaker = PostIPARequestMaker(ipaInfo: info, uuid: uuid)
                info.url = ipaReqMaker.downloadUrl
                guard let file = IPAFileUtils.createInstallPropertyList(info: info, toPath: "./webroot/uploads/\(upload.fileName)") else {
                    let body = failedBody(scode: "002", message: "上传文件解析失败！")
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
                    return
                }
                let objectName = file.path.components(separatedBy: "/").last ?? "\(upload.fileName)"
                let request = PutObjectRequest(file:file,
                                               objectName:"plist/\(uuid)-\(objectName)")
                
                do {
                    let _ = try  OSSTask.start(request: request)
                        .then(closure: { (_) -> Bool in
                            let deliver = AppiOSDiliver()
                            deliver.name = info.displayName
                            deliver.buildID = info.identifier
                            deliver.version = info.version
                            deliver.downloadPlistFileUrl = request.url
                            deliver.createDate = Date()
                            return  try deliver.saveToDB().wait()!
                        })
                        .then(closure: { (isSuccess) -> Void in
                            try _ = isSuccess()
                            let body = successBody(sucessData: ipaReqMaker.transToMappable())
                            response.appendBody(string: body.toJSONString() ?? "")
                            response.completed()
                            file.delete()
                        })
                        .wait()
                } catch let error as StORMError {
                    let body = failedBody(scode: "100", message: error.string())
                    response.appendBody(string: body.toJSONString() ?? "")
                    response.completed()
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

struct appUrlHandler {
    static func get(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            
            do {
                let obj = AppiOSDiliver()
                let thisCursor = StORMCursor(
                    limit: 1,
                    offset: 0
                )
                try obj.select(whereclause: "1", params: [], orderby: ["createTimeStamp DESC"], cursor: thisCursor)
                let dataModel = AppUrlModel()
                if let data = obj.results.rows.first  {
                    obj.to(data)
                    dataModel.url = "itms-services://?action=download-manifest&url=" + obj.downloadPlistFileUrl
                    let body = successBody(sucessData: dataModel)
                    response.appendBody(string: body.toJSONString() ?? "")
                }
                response.completed()
            } catch {
                let body = failedBody(scode:"100" , message: error.localizedDescription)
                response.appendBody(string: body.toJSONString() ?? "")
                response.completed()
            }
        }
    }
}
