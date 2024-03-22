//
//  KeychainManager.swift
//  FileManager
//
//  Created by Миша Вашкевич on 21.03.2024.
//

import Foundation
import KeychainSwift

protocol KeychainManagerProtocol {
    
    var name: String { get }
    
    func getPassword() -> User?
    func savePassword(user: User)
    func updatePassword(user: User ,password: String)
}

final class KeychainManager: KeychainManagerProtocol {
    
    let storage = KeychainSwift()
    
    var name: String = "KeychainStorage"
    
    func getPassword() -> User? {
        guard let data = storage.getData("userDataBase9") else { return nil }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch let error {
            print("decode error \(error)")
            return nil
        }
    }
    
    func savePassword(user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            storage.set(data, forKey: "userDataBase9")
        } catch let error {
            print("encode error \(error)")
        }
    }
    
    func updatePassword(user: User ,password: String) {
        var user = user
        user.password = password
        savePassword(user: user)
    }

}
