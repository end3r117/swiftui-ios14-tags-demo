//
//  FeedViewModel.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

class FeedViewModel: ObservableObject {
	@Published var postViews: [PostView] = []
	@Published var refreshing: Bool = false
	@Published var showingNewPostView: Bool = false
	
	private var newPostViewModel: NewPostViewModel?
	private lazy var newPostSuccessClosure: ([Post]) -> Void = {[weak self] posts in
		DispatchQueue.main.async {
			withAnimation {
				self?.showingNewPostView = false
				self?.refreshing = true
				self?.postViews.removeAll()
				for post in posts {
					var key = post.id
					if let url = post.imageURL {
						key = url.absoluteString
					}
					if let img = PostImagesCache.object(forKey: key as NSString) {
						post.updatePost(image: img, imageURL: nil)
					}
				}
				self?.postViews = posts.sorted(by: { $0.date > $1.date }).map({PostView(model: PostViewModel(post: $0))})
				self?.refreshing = false
			}
		}
	}
	
	init() {
		refreshPosts()
	}
	
	func removePosts(at indexSet: IndexSet) {
		DispatchQueue.global(qos: .background).async {
			indexSet.forEach { idx in
				PostImagesCache.removeObject(forKey: self.postViews[idx].id as NSString)
				var posts = UserDefaults.standard.storedPosts
				posts.removeAll(where: {$0.id == self.postViews[idx].id })
				UserDefaults.standard.storedPosts = posts
				DispatchQueue.main.async {
					withAnimation {
						self.postViews.remove(atOffsets: indexSet)
					}
				}
			}
		}
	}
	
	func getNewPostsModel() -> NewPostViewModel {
//		if newPostViewModel == nil {
			newPostViewModel = NewPostViewModel(onSuccess: newPostSuccessClosure)
//		}
		return newPostViewModel!
	}
	
	func refreshPosts() {
		guard !refreshing else { return }
		refreshing = true
		PostsManager.shared.fetchPosts(completion: newPostSuccessClosure)
//		{ (posts) in
//			var postViews = posts.map({PostView(model: PostViewModel(post: $0))})
//			if postViews.isEmpty {
//				postViews.append(PostView(model: PostViewModel()))
//			}
//			DispatchQueue.main.async {
//				self.postViews = postViews
//				self.refreshing = false
//			}
	}
}
