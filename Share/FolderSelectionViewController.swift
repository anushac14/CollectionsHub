import UIKit

protocol FolderSelectionDelegate: AnyObject {
    func didSelectFolder(_ folder: Folder)
}

class FolderSelectionViewController: UIViewController {
    var folderManager: SupabaseManager!
    weak var delegate: FolderSelectionDelegate?
    
    private var folders: [Folder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Select Folder"
        
        fetchFolders()
    }
    
    private func fetchFolders() {
        print("Fetching folders...")
        Task {
            await folderManager.fetchFolders()
            folders = folderManager.folders
            print("Fetched folders: \(folders)")
            DispatchQueue.main.async {
                self.setupUI()
            }
        }
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for folder in folders {
            let button = UIButton(type: .system)
            button.setTitle(folder.name, for: .normal)
            button.tag = folders.firstIndex(of: folder) ?? 0
            button.addTarget(self, action: #selector(folderSelected(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func folderSelected(_ sender: UIButton) {
        let selectedFolder = folders[sender.tag]
        print("Folder selected: \(selectedFolder)")
        delegate?.didSelectFolder(selectedFolder)
        dismiss(animated: true, completion: nil)
    }
}
