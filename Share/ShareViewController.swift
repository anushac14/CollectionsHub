//
//  ShareViewController.swift
//  Share
//
//  Created by Anusha Chinthamaduka on 7/22/24.
//

import UIKit
import Social
import SwiftUI
import SwiftData

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(rootView: ShareView(itemProviders: itemProviders, controller: self))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
    }
}

fileprivate struct ShareView: View {
    var itemProviders: [NSItemProvider]
    var controller: ShareViewController?
    @State private var items: [Item] = []
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            VStack(spacing: 15) {
                Text("Add to favorites")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Button("Cancel", action: dismiss)
                            .tint(.red)
                    }
                    .padding(.bottom, 10)
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10) {
                        ForEach(items) { item in
                            Image(uiImage: item.previewImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width - 30)
                        }
                    }
                    .padding(.horizontal, 15)
                    .scrollTargetBehavior(.viewAligned)
                }
                .frame(height: 300)
                .scrollIndicators(.hidden)
                
                Button(action: saveItems , label: {
                    Text("Save")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(.blue, in: .rect(cornerRadius: 10))
                        .contentShape(.rect)
                })
                Spacer(minLength: 0)
            }
            .padding(15)
            .onAppear {
                extractItems(size: size)
            }
        }
    }
    
    func extractItems(size: CGSize) {
        guard items.isEmpty else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            for provider in itemProviders {
                provider.loadDataRepresentation(for: .image) { data, error in
                    if let data = data, let image = UIImage(data: data), let thumbnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
                        DispatchQueue.main.async {
                            items.append(.init(imageData: data, previewImage: thumbnail))
                        }
                    }
                }
            }
        }
    }
    
    func saveItems() {
        do {
            let context = try ModelContext(.init(for: ImageItem.self))
            for item in items {
                context.insert(ImageItem(data: item.imageData))
            }
            try context.save()
            dismiss()
        } catch {
            print(error.localizedDescription)
            dismiss()
        }
    }
    
    func dismiss() {
        controller?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private struct Item: Identifiable {
        let id: UUID = UUID()
        var imageData: Data
        var previewImage: UIImage
    }
}
