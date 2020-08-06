//
//  NewPostView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct NewPostView: View {
	@Environment(\.colorScheme) var colorScheme
	@StateObject var viewModel = NewPostViewModel()
	
	@State private var image: Image? = nil
	@State private var ready: Bool = false
	@State private var showAddTag: Bool = false
	@State private var newTagInput: String = ""
	@State private var showActivity: Bool = false
	@State private var fetchingImage: Bool = false
	
	@State private var errorAlert: IdentifiableAlert? = nil
	
	@Namespace var tagAnimations
	@Namespace var addButtonAnimation
	
	var onSuccess: (() -> Void)?
	
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 10) {
				ScrollView {
					VStack {
						if viewModel.image != nil {
							viewModel.image!
								.resizable()
								.scaledToFill()
						}else {
							Rectangle()
								.fill(Color(.secondarySystemBackground))
						}
					}
					.attachActivityIndicator(.constant(viewModel.image == nil))
					.frame(width: geo.size.width, height: 300)
					Button(fetchingImage ? "fetching..." : "choose image"){
						fetchingImage.toggle()
						viewModel.fetchNewImage {
							fetchingImage = false
						}
					}
					.disabled(fetchingImage)
					VStack(spacing: 10) {
						postDetails
						usedTags
						Divider()
						if #available(iOS 14.0, *) {
							//Use Grid stack for iOS 14 Xcode 12
							//Comment out if compiler complains in Xcode 11 (like it should)
							tagGridStack
						}else {
							//Use Popular tags for iOS 13
							popularTags
						}
					}
					.padding()
				}
				.background(Color(colorScheme == .dark ? .systemGroupedBackground : .systemGroupedBackground))
				postButton
			}
		}
		.preferredColorScheme(colorScheme)
		.attachActivityIndicator($showActivity)
		.alert(item: $errorAlert, content: { (errorAlert) in
			errorAlert.alert
		})
		.onReceive(viewModel.$postReady) { value in
			self.ready = value
		}
	}
	
	//Not sure if this compiler check will work in Xcode 11.
	//If not, just comment tagGridStack out.
	#if compiler(>=5.3)
	var tagGridStack: some View {
		VStack {
			Section(header:
						HStack {
							Text("Popular tags")
								.font(.subheadline)
								.fontWeight(.medium)
								.textCase(.uppercase)
								.foregroundColor(.secondary)
							Spacer()
						}
						.padding(.horizontal)
			) {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHGrid(rows: [GridItem(.adaptive(minimum: 40, maximum: .infinity))],
							  spacing: 20,
							  content: {
						ForEach(viewModel.availableTags, id: \.id) { tag in
							Button(action: {
								showAddTag = false
								viewModel.selectTag(tag)
							}, label: {
								tag
									.matchedGeometryEffect(
										id: tag.id,
										in: tagAnimations,
										properties: [.position]
									)
							})
							.frame(minHeight: 80)
						}
					})
				}
				.frame(minHeight: 200, maxHeight: .infinity)
			}
		}
	}
	#endif
	var postDetails: some View {
		Section(
			header:
				HStack {
					Text("Create New Post")
						.font(.subheadline)
						.fontWeight(.medium)
						.textCase(.uppercase)
						.foregroundColor(.secondary)
					Spacer()
				}
				.padding(.horizontal)
			, content: {
				VStack {
					TextField("Add title...", text: $viewModel.postTitle)
						.padding(.vertical, 4)
					Divider()
					TextField("Add description", text: $viewModel.postBody)
						.padding(.vertical, 4)
				}
				.padding(.horizontal)
				.padding(.vertical, 8)
				.background(Color(.secondarySystemGroupedBackground).cornerRadius(10))
		})
	}
	
	var usedTags: some View {
		Section(header:
					HStack {
						Text("Tags")
							.font(.subheadline)
							.fontWeight(.medium)
							.textCase(.uppercase)
							.foregroundColor(.secondary)
						Spacer()
					}
					.padding(.horizontal)
		){
			HStack(spacing: 0) {
				if !showAddTag {
					Button(action: {
						showAddTag.toggle()
					}, label: {
						Image(systemName: "plus")
							.font(.title)
							.padding(8)
							.foregroundColor(.accentColor)
					})
					.background(Color(.secondarySystemGroupedBackground).cornerRadius(10))
					.padding(.leading)
					.contentShape(Rectangle())
					.matchedGeometryEffect(id: "plus", in: addButtonAnimation)
					.animation(.easeOut(duration: 0.3))
				}
				ScrollView(.horizontal, showsIndicators: false) {
					HStack {
							Spacer()
							ForEach(viewModel.selectedTags) { tag in
								Button(action: {
									withAnimation(.easeOut(duration: 0.3)) {
										viewModel.changeColor(forSelectedTag: tag)
									}
								}, label: {
									tag
										.matchedGeometryEffect(id: tag.id, in: tagAnimations, properties: [.position])
								})
								.padding(.horizontal, 8)
								.transition(.opacity)
							}
							.frame(minHeight: 44)
					}
					.frame(maxWidth: .infinity, minHeight: 44)
					.offset(x: showAddTag ? 400 : 0)
				}
				.background(Color(.secondarySystemGroupedBackground).cornerRadius(10))
				.padding(.leading)
				.overlay(
					HStack {
						if showAddTag {
							TextField("New tag...", text: $newTagInput, onCommit: addNewTag)
								.autocapitalization(.none)
								.frame(minWidth: 140, maxWidth: .infinity, maxHeight: .infinity)
								.padding(.horizontal)
								
							Spacer()
							Button(action: addNewTag, label: {
								//Don't know if this check will work in Xcode 11. Wrapped the matchedGeometryEffect in any AnyView, but...no clue. If it doesn't, comment out the AnyView.
								if #available(iOS 14.0, *) {
									AnyView(
								Text(newTagInput.count > 0 ? "Add" : "Back")
									.foregroundColor(.white)
									.padding(.horizontal, 20)
									.frame(minWidth: 80, maxWidth: 80, minHeight: 44, maxHeight: 44)
									.background(
										(newTagInput.count > 0 ? Color.accentColor : Color(.systemGray))
											.cornerRadius(3.0)
									)
									.matchedGeometryEffect(id: "plus", in: addButtonAnimation, properties: [.position], isSource: true)
									.animation(.easeOut(duration: 0.3))
									)
								}else {
								Text(newTagInput.count > 0 ? "Add" : "Back")
									.foregroundColor(.white)
									.padding(.horizontal, 20)
									.frame(minWidth: 80, maxWidth: 80, minHeight: 44, maxHeight: 44)
									.background(
										(newTagInput.count > 0 ? Color.accentColor : Color(.systemGray))
											.cornerRadius(3.0)
									)
									.animation(.easeOut(duration: 0.3))
								}
							})
							.padding(.leading)
						}
					}
					.frame(maxHeight: .infinity)
				)
			}
			.background(Color(.secondarySystemGroupedBackground).cornerRadius(10))
			.animation(.easeOut(duration: 0.3))
		}
	}
	
	var popularTags: some View {
		VStack {
			Section(header:
						HStack {
							Text("Popular tags")
								.font(.subheadline)
								.fontWeight(.medium)
								.textCase(.uppercase)
								.foregroundColor(.secondary)
							Spacer()
						}
						.padding(.horizontal)
			) {
				HStack(spacing: 0) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							Spacer()
								.frame(width: 20)
							ForEach(viewModel.availableTags, id: \.id) { tag in
								Button(action: {
									viewModel.selectTag(tag)
								}, label: {
									//Don't know if this check will work in Xcode 11. Wrapped the matchedGeometryEffect in any AnyView, but...no clue. If it doesn't, comment it out and use "tag" alone.
									if #available(iOS 14.0, *) {
										AnyView(
											tag
												.matchedGeometryEffect(
													id: tag.id,
													in: tagAnimations,
													properties: [.position]
												)
										)
									}else {
										tag
									}
								})
							}
							Spacer()
						}
						.frame(maxWidth: .infinity, minHeight: 44)
						.fixedSize(horizontal: true, vertical: false)
					}
				}
				.background(Color(.secondarySystemGroupedBackground).cornerRadius(10))
				.animation(.easeOut(duration: 0.3))
			}
		}
	}
	
	var postButton: some View {
		Group {
			if ready {
				Button(action: {
					showActivity = true
					viewModel.createPost { res in
						showActivity = false
						switch res {
						case .success(let success):
							if success {
								onSuccess?()
							}else {
								let msg = Text(PostManagerError.unknown(reason: "Something happened.").localizedDescription)
								let alert = Alert(title: Text("Error"),
												  message: msg,
												  dismissButton:.default(Text("Okay")))
								errorAlert = IdentifiableAlert(alert: alert)
							}
						case .failure(let error):
							let alert = Alert(title: Text("Error"),
											  message: Text(error.localizedDescription),
											  dismissButton:.default(Text("Okay")))
							errorAlert = IdentifiableAlert(alert: alert)
						}
					}
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
	}
	
	func addNewTag() {
		withAnimation {
			if newTagInput.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
				var tag = Tag(tagName: newTagInput)
				tag.select()
				viewModel.selectedTags.insert(tag, at: 0)
			}
			newTagInput = ""
			showAddTag = false
		}
	}
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
		NewPostView()
			.colorScheme(.dark)
    }
}
