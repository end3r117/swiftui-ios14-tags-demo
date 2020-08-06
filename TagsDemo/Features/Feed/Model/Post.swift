//
//  Post.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import Foundation
import UIKit

class Post: Identifiable, Equatable {
	static func == (lhs: Post, rhs: Post) -> Bool {
		lhs.id == rhs.id
	}
	
	private(set) var id: String
	private(set) var date = Date()
	private(set) var lastEdit: Date?
	private(set) var favorited: Bool
	
	private(set) var image: UIImage?
	private(set) var imageURL: URL?
	
	private(set) var title: String
	private(set) var body: String
	private(set) var tags: [Tag]
	
	init(id: String? = nil, date: Date? = nil, favorited: Bool? = nil, image: UIImage?, imageURL: URL?, title: String, body: String, tags: [Tag]) {
		self.id = id ?? UUID().uuidString
		self.date = date ?? Date()
		self.favorited = favorited ?? false
		self.image = image
		self.imageURL = imageURL
		self.title = title
		self.body = body
		self.tags = tags
	}
	
	init(input: NewPostInput) {
		self.id = input.id
		self.title = input.title
		self.image = input.image
		self.favorited = input.favorited
		self.imageURL = input.imageURL
		self.body = input.body
		self.tags = input.tags
	}
	
	required init(from decoder: Decoder) throws {
		do {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.id = try container.decode(String.self, forKey: .id)
			self.date = try container.decode(Date.self, forKey: .date)
			if let img = try container.decodeIfPresent(Data.self, forKey: .image){
				self.image = UIImage(data: img)
			}
			if let url = try container.decodeIfPresent(URL.self, forKey: .imageURL) {
				self.imageURL = url
			}
			if let fav = try? container.decodeIfPresent(Bool.self, forKey: .favorited) {
				self.favorited = fav
			}else { self.favorited = false }
			self.title = try container.decode(String.self, forKey: .title)
			self.body = try container.decode(String.self, forKey: .body)
			self.tags = try container.decode([Tag].self, forKey: .tags)
			
		}catch {
			fatalError(error.localizedDescription)
		}
	}
	///Same as calling updatePost(favorited:Bool)
	func favorited(_ bool: Bool) {
		updatePost(favorited: bool)
	}
	func updatePost(title: String? = nil, body: String? = nil, favorited: Bool? = nil, tags: [Tag]? = nil, image: UIImage? = nil, imageURL: URL? = nil) {
		var edited: Bool = false
		if let title = title { self.title = title; edited = true }
		if let body = body { self.body = body; edited = true }
		if let tags = tags {
			let filtered = tags.filter({ !(self.tags.contains($0) )})
			if !(filtered.isEmpty) {
				self.tags.append(contentsOf: filtered)
				edited = true
			}
		}
		if let favorited = favorited { self.favorited = favorited; edited = true }
		if let image = image {
			self.image = image
			let key = ((imageURL ?? self.imageURL)?.absoluteString) ?? id
			PostImagesCache.setObject(image, forKey: key as NSString)
			edited = true
		}
		if let imageURL = imageURL {
			self.imageURL = imageURL
			edited = true
		}
		if edited { lastEdit = Date() }
	}
}

extension Post {
	struct NewPostInput {
		let id: String
		var favorited: Bool = false
		let image: UIImage?
		let imageURL: URL?
		let title: String
		let body: String
		let tags: [Tag]
	}
}

extension Post: Codable {
	enum CodingKeys: String, CodingKey {
		case id, date, favorited, image, imageURL, title, body, tags
	}
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		do {
			try container.encode(id, forKey: .id)
			try container.encode(date, forKey: .date)
			try container.encode(favorited, forKey: .favorited)
			try container.encode(title, forKey: .title)
			try container.encode(body, forKey: .body)
			try container.encode(tags, forKey: .tags)
			
			if let data = image?.pngData() {
				try container.encode(data, forKey: .image)
			}
			if let url = imageURL {
				try container.encode(url, forKey: .imageURL)
			}
			
		}catch {
			print(error.localizedDescription)
		}
	}
}
