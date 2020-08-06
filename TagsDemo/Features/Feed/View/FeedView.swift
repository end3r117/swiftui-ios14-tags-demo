//
//  FeedView.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

struct FeedView: View, Equatable {
	static func == (lhs: FeedView, rhs: FeedView) -> Bool {
		lhs.listStyleChoice == rhs.listStyleChoice
	}
	
	@StateObject var viewModel = FeedViewModel()
	@Binding var colorScheme: ColorScheme
	@Binding var listStyleChoice: ListStyleChoice
	@State private var first: Bool = true
    
	var body: some View {
		GeometryReader { geo in
		List {
			ForEach(viewModel.postViews.indices, id: \.self) { idx in
				viewModel.postViews[idx]
					.scaleEffect(1.1)
					.padding(.vertical)
			}
			.onDelete(perform: { indexSet in
				withAnimation {
					viewModel.removePosts(at: indexSet)
				}
			})
			
		}
		.listStyleChoice(listStyleChoice)
		.buttonStyle(PlainButtonStyle())
		.transition(first ? .identity : .scale)
		.animation(first ? nil : .easeInOut)
		.onAppear { viewModel.refreshPosts() }
		.onChange(of: viewModel.refreshing, perform: { value in
			if value == false, first {
				first = false
			}
		})
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
		}
		.sheet(isPresented: $viewModel.showingNewPostView, content: {
			NewPostView(onSuccess: {
				viewModel.showingNewPostView = false
				viewModel.refreshPosts()
			})
			.environment(\.colorScheme, colorScheme)
			.colorScheme(colorScheme)
		})
		.toolbar {
			ToolbarItem(placement: .bottomBar){
				Button(action: {
					withAnimation(.easeIn(duration: 2)) {
						listStyleChoice.toggle()
					}
				}, label: {
					Text(listStyleChoice.rawValue)
						.animation(.easeInOut)
						.padding(.leading)
				})
			}
			ToolbarItem(placement: .bottomBar){
				Spacer()
			}
			ToolbarItem(placement: .bottomBar){
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
			}
			ToolbarItem(placement: .bottomBar){
				Spacer()
			}
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

enum ListStyleChoice: String, CaseIterable {
	case defaultStyle = "Default", grouped = "Grouped", inset = "Inset", insetGrouped = "InsetGroup", plain = "Plain"
	
	mutating func toggle() {
		if let idx = Self.allCases.firstIndex(of: self) {
			if Self.allCases.indices.contains(idx + 1) {
				self = Self.allCases[idx + 1]
			}else {
				self = Self.allCases.first!
			}
		}
	}
	
	func image(forColorScheme cs: ColorScheme) -> Image? {
		if self == .plain {
			return Image(systemName: cs == .dark ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
		}else if self == .inset {
			return Image(systemName: cs == .dark ? "rectangle.grid.2x2.fill" : "rectangle.grid.2x2")
		}
		
		return nil
	}
}

extension View {
	func listStyleChoice(_ style: ListStyleChoice) -> some View {
		return	Group {
			switch style {
			case .defaultStyle:
				self.listStyle(DefaultListStyle())
			case .grouped:
				self.listStyle(GroupedListStyle())
			case .inset:
				self.listStyle(InsetListStyle())
			case .insetGrouped:
				self.listStyle(InsetGroupedListStyle())
			case .plain:
				self.listStyle(PlainListStyle())
			}
		}
	}
}
