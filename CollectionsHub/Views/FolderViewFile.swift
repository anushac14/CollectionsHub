import Combine

class FolderViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchFolders() {
        SupabaseClient.shared.client.database
            .from("folders")
            .select()
            .execute { result in
                switch result {
                case .success(let response):
                    do {
                        let folders = try response.decode([Folder].self)
                        DispatchQueue.main.async {
                            self.folders = folders
                        }
                    } catch {
                        print("Decoding error: \(error)")
                    }
                case .failure(let error):
                    print("Error fetching folders: \(error)")
                }
            }
    }
}
