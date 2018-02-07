//
//  FileUtils.swift
//  AppDeliverServer
//
//  Created by zhangcan on 2018/2/7.
//

import Foundation
import PerfectLib


class FileUtils {
    //MARK: 在指定路径文件夹下查找文件，并返回文件路径
    static func findFile(fileName: String, inDir dirPath: String) -> String? {
        let dir = Dir(dirPath);
        guard dir.exists == true else {
            return nil;
        }
        return findFile_private(fileName:fileName, inDir:dirPath);
    }
}

//浅层优先查询指定文件名
private func findFile_private(fileName: String, inDir dirPath: String) -> String? {
    let dirFile = File(dirPath);
    if dirFile.isDir {
        let dir = Dir(dirFile.path);
        var subPaths = Array<String>();
        var findFileName: String? = nil;
        do {
            try dir.forEachEntry(closure: { (path) in
                let newDirPath = dirPath.hasSuffix("/") ? "\(dirPath)\(path)" : "\(dirPath)/\(path)"
                let pathFile = File(newDirPath);
                if pathFile.isDir == true {
                 subPaths.append(path)
                } else if path == fileName {
                    findFileName = path;
                }
            })
        } catch {
            print(error);
        }
        
        if let findFile = findFileName {
            return dirPath.hasSuffix("/") ? "\(dirPath)\(findFile)" : "\(dirPath)/\(findFile)"
        }
        
        for path in subPaths {
            let newDirPath = dirPath.hasSuffix("/") ? "\(dirPath)\(path)" : "\(dirPath)/\(path)"
            if let filePath = findFile_private(fileName: fileName, inDir: newDirPath) {
                return filePath;
            }
        }
        
    } else {
        if let finedFileName = dirPath.split(separator: "/").last, finedFileName == fileName {
            return dirPath;
        }
    }
    
    return nil;
}
