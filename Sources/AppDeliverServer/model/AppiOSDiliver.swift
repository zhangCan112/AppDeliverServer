//
//  AppiOSDiliver.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/24.
//

import Foundation
import MySQLStORM
import StORM

class AppiOSDiliver: MySQLStORM {
    var id: Int = 0
    var name: String = ""
    var version: String = ""
    var buildID: String = ""
    var archiveType: Int = 0
    var downloadPlistFileUrl: String = ""
    var comment: String?
    fileprivate var createTime = "NULL"
    var createDate: Date? {
        get{
            return createTime == "NULL" ? nil : getDate(fromSQLDateTime: createTime)
        }
        set{
            createTime = "NULL"
            if let date = newValue {
                createTime = date.sqlDateTime()
            }
        }
    }
    
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
        createTime = this.data["createTime"] as! String
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
