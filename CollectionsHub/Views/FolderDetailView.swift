//  FolderDetailView.swift
//  CollectionsHub

import SwiftUI

struct FolderDetailView: View {
    @ObservedObject var folderManager: SupabaseManager
    var folder: Folder

    var body: some View {
        List(folderManager.links) { link in
            Text(link.link)
        }
        .navigationTitle(folder.name)
        .onAppear {
            Task {
                await folderManager.fetchLinks(folderID: folder.id)
            }
        }
    }
}
