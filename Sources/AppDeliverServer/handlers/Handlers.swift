//
//  Handlers.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation
import PerfectHTTP


class Handlers {
    static func main(data: [String:Any]) throws -> RequestHandler {
        return { request, response in
            // Respond with a simple message.
            response.setHeader(.contentType, value: "text/html")
            response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world123!</body></html>")
            // Ensure that response.completed() is called when your processing is done.            
            response.next()
        }
    }
}
