//
//  NewPostViewModel.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import Combine
import SwiftUI

class NewPostViewModel: ObservableObject {
	@Published var availableTags: [Tag] = Tag.demoTags
	@Published var selectedTags: [Tag] = []
	@Published var postTitle: String = ""
	@Published var postBody: String = ""
	
	let onSuccess: ([Post]) -> Void
	
	var image: Image? {
		if let img = uiImage {
			return Image(uiImage: img)
		}
		return nil
	}
	private var uiImage: UIImage? //= UIImage(systemName: "person.crop.circle.fill")
	private var imageURL: URL?
	
	
	var postReady = CurrentValueSubject<Bool,Never>(false)
	private var postReadySub: AnyCancellable?
	
	private var imageSub: AnyCancellable?
	private var imagePub: AnyPublisher<PostManagerFetchResponse, PostManagerError>?
	
	var randomImageSubs = Set<AnyCancellable>()
	
	private var postReadyPublisher: AnyPublisher<Bool, Never>?
	
	func selectTag(_ tag: Tag) {
		withAnimation {
			if let t = availableTags.first(where: { $0 == tag }) {
				availableTags.removeAll(where: {$0 == t })
				var new = t
				new.showRemove = true
				selectedTags.insert(new, at: 0)
			}else if let t = selectedTags.first(where: {$0 == tag }) {
				selectedTags.removeAll(where: {$0 == t })
				var new = t
				new.showRemove = false
				availableTags.append(new)
			}
		}
	}
	
	func createPost() {
		guard postReady.value, let img = uiImage, let url = imageURL else { fatalError() }
		let newPost = Post.NewPostInput(id: UUID().uuidString, image: img, imageURL: url,title: postTitle, body: postBody, tags: selectedTags)
		PostsManager.shared.createPost(newPost) { res in
			switch res {
			case .success(let posts):
				print(posts.count)
				DispatchQueue.main.async {
					self.onSuccess(posts)
				}
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
	
	func changeImage() {
		imageSub?.cancel()
		imagePub = PostsManager.shared.randomImage()
		imageSub = imagePub?
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: {[weak self] (res) in
				switch res {
				case .failure(let error):
					print(error.localizedDescription)
					self?.uiImage = nil //Image(systemName: "person.crop.circle.fill")
				case .finished:
					print("Yay")
				}
			}, receiveValue: {[weak self] (output) in
				DispatchQueue.main.async {
					self?.objectWillChange.send()
					if let urlSubString = output.url?.absoluteString.split(separator: "?").first {
						let urlString = String(urlSubString)
						self?.imageURL = PostsManager.shared.urlFromReturnedImageAbsoluteString(urlString)
					}
					self?.uiImage = output.image
					let str = output.url?.absoluteString.split(separator: "?").first
					print("Got Image from:\nURL: \(str == nil ? "ERROR" : str!)")
					print("ImageURL: \(self?.imageURL?.absoluteString ?? "NA")")
				}
			})
	}
	
	init(onSuccess: @escaping ([Post]) -> Void) {
		self.onSuccess = onSuccess
		changeImage()
		
		postReadyPublisher = Publishers.CombineLatest($postTitle, $postBody)
			.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
			.map({output in
				if output.0.trimmingCharacters(in: .whitespaces) != "",
				   output.1.trimmingCharacters(in: .whitespaces) != ""
				   {
					
					return true
				}
				return false
			})
			.eraseToAnyPublisher()
		
		postReadySub = postReadyPublisher?
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] ready in
				DispatchQueue.main.async {
					self?.postReady.send(ready)
				}
			})
		
	}
	

}
