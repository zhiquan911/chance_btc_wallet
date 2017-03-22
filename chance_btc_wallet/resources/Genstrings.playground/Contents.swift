//#!/usr/bin/swift
import Foundation
class GenStrings {
    
    let fileManager = FileManager.default
    //    let acceptedFileExtensions = ["swift", "strings"]
    let excludedFolderNames = ["Carthage"]
    let excludedFileNames = ["genstrings.swift"]
    var regularExpresions = [String:NSRegularExpression]()
    let localizedRegex = "(?<=\")([^\"]*)(?=\".(localized|localizedFormat))|(?<=(Localized|NSLocalizedString)\\(\")([^\"]*?)(?=\")"
    let keyRegex = "(?<=\")([^\"]*)(?=\" =)"
    let pathExtension = "lproj"
    
    //修改为自己的项目文件夹路径
    var projectFilePath = "/Users/maizhiquan/Documents/github/ios/chance_btc_wallet/chance_btc_wallet/chance_btc_wallet/"
    
    var newStrings:String? = String()//最新的语言字符串集
    
    enum GenstringsError:Error {
        case error
    }
    
    ///系统当前时间
    func createNowDate()->String{
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyy-MM-dd HH:mm"
        return timeFormatter.string(from: date) as String
    }
    
    //获取已存在的语言文件
    func getExistLocalizableFile() -> [String] {
        
        //        let fileManager = FileManager.default
        //        let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        
        //获取当前文件根路径/Users/imac/Documents/code/bter_app/resources/
        let  root = URL(string: projectFilePath)!
        print(root.absoluteString)
        
        //获取当前文件根路径的所有子文件路径集合
        print("======= 开始扫描文件夹 =======")
        let allFiles = fetchFilesInFolder(root,
                                          defPathExtension: pathExtension,
                                          acceptedFileExtensions: ["strings"],
                                          acceptedFile: ["Localizable.strings"])
        print("======= 结束扫描文件夹 =======")
        print(allFiles)
        print("资源文件数: \(allFiles.count)")
        //装载文件名
        var localizableStrings = Set<String>()
        
        //遍历文件
        for filePath in allFiles {
            let stringsInFile = keyStringsInFile(filePath)
            //获取所在文件字符串的并集合，即去掉重复的
            localizableStrings = localizableStrings.union(stringsInFile)
        }
        // We sort the strings
        //排序整理字符串，按字母排序
        let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
        
        return sortedStrings
    }
    
    func keyStringsInFile(_ filePath: URL) -> Set<String> {
        
        if let fileContentsData = try? Data(contentsOf: filePath), let fileContentsString = NSString(data: fileContentsData, encoding: String.Encoding.utf8.rawValue) {
            do {
                let localizedStringsArray = try regexMatches(keyRegex, string: fileContentsString as String).map({fileContentsString.substring(with: $0.range)})
                
                return Set(localizedStringsArray)
            } catch {}
        }
        return Set<String>()
    }
    
    
    //把最新最新的语言字符串写到本地.Strings文件中
    func writeToLocalizableStringsInFile() ->Void{
        /// 没有新增最新的语言字符串停止执行
        if newStrings!.isEmpty{
            print("没有新字符串需要写入")
            return
        }
        
        let  root = URL(string: projectFilePath)!
        
        //获取当前文件根路径的所有子文件路径集合
        let allFiles = fetchFilesInFolder(root,
                                          defPathExtension: pathExtension,
                                          acceptedFileExtensions: ["strings"],
                                          acceptedFile: ["Localizable.strings"])
        
        //遍历文件
        for filePath in allFiles {
            
            let fileHandle = try! FileHandle(forUpdating: filePath)
            fileHandle.seekToEndOfFile()
            
            //写入时间
            let date = "\n/******** 新增于: " + createNowDate() + " ********/\n"
            let stringDate = date.data(using: String.Encoding.utf8)
            fileHandle.write(stringDate!)
            
            //写入最新的语言字符串
            let stringData = newStrings!.data(using: String.Encoding.utf8)
            fileHandle.write(stringData!)
            fileHandle.closeFile()
            print("写入新数据到\(filePath.absoluteString)————成功")
        }
    }
    
