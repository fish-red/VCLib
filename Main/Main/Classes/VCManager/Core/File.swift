//
//  File.swift
//  Main
//
//  Created by 陈文强 on 16/10/12.
//  Copyright © 2016年 CWQ. All rights reserved.
//

import Foundation

// MARK: - 沙盒目录相关(Standard)
public class File {
    public class func homeDir() -> String {
        return NSHomeDirectory()
    }
    
    public class func documentsDir() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    public class func libraryDir() -> String? {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last
    }
    
    public class func preferencesDir() -> String? {
        let library = libraryDir()
        guard library?.characters.count > 0 else {
            return nil
        }
        return library! + "/Preferences"
    }
    
    public class func cachesDir() -> String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    public class func tmpDir() -> String {
        return NSTemporaryDirectory()
    }
}


// MARK: - 遍历文件夹(Enumerate)
extension File {
    
    public class func listFilesInHomeDirectory(byDeep: Bool) -> [String]? {
        return listFilesInDirectory(atPath: homeDir(), deep: byDeep)
    }
    
    public class func listFilesInDocumentDirectory(byDeep: Bool) -> [String]? {
        return listFilesInDirectory(atPath: documentsDir(), deep: byDeep)
    }
    
    public class func listFilesInLibraryDirectory(byDeep: Bool) -> [String]? {
        return listFilesInDirectory(atPath: libraryDir(), deep: byDeep)
    }
    
    public class func listFilesInCacheDirectory(byDeep: Bool) -> [String]? {
        return listFilesInDirectory(atPath: cachesDir(), deep: byDeep)
    }
    
    public class func listFilesInTmpDirectory(byDeep: Bool) -> [String]? {
        return listFilesInDirectory(atPath: tmpDir(), deep: byDeep)
    }
    
    public class func listFilesInDirectory(atPath: String?, deep: Bool) -> [String]? {
        guard atPath?.characters.count > 0 else {
            return nil
        }
        
        var list: [String]? = nil
        let mgr = FileManager.default
        
        do {
            if deep == true {
                list = try mgr.subpathsOfDirectory(atPath: atPath!)
            }else {
                list = try mgr.contentsOfDirectory(atPath: atPath!)
            }
        } catch {
            debugPrint("list of directory fail")
        }
        
        return list
    }
}


// MARK: - 文件时间(Date)
extension File {
    public class func creationDate(ofPath: String?) -> NSDate? {
        let date = attibutesOfItem(atPath: ofPath, forKey: .creationDate)
        return date as? NSDate
    }
    
    public class func modificationDate(ofPath: String?) -> NSDate? {
        let date = attibutesOfItem(atPath: ofPath, forKey: .modificationDate)
        return date as? NSDate
    }
}


// MARK: - 创建文件夹(Create)
extension File {
    public class func createDirectory(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        
        let mgr = FileManager.default
        do {
            try mgr.createDirectory(atPath: atPath!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        return true
    }
    
    public class func createFile(atPath: String?, content: Data? = nil, overWrite: Bool = true) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        
        let mgr = FileManager.default
        
        // 先判断文件夹存在
        let exist = isExists(atPath: atPath)
        if exist == false {
            // 创建文件夹
            let directoryPath = directory(atPath: atPath!)
            guard createDirectory(atPath: directoryPath) == true else {
                return false
            }
        }
        
        if overWrite == false {
            return exist
        }
        
        var success = mgr.createFile(atPath: atPath!, contents: content, attributes: nil)
        if success == true && content != nil {
            success = writeFile(atPath: atPath, content: NSData(data: content!))
        }
        return success
    }
    
    public class func writeFile(atPath: String?, content: NSData?) -> Bool {
        guard content != nil && atPath?.characters.count > 0 else {
            return false
        }
        
        return content!.write(toFile: atPath!, atomically: true)
    }
}


// MARK: - 删除文件夹(Delete)
extension File {
    public class func removeItem(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(atPath: atPath!)
        } catch {
            return false
        }
        return true
    }
    
    public class func clearCachesDirectory() -> Bool {
        let subFiles = listFilesInCacheDirectory(byDeep: false)
        var success = true
        
        _ = subFiles?.map({ (file) -> Void in
            let path = cachesDir()?.appending("/" + file)
            if removeItem(atPath: path) == false {
                success = false
            }
        })
        return success
    }
    
    public class func clearTmpDirectory() -> Bool {
        let subFiles = listFilesInTmpDirectory(byDeep: false)
        var success = true
        
        _ = subFiles?.map({ (file) -> Void in
            let path = tmpDir().appending("/" + file)
            if removeItem(atPath: path) == false {
                success = false
            }
        })
        return success
    }
}


// MARK: - 复制文件(Copy)
extension File {
    public class func copyItem(fromPath: String?, toPath: String?, overWrite: Bool = false) -> Bool {
        guard fromPath?.characters.count > 0 && toPath?.characters.count > 0 else {
            return false
        }
        
        guard isExists(atPath: fromPath) == true else {
            return false
        }
        
        let toDirPath = directory(atPath: toPath!)
        if isExists(atPath: toDirPath) == false {
            // 创建文件夹
            guard createDirectory(atPath: toDirPath) == true else {
                return false
            }
        }
        
        if overWrite == true && isExists(atPath: toPath) == true {
            // delete first
            guard removeItem(atPath: toPath) == true else {
                return false
            }
        }
        
        // copy 
        do {
            try FileManager.default.copyItem(atPath: fromPath!, toPath: toPath!)
        }catch {
            return false
        }
        return true
    }
}


