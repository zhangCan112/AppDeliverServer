//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectXML


// Configuration data for an example server.
// This example configuration shows how to launch a server
// using a configuration dictionary.


var confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
            "name":"localhost",
            "address":"localhost",
            "port":8181,
			"routes":[],
			"filters":[],
//            "tlsConfig":["certPath":"./server.crt", "keyPath":"./server.key"]
		]
	]
]

///loadConfig
confData["servers"]?[0].merge(config(), uniquingKeysWith: { (_, new) in new});
///loadFilters
confData["servers"]?[0]["filters"] = filters();
///loadRoutes
confData["servers"]?[0]["routes"] = routes();

do {
    initConfig()
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}