    // Performs the genstrings functionality
    func perform1() {
        //        let fileManager = FileManager.default
        //        let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        
        //获取当前文件根路径/Users/imac/Documents/code/bter_app/resources/
        let  root = URL(string: projectFilePath)!
        print(root.absoluteString)
        //获取当前文件根路径的所有子文件路径集合
        print("======= 开始扫描文件夹 =======")
        let allFiles = fetchFilesInFolder(root)
        print("======= 结束扫描文件夹 =======")
        
        // We use a set to avoid duplicates
        //装载文件名
        var localizableStrings = Set<String>()
        
        //遍历文件
        for filePath in allFiles {
            let stringsInFile = localizableStringsInFile(filePath)
            //获取所在文件字符串的并集合，即去掉重复的
            localizableStrings = localizableStrings.union(stringsInFile)
        }
        
        //获取已存在的语言文本数组
        let existStrings = getExistLocalizableFile()
        
        // We sort the strings
        //排序整理字符串，按字母排序
        let sortedStrings = localizableStrings.sorted(by: { $0 < $1 })
        
        for string in sortedStrings {
            //            print(string)
            //            print(sortedStrings.count)
            //            print(existStrings.count)
            if existStrings.contains(string) {
                continue
            }
            newStrings!.append("\"\(string)\" = \"\(string)\";\n")
            
        }
        //打印
        print(newStrings!)
        //追加把最新最新的语言字符串写到本地
        writeToLocalizableStringsInFile()
    }
    
    // Applies regex to a file at filePath.
    func localizableStringsInFile(_ filePath: URL) -> Set<String> {
        if let fileContentsData = try? Data(contentsOf: filePath), let fileContentsString = NSString(data: fileContentsData, encoding: String.Encoding.utf8.rawValue) {
            do {
                let localizedStringsArray = try regexMatches(localizedRegex, string: fileContentsString as String).map({fileContentsString.substring(with: $0.range)})
                return Set(localizedStringsArray)
            } catch {}
        }
        return Set<String>()
    }
    
    //MARK: Regex
    
    func regexWithPattern(_ pattern: String) throws -> NSRegularExpression {
        var safeRegex = regularExpresions
        if let regex = safeRegex[pattern] {
            return regex
        }
        else {
            do {
                let currentPattern: NSRegularExpression
                currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpression.Options.caseInsensitive)
                safeRegex.updateValue(currentPattern, forKey: pattern)
                self.regularExpresions = safeRegex
                return currentPattern
            }
            catch {
                throw GenstringsError.error
            }
        }
    }
    
    func regexMatches(_ pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString = string
            let currentPattern =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = internalString as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = currentPattern.matches(in: internalString, options: [], range: stringRange)
            return matches
        }
        catch {
            throw GenstringsError.error
        }
    }
    
    //MARK: File manager
    
    func fetchFilesInFolder(_ rootPath: URL,
                            defPathExtension: String = "",
                            acceptedFileExtensions: [String] = ["swift", "strings"],
                            acceptedFile: [String]? = nil) -> [URL] {
        
        var files = [URL]()
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: rootPath, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            for urlPath in directoryContents {
                let stringPath = urlPath.path
                let lastPathComponent = urlPath.lastPathComponent
                let pathExtension = urlPath.pathExtension
                var isDir : ObjCBool = false
                
                if fileManager.fileExists(atPath: stringPath, isDirectory:&isDir) {
                    if isDir.boolValue {
                        if !excludedFolderNames.contains(lastPathComponent) && defPathExtension == urlPath.pathExtension {
                            
                            let dirFiles = fetchFilesInFolder(urlPath, defPathExtension: defPathExtension, acceptedFileExtensions: acceptedFileExtensions, acceptedFile: acceptedFile)
                            files.append(contentsOf: dirFiles)
                        }
                    } else {
                        if acceptedFileExtensions.contains(pathExtension) && !excludedFileNames.contains(lastPathComponent) {
                            if acceptedFile != nil {
                                if acceptedFile!.contains(lastPathComponent) {
                                    files.append(urlPath)
                                }
                            } else {
                                files.append(urlPath)
                            }
                        }
                    }
                }
                
            }
        } catch {}
        
        return files
    }
}
let genStrings = GenStrings()

genStrings.perform1()



