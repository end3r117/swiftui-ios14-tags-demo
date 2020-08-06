//
//  PostsManager.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import Combine
import SwiftUI

enum PostManagerError: Error, LocalizedError {
	case createPostError, fetchPostsError, decodingError, encodingError, networkError, unknown(reason: String?)
	
	var errorDescription: String? {
		switch self {
		case .createPostError:
			return "Error creating new post."
		case .fetchPostsError:
			return "Error fetching posts."
		case .decodingError:
			return "Error decoding post."
		case .encodingError:
			return "Error encoding post."
		case .networkError:
			return "Network error."
		case .unknown(reason: let reason):
			return "An unknown error occured: \(reason ?? "N/A")"
		}
	}
}

let PostImagesCache = NSCache<NSString, UIImage>()

//Quickly mocking database using .plist. Not thread-safe.
extension UserDefaults {
	fileprivate static let storedPostsKey = "storedPosts"
	var storedPosts: [Post] {
		get {
			do {
				if let data = self.data(forKey: Self.storedPostsKey) {
					let posts = try JSONDecoder().decode([Post].self, from: data)
					return posts
				}
			}catch {
				print(error.localizedDescription)
			}
			return []
		}
		set {
			do {
				let data = try JSONEncoder().encode(newValue)
				set(data, forKey: Self.storedPostsKey)
			}catch {
				print(error.localizedDescription)
			}
		}
	}
}


typealias PostManagerFetchResponse = (image: UIImage, url: URL?)
class PostsManager: ObservableObject {
	private static var __postsManager = PostsManager()
	static var shared: PostsManager {
		__postsManager
	}
	private init() {
		//uncomment to clear all posts...or just delete them.
//		UserDefaults.standard.storedPosts = []
	}
	
	static let placeholderURLString = "https://via.placeholder.com/400x200"
	static let placeholderURL: URL = URL(string: placeholderURLString)!
	
	static let randomImageURLString = "https://picsum.photos/640/360"
	static let randomImageURL: URL? = URL(string: randomImageURLString)
	static let randomImageBaseURLIncomingHostname: String = "i.picsum.photos"
	static let randomImageBaseURLRequestHostname: String = "picsum.photos"

	private static let queue: DispatchQueue = DispatchQueue(label: "posts-manager.background-queue", qos: .background)
	private var cancelBucket = Set<AnyCancellable>()
	
	func createPost(_ newPostInput: Post.NewPostInput, completion: @escaping (Result<[Post], PostManagerError>) -> Void) {
		//mock network call
		if let img = newPostInput.image {
			let substr = newPostInput.imageURL?.absoluteString.split(separator: "?").first
			let string = substr == nil ? newPostInput.id : String(substr!)
			if PostImagesCache.object(forKey: string as NSString) == nil {
				PostImagesCache.setObject(img, forKey: string as NSString)
			}
		}
		Self.queue.async {
			let post = Post(input: newPostInput)
			UserDefaults.standard.storedPosts.append(post)
			
			Self.queue.asyncAfter(deadline: .now() + Double.random(in: 0..<2)){
				let posts = UserDefaults.standard.storedPosts
				DispatchQueue.main.async {
					if !(posts.isEmpty), posts.map({$0.title}).contains(post.title) {
						completion(.success(posts))
					}else {
						completion(.failure(.encodingError))
					}
				}
			}
		}
	}
	
	func updatedPost(_ post: Post, completion: (() -> Void)? = nil) {
		var p = UserDefaults.standard.storedPosts
		if let idx = p.firstIndex(of: post) {
			p[idx] = post
			UserDefaults.standard.storedPosts = p
			completion?()
		}
	}
	
	func randomImage(completion: @escaping (Result<PostManagerFetchResponse, PostManagerError>) -> Void) {
		randomImage()?
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { (completed) in
				switch completed {
				case .failure(let error):
					DispatchQueue.main.async {
						completion(.failure(error))
					}
				case .finished:
					print("Completed random image")
				}
			}, receiveValue: { (result) in
				DispatchQueue.main.async {
					completion(.success(result))
				}
			})
			.store(in: &cancelBucket)
	}
	func randomImage() -> AnyPublisher<PostManagerFetchResponse, PostManagerError>? {
		guard let url = Self.randomImageURL else {
			return Future { (promise) in
				if let data = try? Data(contentsOf: PostsManager.placeholderURL) {
					if let image = UIImage(data: data) {
						DispatchQueue.main.async {
							promise(.success(PostManagerFetchResponse(image, nil)))
						}
					}else {
						promise(.failure(.decodingError))
					}
				}else {
					DispatchQueue.main.async {
						promise(.failure(.networkError))
					}
				}
			}
			.eraseToAnyPublisher()
		}
		return URLSession.shared.dataTaskPublisher(for: url)
			.subscribe(on: DispatchQueue.global(qos: .background))
			.print()
			.tryMap { data, response -> (data: Data, url: URL?) in
				guard let httpResponse = response as? HTTPURLResponse,
					  200..<300 ~= httpResponse.statusCode else {
					throw PostManagerError.networkError
				}
				let url = self.urlFromReturnedImageAbsoluteString(httpResponse.url?.absoluteString)
				return (data, url)
			}
			.retry(3)
			.mapError({ (error) in
				if let e = error as? PostManagerError {
					return e
				} else {
					return PostManagerError.unknown(reason: error.localizedDescription)
				}
			})
			.print()
			.receive(on: DispatchQueue.main)
			.compactMap({data, url in
				if let img = UIImage(data: data) {
					return PostManagerFetchResponse(img, url)
				}
				return nil
			})
			.eraseToAnyPublisher()
	}
	
	func fetchPosts(completion: @escaping ([Post]) -> Void) {
		fetchPostsFromUserDefaults()
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { (posts) in
				DispatchQueue.main.async {
					completion(posts)
				}
			})
			.store(in: &cancelBucket)

	}
	
	private func fetchPostsFromUserDefaults() -> AnyPublisher<[Post], Never> {
		Future<[Post], Never>({ (promise) in
			Self.queue.asyncAfter(deadline: .now() + Double.random(in: 0..<2)) {
				let posts = UserDefaults.standard.storedPosts
				promise(.success(posts))
			}
		}).eraseToAnyPublisher()
	}
	
	func urlFromReturnedImageAbsoluteString(_ urlString: String?) -> URL? {
		guard let urlString = urlString, var components = URLComponents(string: urlString) else { return nil }
		if components.host == Self.randomImageBaseURLIncomingHostname {
			components.host = Self.randomImageBaseURLRequestHostname
		}
		components.queryItems?.removeAll()
		components.path = (components.path as NSString).deletingPathExtension
		return components.url
	}
}
