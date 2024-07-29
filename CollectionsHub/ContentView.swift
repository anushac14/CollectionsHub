import SwiftUI

struct ContentView: View {
    @StateObject private var folderManager = SupabaseManager()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(folderManager.folders) { folder in
                    NavigationLink(destination: FolderDetailView(folderManager: folderManager, folder: folder)) {
                        Text(folder.name)
                    }
                }
                .onDelete { indexSet in
                    let idsToDelete = indexSet.map { folderManager.folders[$0].id }
                    idsToDelete.forEach { id in
                        folderManager.deleteFolder(id: id)
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: showAddFolderAlert) {
                        Label("Add Folder", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                Task {
                    await folderManager.fetchFolders()
                }
            }
        }
    }
    
    private func showAddFolderAlert() {
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController {
            let alert = UIAlertController(title: "New Folder", message: "Enter folder name:", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Folder name"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
                if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                    folderManager.addFolder(name: folderName)
                }
            }))
            
            rootViewController.present(alert, animated: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
