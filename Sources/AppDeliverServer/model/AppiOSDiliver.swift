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
    var downloadPlistFileUrl: String = ""
    var comment: String?
    var createDate: Date = Date()
    
    override func table() -> String {
        return "iOSDiliver"
    }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as! Int
        name = this.data["name"] as! String
        version = this.data["version"] as! String
        buildID = this.data["buildID"] as! String
        archiveType = this.data["archiveType"] as! Int
        downloadPlistFileUrl = this.data["downloadPlistFileUrl"] as! String
        comment = this.data["comment"] as? String
        createDate = this.data["createDate"] as? Date
    }
    
    func rows() -> [AppiOSDiliver] {
        var rows = [AppiOSDiliver]()
        for i in 0..<self.results.rows.count {
            let row = AppiOSDiliver()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
}
