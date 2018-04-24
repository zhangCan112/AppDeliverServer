//
//  AppiOSDiliver.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/24.
//

import MySQLStORM
import StORM
import SwiftSQL

class AppiOSDiliver: MySQLStORM {
    var id: Int = 0
    var name: String = ""
    var version: String = ""
    var buildID: String = ""
    var archiveType: Int = 0
    var shortUrl: String = ""
    var comment: String = ""
    var createDate: Int = 0
    
    override func table() -> String {
        return "iOSDiliver"
    }
    
    override func to(_ this: StORMRow) {
        
    }
}
