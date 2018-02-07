//
//  FileUploadHandler.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation
import PerfectHTTP
import PerfectLib
import PerfectZip

extension Handlers {
    static func fileUpload(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            if let method = data["method"] as? String, method == "post" {
                do {
                    try FileUploadHander.post(data: data)(request, response);
                } catch  {
                    print(error);
                }
            }
            
            do {
                try FileUploadHander.get(data: data)(request, response);
            } catch  {
                print(error);
            }
            
            response.completed()
        }
    }
}

private class FileUploadHander {
    static func post(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            // Process only if request.postFileUploads is populated
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // iterate through the file uploads.
                for upload in uploads {
                    // move file                    
                    let thisFile = File(upload.tmpFileName)
                    do {
                        let _ = try thisFile.moveTo(path: "./webroot/uploads/\(upload.fileName)", overWrite: true)
                        let plistPath = IPAFileUtils.unZipFile(sourcePath: "./webroot/uploads/\(upload.fileName)", toPath: "./webroot/uploads/\(upload.fileName)2").plistPath;
                        IPAFileUtils.parseInfoPlistFile(path: plistPath);
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    static func get(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            // Context variable, which also initializes the "files" array
            var context = ["files":[[String:String]]()]
            // Inspect the uploads directory contents
            let d = Dir("./webroot/uploads")
            if !d.exists {
                do {
                    try d.create();
                } catch {
                    print(error);
                }
            }
            do{
                try d.forEachEntry(closure: {f in
                    context["files"]?.append(["name":f])
                })
            } catch {
                print(error)
            }
            
            // Render the Mustache template, with context.
            response.render(template: "templates/index", context: context)
        }
    }
}
