//
//  ViewController.swift
//  FileManager
//
//  Created by Миша Вашкевич on 18.03.2024.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    let fileManagerService: FileManagerServiceProtocol
    let userDefaultsManager: UserDefaultsManagerPtotocol
    var settings: Settings? {
        userDefaultsManager.loadSettings()
    }
    // MARK: Subviews
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var addFileButton: UIBarButtonItem = {
        let view = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addFileButtonTapped))
        view.tintColor = .black
        return view
    }()
    private lazy var addFolderButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"),
                                   style: .plain, target: self,
                                   action: #selector(addFolderButtonTapped))
        view.tintColor = .black
        return view
    }()
    

    // MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    init(fileManagerService: FileManagerServiceProtocol, userDefaults: UserDefaultsManagerPtotocol) {
        self.fileManagerService = fileManagerService
        self.userDefaultsManager = userDefaults
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    deinit {
        print("deinit")
    }
    
    // MARK: Actions
    
    @objc func addFileButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    @objc func addFolderButtonTapped() {
        let alertController = UIAlertController(title: "Create new folder", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Folder name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] action in
            self?.fileManagerService.createDirectory(folderName: "\(alertController.textFields![0].text!)")
            self?.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        self.present(alertController, animated: true)
    }
    
    
    // MARK: Private
    
    func setupView() {
        navigationItem.rightBarButtonItems = [addFileButton, addFolderButton]
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
        
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileManagerService.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var items = fileManagerService.items
        if settings!.sortBy {
            items.sort {$0.name < $1.name}
        } else {
            items.sort {$0.name > $1.name}
        }
    
        let cell = UITableViewCell()
        var configuration = UIListContentConfiguration.cell()
        configuration.text = items[indexPath.row].name
        if items[indexPath.row].isFolder! {
            cell.accessoryType = .disclosureIndicator
        } else {
            if settings!.showPhotoSize {
                configuration.secondaryText = "\(fileManagerService.items[indexPath.row].url.dataRepresentation)"
            }
        }
        cell.contentConfiguration = configuration
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                fileManagerService.removeContent(atIndex: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if fileManagerService.items[indexPath.row].isFolder! {
            let url = fileManagerService.items[indexPath.row].url
            let filemanager = FileManagerService(folderUrl: url)
            let userdefaults = UserDefaultsManager()
            let vc = ViewController(fileManagerService: filemanager, userDefaults: userdefaults)
            vc.title = fileManagerService.items[indexPath.row].name
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            fileManagerService.createFile(image: imagePicked, imageName: "\(Date.now)")
            picker.dismiss(animated: true)
            tableView.reloadData()
            
        }
    }
}

