//
//  PostsView.swift
//  TagsDemo-iOS13
//
//  Created by Anthony Rosario on 8/9/20.
//

import SwiftUI


struct PostView: Identifiable, View {
	@Environment(\.colorScheme) var colorScheme
	@ObservedObject var model: PostViewModel
	var id: String { model.postID }
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if model.image != nil {
			model.image?
				.resizable()
				.scaledToFit()
			}else {
				Rectangle()
					.fill(Color(.secondarySystemFill))
					.frame(height: 200)
					.attachActivityIndicator(.constant(true))
			}
			HStack {
				Text(model.title)
					.font(.title)
					.bold()
				Spacer()
				Button(action: {
					model.favoriteButtonTapped()
				}, label: {
					Image(systemName: model.favorited ? "heart.fill" : "heart")
						.font(Font(UIFont.preferredFont(forTextStyle: .title3)))
						.foregroundColor(model.favorited ? .red : .primary)
				})
				.padding([.trailing])
			}
			Text(model.postedDate ?? "")
				.font(.caption)
				.italic()
				.foregroundColor(.secondary)
				.padding(.bottom)
			Text(model.body)
				.frame(maxHeight: .infinity)
				.fixedSize(horizontal: false, vertical: true)
			Divider()
				.padding(.vertical, 8)
			ScrollView(.horizontal, showsIndicators: false) {
				HStack {
					ForEach(model.tags, id: \.id) { tag in
						Text("#\(tag.tagName)")
							.italic()
							.foregroundColor(tag.color)
							.fontWeight(.medium)
					}
				}
			}
		}
		.fixedSize(horizontal: false, vertical: true)
		.padding(.vertical)
		.padding(.horizontal, 8)
		.background(
			RoundedRectangle(cornerRadius: 8)
				.fill(Color(colorScheme == .dark ? .secondarySystemFill : .systemFill))
		)
	}
}

struct PostView_Previews: PreviewProvider {
	static var previews: some View {
		PostView(model: PostViewModel())
	}
}
