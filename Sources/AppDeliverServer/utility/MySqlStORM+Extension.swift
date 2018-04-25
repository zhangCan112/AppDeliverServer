//
//  MySqlStORM-Extension.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/4/25.
//

import Foundation
import MySQLStORM
import StORM
import PerfectThread

extension MySQLStORM {
    func saveToDB() -> Promise<Bool> {
        return Promise(closure: { (prom) in
            do {
               try self.save()
               prom.set(true)
            } catch {
               prom.fail(StORMError.error("save To DB Failed！"))
            }
        })
    }
}

