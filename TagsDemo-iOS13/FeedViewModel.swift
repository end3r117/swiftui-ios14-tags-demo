//
//  FeedViewModel.swift
//  TagsDemo-iOS13
//
//  Created by Anthony Rosario on 8/10/20.
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
					if let img = PostImagesCache13.object(forKey: key as NSString) {
						post.updatePost(image: img, imageURL: nil)
					}
				}
				self?.postViews = posts.sorted(by: { $0.date > $1.date })
					.map({PostView(model: PostViewModel(post: $0))})
				if self?.newPostViewModel != nil {
					self?.newPostViewModel?.resetSubs()
					self?.newPostViewModel = nil
				}
				self?.refreshing = false
			}
		}
	}
	
	init() {
		refreshPosts()
	}
	
	func getNewPostViewModel() -> NewPostViewModel {
		if newPostViewModel == nil {
			newPostViewModel = NewPostViewModel()
		}
		return newPostViewModel!
	}
	
	func removePosts(at indexSet: IndexSet) {
		var posts = UserDefaults.standard.storedPosts.sorted(by: { $0.date > $1.date })
		let currentIds = postViews.map({ $0.id as NSString })
		DispatchQueue.main.async {
			withAnimation {
				self.postViews.remove(atOffsets: indexSet)
			}
		}
		DispatchQueue.global(qos: .background).async {
			posts.remove(atOffsets: indexSet)
			indexSet.forEach({idx in
				//posts.removeAll(where: { $0.id == self.postViews[idx].id })
				PostImagesCache13.removeObject(forKey: currentIds[idx])
			})
			UserDefaults.standard.storedPosts = posts
		}
		
	}
	
	func refreshPosts() {
		guard !refreshing else { return }
		refreshing = true
		PostsManager.shared.fetchPosts(completion: newPostSuccessClosure)
	}
}

