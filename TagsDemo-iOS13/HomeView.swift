//
//  HomeView.swift
//  TagsDemo-iOS13
//
//  Created by Anthony Rosario on 8/9/20.
//
//
//  HomeView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

typealias User = (username: String, firstName: String)

struct HomeView: View {
	@ObservedObject var feedViewModel: FeedViewModel
	@State private var scheme: ColorScheme = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
	@State private var menuOpen: Bool = false
	@State private var listStyleChoice: ListStyleChoice = .plain
	
	let user = User(username: "end3r117", firstName: "Anthony")
	
	var body: some View {
		NavigationView {
			FeedView(viewModel: feedViewModel, colorScheme: $scheme, listStyleChoice: $listStyleChoice)
				.equatable()
			.navigationBarTitle(Text("Timeline"), displayMode: .large)
			.navigationBarItems(
				leading:
					Button(action: {
						withAnimation(.easeIn(duration: 2)) {
							scheme = scheme == .dark ? .light : .dark
						}
					}, label: {
						Image(systemName: scheme == .dark ? "lightbulb.fill" : "lightbulb")
							.foregroundColor(scheme == .dark ? .accentColor : .primary)
							.transition(.move(edge: .trailing))
							.animation(.easeInOut)
					})
				, trailing:
					Button(action: {
						feedViewModel.showingNewPostView.toggle()
					}, label: {
						Text("Add Post")
						Image(systemName: "camera.fill")
							.font(Font(UIFont.preferredFont(forTextStyle: .title3)))
					})
			)
		}
		.id(listStyleChoice)
		.sheet(isPresented: $feedViewModel.showingNewPostView, content: {
			NewPostView(viewModel: feedViewModel.getNewPostViewModel(), onSuccess: {
				feedViewModel.showingNewPostView = false
				feedViewModel.refreshPosts()
			})
			.environment(\.colorScheme, scheme)
			.colorScheme(scheme)
		})
		.preferredColorScheme(scheme)
		.transition(.identity)
		.animation(nil)
	}

}

struct HomeView13_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(feedViewModel: FeedViewModel())
	}
}
