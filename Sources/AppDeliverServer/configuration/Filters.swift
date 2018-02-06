//
//  Filters.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation
import PerfectHTTPServer

func filters() -> [[String: Any]] {
    return [
        [
            "type":"response",
            "priority":"high",
            "name":PerfectHTTPServer.HTTPFilter.contentCompression,
            ]
    ];
}
