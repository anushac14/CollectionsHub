import SwiftUI

struct FolderDetailView: View {
    @ObservedObject var folderManager: SupabaseManager
    var folder: Folder

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(folderManager.links) { link in
                    if let originalUrl = URL(string: link.link),
                       let embedUrl = URL(string: originalUrl.absoluteString + "/embed/") {
                        VStack(alignment: .leading) {
                            InstagramPostView(url: embedUrl)
                                .frame(height: 700)
                        }
                    } else {
                        Text("Invalid URL")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(folder.name)
        .onAppear {
            Task {
                await folderManager.fetchLinks(folderID: folder.id)
            }
        }
    }
}
