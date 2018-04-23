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
    let displayName: String
    let identifier: String
    let iconName: String
    let version: String
    var url: String = ""
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
            file.close()
        } catch  {
            print(error)
        }
        if let xDoc = XDocument(fromSource: rssXML) {
            let infoDic = xDoc.parseAsPlistFile()
            let ipaInfo = IpaInfo(displayName: infoDic["CFBundleDisplayName"] as? String ?? "未获取到displayName",
                                  identifier: infoDic["CFBundleIdentifier"] as? String ?? "未获取到identifier",
                                  iconName: (((infoDic["CFBundleIcons"] as? Dictionary<String, Any>)?["CFBundlePrimaryIcon"]as? Dictionary<String, Any>)?["CFBundleIconFiles"] as? Array<String> ?? [""]).last ?? "",
                                  version: infoDic["CFBundleVersion"] as? String ?? "未获取到version",
                                  url: "")
            return ipaInfo
        }
        return nil
    }
    
    
    
    //MARK: 根据IpaInfo生成下载ipa的配置plist文件到指定路径
    static func createInstallPropertyList(info: IpaInfo, toPath: String) -> File? {
        let temFile = File("./webroot/templates/ipadownload.swift")
        do {
            var temString = try temFile.readString()
            temString = temString
                .stringByReplacing(string: "{IPAURL}", withString: info.url)
                .stringByReplacing(string: "{IPAID}", withString: info.identifier)
                .stringByReplacing(string: "{IPAVER}", withString: info.version)
                .stringByReplacing(string: "{IPATITLE}", withString: info.displayName)
            let newFile = File(toPath)
            try newFile.open(.readWrite)
            try newFile.write(string: temString)
            newFile.close()
            return newFile
        } catch {
            return nil;
        }        
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