// MARK: - 移动文件夹(Move)
extension File {
    public class func moveItem(fromPath: String?, toPath: String?, overWrite: Bool = false) -> Bool {
        guard fromPath?.characters.count > 0 && toPath?.characters.count > 0 else {
            return false
        }
        
        guard isExists(atPath: fromPath) == true else {
            return false
        }
        
        let toDirPath = directory(atPath: toPath)
        if isExists(atPath: toDirPath) == false {
            guard createDirectory(atPath: toDirPath) == true else {
                return false
            }
        }
        
        if isExists(atPath: toPath) == true {
            if overWrite == true {
                _ = removeItem(atPath: toPath!)
            }else {
                return removeItem(atPath: fromPath!)
            }
        }
        
        do {
            try FileManager.default.moveItem(atPath: fromPath!, toPath: toPath!)
        }catch {
            return false
        }
        return true
    }
}


// MARK: - 根据Path获取文件名(File name)
extension File {
    public class func fileName(atPath: String?, withSuffix: Bool = false) -> String? {
        guard atPath?.characters.count > 0 else {
            return nil
        }
        
        var fileName = NSString(string: atPath!).lastPathComponent
        if withSuffix == false {
            fileName = NSString(string: fileName).deletingPathExtension
        }
        return fileName
    }
    
    public class func directory(atPath: String?) -> String? {
        guard atPath?.characters.count > 0 else {
            return nil
        }
        return NSString(string: atPath!).deletingLastPathComponent
    }
    
    public class func suffix(atPath: String?) -> String? {
        guard atPath?.characters.count > 0 else {
            return nil
        }
        return NSString(string: atPath!).pathExtension
    }
}


// MARK: - 判断文件是否存在(Exist)
extension File {
    public class func isExists(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        return FileManager.default.fileExists(atPath: atPath!)
    }
    
    public class func isEmptyItem(atPath: String?) -> Bool {
        return (isFile(atPath: atPath) == true && sizeOfItem(atPath: atPath) == 0) || (isDirectory(atPath: atPath) == true && listFilesInDirectory(atPath: atPath, deep: false)?.count == 0)
    }
    
    public class func isDirectory(atPath: String?) -> Bool {
        if let t = attibutesOfItem(atPath: atPath, forKey: .type) as? String {
            let type = FileAttributeType(rawValue: t)
            return type == FileAttributeType.typeDirectory
        }
        return false
    }
    
    public class func isFile(atPath: String?) -> Bool {
        if let t = attibutesOfItem(atPath: atPath, forKey: .type) as? String {
            let type = FileAttributeType(rawValue: t)
            return type == FileAttributeType.typeRegular
        }
        return false
    }
    
    public class func isExecutableItem(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        return FileManager.default.isExecutableFile(atPath: atPath!)
    }
    
    public class func isReadableItem(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        return FileManager.default.isReadableFile(atPath: atPath!)
    }
    
    public class func isWritableItem(atPath: String?) -> Bool {
        guard atPath?.characters.count > 0 else {
            return false
        }
        return FileManager.default.isWritableFile(atPath: atPath!)
    }
}


// MARK: - 获取文件大小(Size)
extension File {
    public class func sizeOfItem(atPath: String?) -> Int64 {
        let s = attibutesOfItem(atPath: atPath, forKey: .size)
        return s as? Int64 ?? -1
    }
    
    public class func sizeOfFile(atPath: String?) -> Int64 {
        return sizeOfItem(atPath: atPath)
    }
    
    public class func sizeOfDirectory(atPath: String?) -> Int64 {
        guard atPath?.characters.count > 0 else {
            return -1
        }
        
        guard isDirectory(atPath: atPath!) == true else {
            return -1
        }
    
        let s = sizeOfItem(atPath: atPath!)
        guard s > 0 else {
            return s
        }
        
        let subPaths = listFilesInDirectory(atPath: atPath, deep: true)
        return subPaths?.reduce(s, { (si, path) -> Int64 in
            let size = sizeOfItem(atPath: path)
            return si + size
        }) ?? -1
    }
    
    public class func sizeOfItem(path: String?) -> String {
        let size = sizeOfItem(atPath: path)
        return sizeFormatted(s: size)
    }
    
    public class func sizeOfFile(path: String?) -> String {
        let size = sizeOfFile(atPath: path)
        return sizeFormatted(s: size)
    }
    
    public class func sizeOfDirectory(path: String?) -> String {
        let size = sizeOfDirectory(atPath: path)
        return sizeFormatted(s: size)
    }
}


// MARK: - 文件属性(Attribute)
extension File {
    public class func attributesOfItem(atPath: String?) -> [FileAttributeKey: Any]? {
        guard atPath?.characters.count > 0 else {
            return nil
        }
        
        let mgr = FileManager.default
        do {
            return try mgr.attributesOfItem(atPath: atPath!)
        } catch {
            
        }
        
        return nil
    }
    
    public class func attibutesOfItem(atPath: String?, forKey: FileAttributeKey) -> Any? {
        let dic = attributesOfItem(atPath: atPath)
        return dic?[forKey]
    }
}


// MARK: - 文件大小格式化(Format)
extension File {
    fileprivate class func sizeFormatted(s: Int64) -> String {
        var size = s
        var factor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB"]
        let value: Int64 = 1024
        
        while size > value {
            size /= value
            factor += 1
        }
        
        let sizeFormat = factor > 1 ? "%4.2d %s" : "%4.0d %s"
        return NSString(format: NSString(string: sizeFormat), s, tokens[factor]).substring(from: 0)
    }
}






