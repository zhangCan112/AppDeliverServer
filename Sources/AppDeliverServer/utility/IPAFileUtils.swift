//
//  IPAFileUtils.swift
//  AppDeliverServerPackageDescription
//
//  Created by zhangcan on 2018/2/7.
//

import PerfectXML
import PerfectZip
import PerfectLib

struct IpaInfo {
    let identifier: String
    let displayName: String
    let iconName: String
    let version: String
}

class IPAFileUtils {
    //MARK: 解压ipa文件，并返回info.plist文件路径
   static func unZipFile(sourcePath: String, toPath: String) -> (plistPath: String, error: PerfectError?) {
      let myZip = Zip();
    
      let status = myZip.unzipFile(source: sourcePath, destination: toPath, overwrite: true);
    
      guard status == .ZipSuccess else {
        
          return ("",PerfectError.apiError(status.description));
      }
    
      //解压成功，寻找info.plist
    let d = Dir(toPath)
    if !d.exists {
        return ("",PerfectError.apiError("file path is not exists"));
    }
    
    if let plistPath = FileUtils.findFile(fileName: "Info.plist", inDir: toPath)  {
        return (plistPath, nil);
    }
    
      return ("",PerfectError.apiError("info.plist is not found"))    
    }
    
    
    //MARK: 解析info.plist文件获取需要的字段信息
    static func parseInfoPlistFile(path: String) -> IpaInfo? {
        let file = File(path)
        var rssXML: String = ""
        do {
             rssXML = try file.readString()
        } catch  {
            print(error)
        }
        if let xDoc = XDocument(fromSource: rssXML) {
            let infoDic = xDoc.parseAsPlistFile()
            let ipaInfo = IpaInfo(identifier: infoDic["CFBundleIdentifier"] as? String ?? "未获取到identifier",
                                  displayName: infoDic["CFBundleDisplayName"] as? String ?? "未获取到displayName",
                                  iconName: (((infoDic["CFBundleIcons"] as? Dictionary<String, Any>)?["CFBundlePrimaryIcon"]as? Dictionary<String, Any>)?["CFBundleIconFiles"] as? Array<String> ?? [""]).last ?? "",
                                  version: infoDic["CFBundleVersion"] as? String ?? "未获取到version")
            return ipaInfo
        }
        
        return nil
    }
    
}

extension XDocument {
    func parseAsPlistFile() -> Dictionary<String, Any> {
        let childNodes = self.documentElement?.childNodes.filter({ (node) -> Bool in
            return node.nodeName == "dict"
        })
        if let mainNode = childNodes?.first  {
            return mainNode.parseDictTag()
        }
        return [:]
    }
}

extension XNode {
    func parseDictTag() -> Dictionary<String, Any> {
        guard self.nodeName == "dict" else {
            return [:]
        }
        let childrenNodes = self.childNodes.filter { (child) -> Bool in
            return !child.nodeName.hasPrefix("#")
        }
        var dic = Dictionary<String, Any>()
        for index in 0..<childrenNodes.count {
            let child = childrenNodes[index];
            if (child.nodeName == "key") {
                if let keyValue = child.nodeValue {
                    let valueNode = childrenNodes[index + 1];
                    switch valueNode.nodeName {
                    case "dict":
                        dic[keyValue] = valueNode.parseDictTag()
                    case "array":
                        dic[keyValue] = valueNode.parseArrayTag()
                    case "string":
                        dic[keyValue] = valueNode.parseStringTag()
                    default:
                        break
                    }
                }
            }
        }
        return dic
    }
    
    func parseStringTag() -> String {
       return self.nodeValue ?? ""
    }
    
    func parseArrayTag() -> [Any] {
        guard self.nodeName == "array" else {
            return []
        }
        let childrenNodes = self.childNodes.filter { (child) -> Bool in
            return !child.nodeName.hasPrefix("#")
        }
         var array = [Any]()
        for index in 0..<childrenNodes.count {
            let valueNode = childrenNodes[index];
            switch valueNode.nodeName {
            case "dict":
                array.append(valueNode.parseDictTag())
            case "array":
                array.append(valueNode.parseArrayTag())
            case "string":
                array.append(valueNode.parseStringTag())
            default:
                break
            }
        }
        return array
    }
}



