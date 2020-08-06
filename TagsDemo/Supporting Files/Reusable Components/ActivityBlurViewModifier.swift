//
//  ActivityBlurViewModifier.swift
//
//
//  Created by Anthony Rosario on 3/13/20.
//  Copyright © 2020 Anthony Rosario. All rights reserved.
//

import SwiftUI
import Combine

struct ActivityBlurView: ViewModifier {
	@Environment(\.colorScheme) var colorScheme
	@Binding var enabled: Bool
	@State private var scale: CGFloat = 1
	
	var blurRadius: CGFloat = 4
	var scaleModifier: CGFloat = 2
	var indicatorColor: UIColor = .white
	var additionalConditions: (() -> Bool)?
	
	public func body(content: Content) -> some View {
		var animating: Bool {
			if additionalConditions != nil {
				return additionalConditions!() && enabled
			}
			return enabled
		}
		
		return makeBody(content: content, animating: animating)
		
	}
	
	private func makeBody(content: Content, animating: Bool) -> some View {
		ZStack {
			content
				.blur(radius: animating ? blurRadius : 0)
			if animating {
				Rectangle()
					.fill(Color(.systemFill))
					.blendMode(.saturation)
				overlayIndicator(alignment: .center, animating: animating) {
					Rectangle()
						.fill(Color(.clear))
						.edgesIgnoringSafeArea(.vertical)
						.opacity(animating ? 0.8 : 0)
						.transition(.opacity)
						.animation(.easeOut(duration: 0.3))
				}
			}
		}
	}
	
	private func overlayIndicator<V: View>(alignment: Alignment, scaleModifier: CGFloat? = nil, animating: Bool, @ViewBuilder _ view: () -> V ) -> some View {
		view()
			.overlay(
				ActivityIndicator(isAnimating: animating)
					.configureUIView {
						$0.color = self.indicatorColor
						$0.hidesWhenStopped = true
					}
					.scaleEffect(scaleModifier ?? self.scaleModifier)
					.opacity(animating ? 1 : 0)
				, alignment: alignment)
	}
}

struct ActivityIndicator: UIViewRepresentable {
	
	typealias UIViewType = UIActivityIndicatorView
	var isAnimating: Bool
	fileprivate var configuration = { (indicator: UIViewType) in }
	
	func makeUIView(context: UIViewRepresentableContext<Self>) -> UIViewType { UIViewType() }
	func updateUIView(_ uiView: UIViewType, context: UIViewRepresentableContext<Self>) {
		configuration(uiView)
		isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
	}
}

extension View {
	
	func attachActivityIndicator(_ enabled: Binding<Bool>, blurRadius: CGFloat = 4, scaleModifier: CGFloat = 2, indicatorColor: UIColor = .white, additionalConditions: (() -> Bool)? = nil) -> some View {
		return self.modifier(ActivityBlurView(enabled: enabled, blurRadius: blurRadius, scaleModifier: scaleModifier, indicatorColor: indicatorColor, additionalConditions: additionalConditions))
	}
}

extension View where Self == ActivityIndicator {
	func configureUIView(_ configuration: @escaping (ActivityIndicator.UIViewType) -> Void) -> Self {
		Self.init(isAnimating: self.isAnimating, configuration: configuration)
	}
}

#if DEBUG
struct ActivityBlurViewModifier_Previews: PreviewProvider {
	static var previews: some View {
		EmptyView()
	}
}
#endif
