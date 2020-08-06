//
//  PostViewModel.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import Combine
import SwiftUI

class PostViewModel: ObservableObject {
	static var formatter: RelativeDateTimeFormatter {
		let f = RelativeDateTimeFormatter()
		f.dateTimeStyle = .numeric
		f.unitsStyle = .abbreviated
		
		return f
	}
	@Published var image: Image? = nil
	@Published var favorited: Bool = false
	@Published var tags: [Tag]
	
	private var post: Post
	var postID: String { post.id }
	var postedDate: String? { Self.formatter.localizedString(for: post.date, relativeTo: Date()) }
	var title: String { post.title }
	var body: String { post.body }
	
	
	func favoriteButtonTapped() {
		withAnimation {
			favorited.toggle()
			post.favorited(favorited)
			PostsManager.shared.updatedPost(post)
		}
	}
	
	init(post: Post) {
		self.post = post
		self.tags = post.tags
		self.favorited = post.favorited
		if let img = post.image {
			self.image = Image(uiImage: img)
		}else if let img = PostImagesCache.object(forKey: (post.imageURL?.absoluteString ?? post.id) as NSString) {
			self.image = Image(uiImage: img)
		}else {
			print("No image for post: \(post.title).\nURL: \(post.imageURL?.absoluteString ?? "NA")")
			if let url = post.imageURL, let img = try? UIImage(data: Data(contentsOf: url)) {
				self.post.updatePost(image: img, imageURL: url)
				self.image = Image(uiImage: img)
			}
		}
	}
	
	init() {
		let postInput = Post.NewPostInput(id: "Demo", image: nil, imageURL: nil, title: "Demo Post", body: "Blah blah blah, and then you wouldn't blah!", tags: [.init(tagName: "Demo"), .init(tagName: "Blessed")])
		
		self.post = Post(id: "Demo", date: Date.init(timeIntervalSinceNow: Double.random(in: 1...10) * Double(-86400)), image: nil, imageURL: nil, title: postInput.title, body: postInput.body, tags: postInput.tags)
		
		self.tags = post.tags
		
		PostsManager.shared.randomImage(completion: { [weak self] res in
			guard let self = self else { return }
			switch res {
			case .success(let (img, url)):
				DispatchQueue.main.async {
					self.objectWillChange.send()
					self.post.updatePost(image: img, imageURL: url)
					self.image = Image(uiImage: img)
					PostImagesCache.setObject(img, forKey: (url?.absoluteString ?? self.post.id) as NSString)
				}
			case .failure(let error):
				fatalError(error.localizedDescription)
			}
		})
	}
}
