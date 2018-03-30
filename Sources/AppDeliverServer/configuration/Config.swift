//
//   Config.swift
//  PerfectTemplate
//
//  Created by zhangcan on 2018/2/6.
//

import Foundation

func config() -> [String: Any] {
    return [
        "name":"localhost",
        "address":"192.168.1.104",
        "port":8181,
    ]
}

func aliyunAccessKeyInfo() -> (accessKeyId: String, accessKeySecret: String) {
    let accessKeyId = "LTAIP46PMViRaQCJ"
    let accessKeySecret = "T4eDGknsW2PBbDpQ9tcqTEks42tahs"
    return (accessKeyId, accessKeySecret)
}
