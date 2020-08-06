//
//  TagsDemoApp.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

typealias User = (username: String, firstName: String)

@main
struct TagsDemoApp: App {
	
	var body: some Scene {
        WindowGroup {
            HomeView()
				.environmentObject(PostsManager.shared)
        }
    }
}
