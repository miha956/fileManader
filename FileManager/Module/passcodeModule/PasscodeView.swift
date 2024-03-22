//
//  PassCodeView.swift
//  FileManager
//
//  Created by Миша Вашкевич on 19.03.2024.
//

import Foundation
import UIKit

protocol PasscodeViewPtorocol: AnyObject {
    
    var codeLength: Int? { get set }
    func passcodeState(state: PasscodeState)
    func enterCode(code: [Int])
    func pushVC(view: UIViewController)
}

final class PasscodeView: UIViewController {
    
    // MARK: Properties
    
    var passcodePresenter: PasscodePresenterProtocol?
    let numbers : [[Int]] = [[1,2,3],[4,5,6],[7,8,9],[0]]
    var codeLength: Int?
    
    // MARK: SubViews
    private let passcodeStateLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return view
    }()
    private let keyboardStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .center
        return view
    }()
    private let codeStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 20
        view.alignment = .center
        return view
    }()
    private let deleteButton: UIButton = {
        let view = UIButton(type: .system)
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(systemName: "delete.left"), for: .normal)
        view.addTarget(nil, action: #selector(deleteBottonTapped), for: .touchUpInside)
        return view
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addSubviews()
        setupConstrints()
        confingNumStackView()
        congifCodeStackView()
    }
    
    deinit {
        print("PasscodeView deinit")
    }
    
    // MARK: Actions
    
    @objc func numBottonTapped(sender: UIButton) {
        passcodePresenter?.enterPasscode(num: sender.tag)
    }
    
    @objc func deleteBottonTapped() {
        passcodePresenter?.removeLastPasscode()
    }
    
    // MARK: Private
    
    func setupView() {
        view.backgroundColor = .black
    }
    
    func addSubviews() {
        [passcodeStateLabel,codeStackView,keyboardStackView,deleteButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setupConstrints() {
        
        NSLayoutConstraint.activate([
            
            passcodeStateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            passcodeStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            codeStackView.topAnchor.constraint(equalTo: passcodeStateLabel.bottomAnchor, constant: 40),
            codeStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            keyboardStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyboardStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: keyboardStackView.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: keyboardStackView.bottomAnchor, constant: -15),
            deleteButton.heightAnchor.constraint(equalToConstant: 60),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            
        ])
        
    }
    
    func confingNumStackView() {
        numbers.forEach { numsarray in
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 50
            numsarray.forEach { num in
                let button = UIButton(type: .system)
                button.setTitle("\(num)", for: .normal)
                button.tintColor = .white
                button.titleLabel?.font = UIFont.systemFont(ofSize: 60, weight: .light)
                button.tag = num
                button.widthAnchor.constraint(equalToConstant: 60).isActive = true
                button.addTarget(self, action: #selector(numBottonTapped), for: .touchUpInside)
                stackView.addArrangedSubview(button)
                }
            keyboardStackView.addArrangedSubview(stackView)
        }
    }
    
    func congifCodeStackView() {
        guard let codeLength = codeLength else { return }
        
        while codeStackView.subviews.count < codeLength {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 20).isActive = true
            view.widthAnchor.constraint(equalToConstant: 20).isActive = true
            view.layer.cornerRadius = 10
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.white.cgColor
            codeStackView.addArrangedSubview(view)
        }
    }
}

extension PasscodeView: PasscodeViewPtorocol {
    
    
    func passcodeState(state: PasscodeState) {
        passcodeStateLabel.text = state.getPasscodeLabel()
    }
    
    func enterCode(code: [Int]) {
        for i in 0..<codeStackView.subviews.count {
            if i < code.count {
                codeStackView.subviews[i].backgroundColor = .white
            } else {
                codeStackView.subviews[i].backgroundColor = .clear
            }
        }
    }
    
    func pushVC(view: UIViewController) {
        navigationController?.setViewControllers([view], animated: true)
    }
}
