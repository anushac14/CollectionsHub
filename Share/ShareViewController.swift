import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController, FolderSelectionDelegate {
    var folderManager = SupabaseManager()
    var sharedURL: URL?
    var selectedFolder: Folder?
    
    private var folderNameLabel: UILabel!
    private var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        handleSharedContent()
        fetchFolders()
        setupUI()
    }
    
    private func handleSharedContent() {
        print("Handling shared content...")
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            print("Found NSExtensionItem")
            if let itemProvider = item.attachments?.first {
                print("Found item provider")
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    print("Item provider conforms to URL type")
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (url, error) in
                        guard let self = self else { return }
                        if let url = url as? URL {
                            print("Received URL: \(url)")
                            self.sharedURL = url
                        } else {
                            print("Failed to cast URL. Error: \(String(describing: error))")
                        }
                        DispatchQueue.main.async {
                            self.updatePostButtonState()
                        }
                    }
                } else {
                    print("Item provider does not conform to URL type")
                }
            } else {
                print("No item provider found")
            }
        } else {
            print("No NSExtensionItem found")
        }
    }
    
    private func fetchFolders() {
        print("Fetching folders...")
        Task {
            await folderManager.fetchFolders()
            DispatchQueue.main.async {
                print("Fetched folders: \(self.folderManager.folders)")
                self.updatePostButtonState()
            }
        }
    }
    
    private func setupUI() {
        let selectFolderButton = UIButton(type: .system)
        selectFolderButton.setTitle("Select Folder", for: .normal)
        selectFolderButton.addTarget(self, action: #selector(presentFolderSelection), for: .touchUpInside)
        
        folderNameLabel = UILabel()
        folderNameLabel.text = "No folder selected"
        folderNameLabel.textAlignment = .center
        
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveLink), for: .touchUpInside)
        saveButton.isEnabled = false
        
        let stackView = UIStackView(arrangedSubviews: [selectFolderButton, folderNameLabel, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func presentFolderSelection() {
        print("Presenting folder selection...")
        let folderSelectionVC = FolderSelectionViewController()
        folderSelectionVC.folderManager = folderManager
        folderSelectionVC.delegate = self
        let navController = UINavigationController(rootViewController: folderSelectionVC)
        present(navController, animated: true)
    }
    
    @objc private func saveLink() {
        print("Saving link...")
        guard let url = sharedURL, let folder = selectedFolder else {
            print("Cannot save link. Missing URL or selected folder.")
            return
        }
        addLink(to: folder, url: url)
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func addLink(to folder: Folder, url: URL) {
        print("Adding link to folder \(folder.name): \(url)")
        let link = Link(id: UUID(), folder_id: folder.id, link: url.absoluteString)
        Task {
            do {
                try await folderManager.addLink(link)
                print("Link added successfully.")
            } catch {
                print("Failed to add link: \(error)")
            }
        }
    }
    
    private func updatePostButtonState() {
        print("Updating post button state...")
        print("sharedURL: \(String(describing: sharedURL))")
        print("selectedFolder: \(String(describing: selectedFolder))")
        saveButton.isEnabled = (sharedURL != nil && selectedFolder != nil)
    }
    
    func didSelectFolder(_ folder: Folder) {
        print("Folder selected: \(folder)")
        selectedFolder = folder
        folderNameLabel.text = "Selected Folder: \(folder.name)"
        updatePostButtonState()
        dismiss(animated: true, completion: nil)
    }
}
