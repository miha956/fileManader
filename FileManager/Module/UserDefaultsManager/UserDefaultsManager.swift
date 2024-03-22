//
//  UserDefaultsManager.swift
//  FileManager
//
//  Created by Миша Вашкевич on 22.03.2024.
//

import Foundation

protocol UserDefaultsManagerPtotocol {
    
    func loadSettings() -> Settings?
    func saveSettings(settings: Settings)
    func updateSettings(sorBt: Bool)
    func updateSettings(showSize: Bool)
}

final class UserDefaultsManager: UserDefaultsManagerPtotocol {
    
    func loadSettings() -> Settings? {
        guard let data = UserDefaults.standard.data(forKey: "databaseKEY") else { return nil }
        do {
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            return settings
        } catch let error {
            print("decode error \(error)")
            return nil
        }
    }
    
    func saveSettings(settings: Settings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: "databaseKEY")
        } catch let error {
            print("encode error \(error)")
        }
    }
    
    func updateSettings(sorBt: Bool) {
        let setting = Settings(sortBy: sorBt)
        saveSettings(settings: setting)
    }
    func updateSettings(showSize: Bool) {
        let setting = Settings(showPhotoSize: showSize)
        saveSettings(settings: setting)
    }
    
    init() {
        if loadSettings() != nil {
            print("we already have settings")
        } else {
            let settings = Settings()
            saveSettings(settings: settings)
        }
    }
    
    
}
