//
//  FileManager.swift
//  ExternalSortApp
//
//  Created by Jackson  on 12.12.2021.
//

import Foundation

protocol IFileService {
    func delete(file name: String) throws
    func create(file name: String)
    
    func write(string: String, to file: String)
    func read(file name: String) -> String?
    func add(line: String, to fileName: String)
    
    func cleanDirectory()
    
    var rootUrl: URL? { get set }
}

final class FileService: IFileService {
    private let fileManger = FileManager.default
    static let shared = FileService()
    
    var rootUrl: URL?
    
    init() {
        let documentsUrl = fileManger.urls(
            for: .documentDirectory, in: .userDomainMask).first
        self.rootUrl = documentsUrl
    }
    
    // MARK: - Main Actions
    
    func add(line: String, to fileName: String) {
        guard let fileUrl = rootUrl?.appendingPathComponent(fileName) else { return }
        
        do {
            try line.appendLineToURL(fileURL: fileUrl)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func delete(file name: String) throws {
        guard let fileUrl = rootUrl?.appendingPathComponent(name) else {
            throw "File \(name) does not exists."
        }
        if fileManger.fileExists(atPath: fileUrl.path) {
            do {
                try fileManger.removeItem(atPath: fileUrl.path)
            } catch let error {
                throw error
            }
        }
    }
    
    func create(file name: String) {
        guard let fileUrl = rootUrl?.appendingPathComponent(name) else { return }
        if !fileManger.fileExists(atPath: fileUrl.path) {
            let _ = fileManger.createFile(
                atPath: fileUrl.path, contents: nil, attributes: nil)
        }
    }
    
    func write(string: String, to file: String) {
        guard let fileUrl = rootUrl?.appendingPathComponent(file) else { return }
        do {
            try string.write(toFile: fileUrl.path,
                          atomically: false,
                          encoding: .utf8)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func read(file name: String) -> String? {
        guard let fileUrl = rootUrl?.appendingPathComponent(name) else { return nil }
        if fileManger.fileExists(atPath: fileUrl.path) {
            guard let string = fileManger.contents(atPath: fileUrl.path) else {
                return nil
            }
            return String(data: string, encoding: .utf8)
        }
        return nil
    }
    
    func cleanDirectory() {
        guard rootUrl != nil else { return }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: rootUrl!,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)
            
            try fileURLs.forEach {
                try FileManager.default.removeItem(at: $0)
            }
            
        } catch  {
            print(error)
        }
    }
}


