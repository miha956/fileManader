//
//  PasscodePresenter.swift
//  FileManager
//
//  Created by Миша Вашкевич on 19.03.2024.
//

import Foundation

protocol PasscodePresenterProtocol: AnyObject {
    
    var codeLength: Int { get set }
    var passcode: [Int] { get set }
    var tempPasscode: [Int]? { get set }
    
    func enterPasscode(num: Int)
    func removeLastPasscode()
    func setNewPasscode()
    func checkPasscode()
    func clearPasscode(state: PasscodeState)
    
    init(view: PasscodeViewPtorocol, passcodeState: PasscodeState, keychainManager: KeychainManagerProtocol)
    
}

enum PasscodeState: String {
    
    case inputPasscode
    case wrongPasscode
    case setNewPasscode
    case repeatPasscode
    case passcodeMismatch
    
    func getPasscodeLabel() -> String {
        switch self {
        case .inputPasscode:
            return "Enter password"
        case .wrongPasscode:
            return "Password is wrong"
        case .setNewPasscode:
            return "Set new password"
        case .repeatPasscode:
            return "Repeat password"
        case .passcodeMismatch:
            return "Passwords doesn't match"
        }
    }
}

final class PasscodePresenter: PasscodePresenterProtocol {
    
    var codeLength = 5
    var passcode: [Int] = [] {
        didSet {
            if passcode.count == codeLength {
                switch passcodeState {
                case .inputPasscode:
                    self.checkPasscode()
                case .setNewPasscode:
                    self.setNewPasscode()
                default:
                    break
                }
            }
        }
    }
    var tempPasscode: [Int]?
    weak var view: PasscodeViewPtorocol?
    var passcodeState: PasscodeState
    let keychainManager: KeychainManagerProtocol
    
    required init(view: PasscodeViewPtorocol, passcodeState: PasscodeState, keychainManager: KeychainManagerProtocol) {
        self.view = view
        self.passcodeState = passcodeState
        self.keychainManager = keychainManager
        
        view.passcodeState(state: .inputPasscode)
        view.codeLength = codeLength
    }
    
    deinit {
       print("PasscodePresenter deinit")
    }

    func enterPasscode(num: Int) {
        if passcode.count < codeLength {
            passcode.append(num)
            view?.enterCode(code: passcode)
        }
    }
    
    func removeLastPasscode() {
        if passcode.isEmpty == false {
            passcode.removeLast()
            view?.enterCode(code: passcode)
        }
    }
    
    func setNewPasscode() {
        let stringPasscode = passcode.map { String($0) }.joined()

        if let user = keychainManager.getPassword() {
            if tempPasscode != nil {
                if passcode == tempPasscode {
                    keychainManager.updatePassword(user: user ,password: stringPasscode)
                    NotificationCenter.default.post(Notification(name: .init("passChanged")))
                } else {
                    clearPasscode(state: .passcodeMismatch)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        self?.view?.passcodeState(state: .inputPasscode)
                        self?.tempPasscode = nil
                    })
                }
            } else {
                tempPasscode = passcode
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    self?.clearPasscode(state: .repeatPasscode)
                })}
        } else {
            if tempPasscode != nil {
                if passcode == tempPasscode {
                    let user = User(isAuth: true, password: stringPasscode)
                    keychainManager.savePassword(user: user)
                    let vc = MainTabBarViewController()
                    view?.pushVC(view: vc)
                } else {
                    clearPasscode(state: .passcodeMismatch)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        self?.view?.passcodeState(state: .inputPasscode)
                        self?.tempPasscode = nil
                    })
                }
            } else {
                tempPasscode = passcode
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    self?.clearPasscode(state: .repeatPasscode)
                })
            }
        }
        
        
    }
    
    func checkPasscode() {
        let user = keychainManager.getPassword()
        if passcode.map({ String($0) }).joined() == user?.password {
            let vc = MainTabBarViewController()
            view?.pushVC(view: vc)
        } else {
            view?.passcodeState(state: .wrongPasscode)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                self?.clearPasscode(state: .inputPasscode)
            })
        }
    }
    
    func clearPasscode(state: PasscodeState) {
        passcode = []
        view?.enterCode(code: [])
        view?.passcodeState(state: state)
    }
}


