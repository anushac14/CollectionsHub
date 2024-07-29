import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    let client: SupabaseClient
    @Published var folders: [Folder] = []

    init() {
        self.client = SupabaseClient(supabaseURL: URL(string: "https://gpvmwqfevyfykdcfgpxb.supabase.co")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdwdm13cWZldnlmeWtkY2ZncHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyMzYxOTEsImV4cCI6MjAzNzgxMjE5MX0.9ql5yfBE431ipBLCucrGflUUu98Ku__kz5aTRAg6eao")
        Task {
            await fetchFolders()
        }
    }
    
    func addFolder(name: String) {
        Task {
            do {
                try await client
                    .from("folders")
                    .insert(["name": name])
                    .execute()
                await fetchFolders() // Refresh the folder list
            } catch {
                print("Failed to add folder: \(error)")
            }
        }
    }
    
    func deleteFolder(id: UUID) {
        Task {
            do {
                try await client
                    .from("folders")
                    .delete()
                    .eq("id", value: 1)
                    .execute()
                await fetchFolders() // Refresh the folder list
            } catch {
                print("Failed to delete folder: \(error)")
            }
        }
    }
    
    func fetchFolders() async {
        do {
            let foldersResponse: [Folder] = try await client
                .from("folders")
                .select()
                .execute()
                .value
            DispatchQueue.main.async {
                self.folders = foldersResponse
            }
        } catch {
            print("Failed to fetch folders: \(error)")
        }
    }
    
    enum SupabaseError: Error {
        case insertFailed
        case fetchFailed
    }
}
