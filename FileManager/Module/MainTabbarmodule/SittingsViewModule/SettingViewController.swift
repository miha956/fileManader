//
//  SettingViewController.swift
//  FileManager
//
//  Created by Миша Вашкевич on 22.03.2024.
//

import UIKit

class SettingViewController: UIViewController {
    
    let userDefaultsManager: UserDefaultsManagerPtotocol
    var settings: Settings? {
        userDefaultsManager.loadSettings()
    }
    let tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    init(userDefaultsManager: UserDefaultsManagerPtotocol) {
        self.userDefaultsManager = userDefaultsManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changePhotoSizeAppereance(sender: UISwitch) {
        userDefaultsManager.updateSettings(showSize: sender.isOn)
    }
    @objc func changeSort(sender: UISwitch) {
        userDefaultsManager.updateSettings(sorBt: sender.isOn)
    }
    @objc func changePassword() {
        let passcodeView = PasscodeView()
        let keychainManager = KeychainManager()
        let presenter = PasscodePresenter(view: passcodeView, passcodeState: .setNewPasscode, keychainManager: keychainManager)
        passcodeView.passcodePresenter = presenter
        self.present(passcodeView, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("passChanged"), object: nil)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        self.dismiss(animated: true)
    }
    
}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let label = UILabel()
            label.text = "Sort content by Abc.."
            label.translatesAutoresizingMaskIntoConstraints = false
            let switcher = UISwitch()
            switcher.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            cell.contentView.addSubview(switcher)
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            switcher.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
            switcher.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            switcher.isOn = settings!.sortBy
            switcher.addTarget(self, action: #selector(changeSort), for: .valueChanged)
            return cell
        case 1:
            let label = UILabel()
            label.text = "Show photo size"
            label.translatesAutoresizingMaskIntoConstraints = false
            let switcher = UISwitch()
            switcher.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            cell.contentView.addSubview(switcher)
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            switcher.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
            switcher.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            switcher.isOn = settings!.showPhotoSize
            switcher.addTarget(self, action: #selector(changePhotoSizeAppereance), for: .valueChanged)
            return cell
        default:
            let changePassButton = UIButton(type: .system)
            changePassButton.translatesAutoresizingMaskIntoConstraints = false
            changePassButton.tintColor = .black
            changePassButton.setTitle("Change password", for: .normal)
            cell.contentView.addSubview(changePassButton)
            changePassButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            changePassButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            changePassButton.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            changePassButton.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            changePassButton.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
            return cell
        }
    }
    
    
}
