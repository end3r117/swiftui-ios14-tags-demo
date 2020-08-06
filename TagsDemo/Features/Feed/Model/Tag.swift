//
//  Tag.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct Tag: View, Identifiable {
	
	var showRemove: Bool = false
	let id: String
	let uiColor: UIColor
	
	var color: Color {
		Color(uiColor)
	}
	
	init(tagName: String, color: UIColor = .random()) {
		self.id = tagName
		self.uiColor = color
	}
	
	mutating func select() {
		showRemove.toggle()
	}
	
	
	var body: some View {
			tagText(Color(.systemFill))
			.background(
				RoundedRectangle(cornerRadius: 4, style: .continuous)
					.fill(color)
			)
			.overlay(tagText(.white))
		
	}
	func tagText(_ fontColor: Color = .primary) -> some View {
		HStack {
		Text(id)
			.font(.headline)
			.foregroundColor(fontColor)
			.padding(.horizontal)
			.padding(.vertical, 10)
			.frame(maxWidth: .infinity, minHeight: 8)
			.fixedSize(horizontal: true, vertical: false)
			if showRemove {
				Image(systemName: "x.square.fill")
					.offset(x: -8)
					.foregroundColor(.white)
					Spacer()
						.frame(maxWidth: 4)
			}
		}
		
	}
	
}


struct Tag_Previews: PreviewProvider {
	
	static var previews: some View {
		Tag.demoTags.randomElement()
	}
}


extension Tag {
	static func makeTags(for tagNames: [String]) -> [Tag] {
		tagNames.map({Tag(tagName: $0)})
	}
	static var demoTags: [Tag] = Tag.makeTags(for: ["Blessed", "Summer", "Hot", "TIFU", "TIL"])
}

extension Tag: Equatable, Hashable {
	static func == (lhs: Tag, rhs: Tag) -> Bool {
		lhs.id == rhs.id && lhs.showRemove == rhs.showRemove
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension Tag: Codable {
	enum CodingKeys: String, CodingKey {
		case id, color
	}
	func encode(to encoder: Encoder) throws {
		let (red, blue, green, alpha) = uiColor.rgba
		let stringColor = "\(red),\(blue),\(green),\(alpha)"
		
		var container = encoder.container(keyedBy: Tag.CodingKeys.self)
		do {
			try container.encode(id, forKey: .id)
			try container.encode(stringColor, forKey: .color)
		}
	}
	init(from decoder: Decoder) throws {
		do {
			let container = try decoder.container(keyedBy: Tag.CodingKeys.self)
			
			let id = try container.decode(String.self, forKey: .id)
			
			let componentsArray = try container.decode(String.self, forKey: .color).split(separator: ",").map({String($0)})
			let formatter = NumberFormatter()
			guard componentsArray.indices.count == 4, let red = formatter.number(from: componentsArray[0]), let green = formatter.number(from: componentsArray[1]), let blue = formatter.number(from: componentsArray[2]), let alpha = formatter.number(from: componentsArray[3]) else {
				self.init(tagName: id)
				return
			}
			
			let color = UIColor(red: CGFloat(red.floatValue), green: CGFloat(green.floatValue), blue: CGFloat(blue.floatValue), alpha: CGFloat(alpha.floatValue))
			
			self.init(tagName: id, color: color)
			
		}
	}
}
