//
//  FeedView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct FeedView: View {
	@StateObject var viewModel = FeedViewModel()
	@Binding var colorScheme: ColorScheme
	@State private var first: Bool = true
    
	var body: some View {
		List {
			ForEach(viewModel.postViews.indices, id: \.self) { idx in
				viewModel.postViews[idx]
					.scaleEffect(1.1)
					.padding(.vertical)
			}
			.onDelete(perform: { indexSet in
				viewModel.removePosts(at: indexSet)
			})
		}
		.listStyle(PlainListStyle())
		.buttonStyle(PlainButtonStyle())
		.onAppear { viewModel.refreshPosts() }
		.onChange(of: viewModel.refreshing, perform: { value in
			if value == false {
				first = false
			}
		})
		.padding(.top)
		.overlay(
			VStack {
				if first || viewModel.refreshing {
					Text("Loading Feed...")
						.foregroundColor(.secondary)
				}else if viewModel.postViews.isEmpty {
					emptyFeed
						.frame(maxHeight: .infinity)
				}
			}
			, alignment:first || viewModel.refreshing  ? .center : .top)
		.sheet(isPresented: $viewModel.showingNewPostView, content: {
			NewPostView(viewModel: viewModel.getNewPostsModel())
				.environment(\.colorScheme, colorScheme)
				.colorScheme(colorScheme)
		})
		.toolbar {
			ToolbarItem(placement: .bottomBar, content:{
				Button(action: {
					viewModel.showingNewPostView.toggle()
				}, label: {
					Circle()
						.strokeBorder(lineWidth: 4)
						.foregroundColor(Color.accentColor)
						.frame(width: 50, height: 50)
						.overlay(Circle().fill(Color.accentColor.opacity(0.3)))
						.overlay(Image(systemName: "camera").font(.headline).foregroundColor(.white))
				})
			})
		}
		.preferredColorScheme(colorScheme)
	}
	
	var emptyFeed: some View {
		VStack {
			Text("No posts to view. Try adding a post.")
				.font(.title3)
				.foregroundColor(.secondary)
				.padding()
			Button("New post"){
				viewModel.showingNewPostView = true
			}
			.padding(.bottom)
			Button("Refrsh feed") {
				viewModel.refreshPosts()
			}
		}
		
	}
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Color(.systemBackground)
			HomeView()
		}
		
    }
}
