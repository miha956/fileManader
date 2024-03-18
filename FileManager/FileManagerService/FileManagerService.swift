//
//  FileManagerService.swift
//  FileManager
//
//  Created by Миша Вашкевич on 18.03.2024.
//

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    
    var items: [Content] { get set }
    
    func fetchContentsOfDirectory()
    func createDirectory(folderName: String)
    func createFile(image: UIImage, imageName: String)
    func removeContent(atIndex: Int)
    
}

struct Content {

    var url: URL
    var name: String {
        url.lastPathComponent
    }
    var isFolder: Bool?
}

final class FileManagerService: FileManagerServiceProtocol {
    
    var folderUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var items: [Content] = []
    
    init() {
        fetchContentsOfDirectory()
    }
    
    init(folderUrl: URL) {
        self.folderUrl = folderUrl
        fetchContentsOfDirectory()
    }

    func fetchContentsOfDirectory() {

        do {
            let contentUrl = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: [])
            items = []
            for url in contentUrl {
                var item = Content(url: url)
                if url.hasDirectoryPath {
                    item.isFolder = true
                } else {
                    item.isFolder = false
                }
                items.append(item)
            }
        } catch let error {
            print(error)
        }
    }
    
    func createDirectory(folderName: String) {
        do {
            try FileManager.default.createDirectory(at: folderUrl.appending(path: folderName), withIntermediateDirectories: false)
            fetchContentsOfDirectory()
        } catch let error{
           print(error)
        }
    }
    
    func createFile(image: UIImage, imageName: String) {
        let imageName = "\(imageName).png"
            let imageUrl = folderUrl.appendingPathComponent("\(imageName)")
            if let data = image.jpegData(compressionQuality: 1.0){
                do {
                    try data.write(to: imageUrl)
                    fetchContentsOfDirectory()
                } catch {
                    print("error saving", error)
                }
            }
    }
    
    func removeContent(atIndex: Int) {
        do {
            try FileManager.default.removeItem(at: items[atIndex].url)
            fetchContentsOfDirectory()
        } catch let error {
            print(error)
        }
    }
}
