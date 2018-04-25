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
    var id: UInt32 = 0
    var name: String = ""
    var version: String = ""
    var buildID: String = ""
    var archiveType: Int32 = 0
    var downloadPlistFileUrl: String = ""
    var comment: String?
    fileprivate var createTimeStamp: Int64 = 0
    var createDate: Date? {
        get{
            return createTimeStamp == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(createTimeStamp))
        }
        set{
            createTimeStamp = 0
            if let date = newValue {
                createTimeStamp = Int64(date.timeIntervalSince1970)
            }
        }
    }
    
    override func table() -> String {
        return "iOSDiliver"
    }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as! UInt32
        name = this.data["name"] as! String
        version = this.data["version"] as! String
        buildID = this.data["buildID"] as! String
        archiveType = this.data["archiveType"] as! Int32
        downloadPlistFileUrl = this.data["downloadPlistFileUrl"] as! String
        comment = this.data["comment"] as? String
        createTimeStamp = this.data["createTimeStamp"] as! Int64
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
