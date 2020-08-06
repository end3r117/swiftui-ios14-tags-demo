//
//  NewPostView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct NewPostView: View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var viewModel: NewPostViewModel
	@State private var image: Image? = nil
	@State private var ready: Bool = false
	@State private var showAddTag: Bool = false
	@State private var newTagInput: String = ""
	
	@Namespace var addingTags
	@Namespace var removingTags
	
	
	var body: some View {
		VStack(spacing: 10) {
			Group {
				if viewModel.image != nil {
					viewModel.image!
						.resizable()
						.scaledToFill()
				}else {
					Rectangle()
						.fill(Color(.systemBackground))
				}
			}
				.attachActivityIndicator(.constant(viewModel.image == nil))
				.frame(maxWidth: .infinity, minHeight: 40, maxHeight: 200)
				.clipped()
			Button("choose image"){
				viewModel.changeImage()
			}
			Form {
				Section(header: Text("Create New Post")) {
					TextField("Add title...", text: $viewModel.postTitle)
					TextField("Add description", text: $viewModel.postBody)
						.fixedSize(horizontal: true, vertical: 	true)
				}
				Section(header: Text("Tags")){
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(viewModel.selectedTags, id: \.id) { tag in
								Button(action: {
									viewModel.selectTag(tag)
								}, label: {
									tag
										.matchedGeometryEffect(id: tag.id, in: addingTags, properties: [.position])
								})
								.padding(.horizontal, 8)
							}
						}
					}
				}
				.animation(.easeOut(duration: 0.3))
				Section(header: Text("Popular tags")) {
					HStack {
						Button(action: {
							showAddTag.toggle()
						}, label: {
							Image(systemName: "plus")
								.font(.title)
								.padding(.trailing)
								.foregroundColor(.accentColor)
						})
						.buttonStyle(PlainButtonStyle())
						ScrollView(.horizontal, showsIndicators: false) {
							HStack {
								if showAddTag {
									TextField("New tag...", text: $newTagInput, onCommit: {
										withAnimation {
											if newTagInput.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
												viewModel.availableTags.insert(.init(tagName: newTagInput), at: 0)
											}
											newTagInput = ""
											showAddTag = false
										}
									})
										.frame(maxWidth: .infinity, maxHeight: .infinity)
									.fixedSize(horizontal: true, vertical: false)
										
								}
								ForEach(viewModel.availableTags, id: \.id) { tag in
									Button(action: {
										viewModel.selectTag(tag)
									}, label: {
										tag
											.matchedGeometryEffect(id: tag.id, in: addingTags, properties: [.position])
									
									})
									.frame(maxWidth: .infinity)
								}
							}
						}.buttonStyle(PlainButtonStyle())
					}
				}
				.animation(.easeOut(duration: 0.3))
				
				
			}
			.frame(width: UIScreen.main.bounds.width)
			if ready {
			Button(action: {
				viewModel.createPost()
			}, label: {
				Text("Post")
					.font(.title3)
					.bold()
					.foregroundColor(.white)
					.padding(.vertical, 20)
					.frame(maxWidth: UIScreen.main.bounds.width)
			})
			.background(Color.accentColor)
			}
		}
		.preferredColorScheme(colorScheme)
		.onReceive(viewModel.postReady) { value in
			self.ready = value
		}
	}
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
		NewPostView(viewModel: NewPostViewModel{_ in})
    }
}
