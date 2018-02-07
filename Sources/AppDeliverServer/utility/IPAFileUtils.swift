//
//  IPAFileUtils.swift
//  AppDeliverServerPackageDescription
//
//  Created by zhangcan on 2018/2/7.
//

import Foundation
import PerfectXML
import PerfectZip
import PerfectLib


class IPAFileUtils {
    //MARK: 解压ipa文件，并返回info.plist文件路径
   static func unZipFile(sourcePath: String, toPath: String) -> (plistPath: String, error: NSError?) {
      let myZip = Zip();
    
      let status = myZip.unzipFile(source: sourcePath, destination: toPath, overwrite: true);
    
      guard status == .ZipSuccess else {
          return ("",NSError.init(domain: status.description, code: -1, userInfo: nil));
      }
    
      //解压成功，寻找info.plist
    let d = Dir(toPath)
    if !d.exists {
        return ("",NSError.init(domain: "file path is not exists", code: -1, userInfo: nil));
    }
    
    if let plistPath = FileUtils.findFile(fileName: "Info.plist", inDir: toPath)  {
        return (plistPath, nil);
    }
    
      return ("",NSError.init(domain: "info.plist is not found", code: -1, userInfo: nil))    
    }
}



