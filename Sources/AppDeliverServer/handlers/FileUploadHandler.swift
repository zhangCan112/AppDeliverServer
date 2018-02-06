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
            
            // Context variable, which also initializes the "files" array
            var context = ["files":[[String:String]]()]
            
            // Process only if request.postFileUploads is populated
            if let uploads = request.postFileUploads, uploads.count > 0 {
                
                // iterate through the file uploads.
                for upload in uploads {
                    // move file
                    let thisFile = File(upload.tmpFileName)
                    do {
                        let _ = try thisFile.moveTo(path: "./webroot/uploads/\(upload.fileName)", overWrite: true)                        
                    } catch {
                        print(error)
                    }
                }
            }
            
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
            response.completed()
        }
    }
}
