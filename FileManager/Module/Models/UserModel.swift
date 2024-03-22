//
//  UserModel.swift
//  FileManager
//
//  Created by Миша Вашкевич on 21.03.2024.
//

import Foundation

struct User: Codable {
    var isAuth: Bool
    var password: String
}
