//
//  HomeView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct HomeView: View {
	let user = User(username: "end3r117", firstName: "Anthony")
	@State private var scheme: ColorScheme = UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
	@State private var menuOpen: Bool = false
	@State private var listStyleChoice: ListStyleChoice = .plain
	
	var body: some View {
		NavigationView {
			FeedView(colorScheme: $scheme, listStyleChoice: $listStyleChoice)
				.equatable()
			
			.navigationBarTitle(Text("Timeline"), displayMode: .large)
			.navigationBarItems(
				trailing:
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
			)
		}
		.id(listStyleChoice)
		.preferredColorScheme(scheme)
		.transition(.identity)
		.animation(nil)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
