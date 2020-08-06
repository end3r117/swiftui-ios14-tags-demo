//
//  ActivityBlurViewModifier.swift
//  GenieBUY
//
//  Created by Anthony Rosario on 3/13/20.
//  Copyright © 2020 Faultliner Applications, LLC. All rights reserved.
//

import SwiftUI
import Combine

struct ActivityBlurView: ViewModifier {
	@Environment(\.colorScheme) var colorScheme
	@Binding var enabled: Bool
	@State private var rotation = Angle(degrees: 0)
	@State private var scale: CGFloat = 1
	var blurRadius: CGFloat = 4
	var scaleModifier: CGFloat = 2
	var indicatorColor: UIColor = .white
	
	var additionalConditions: (() -> Bool)?
	@State private var dev_ToggleActiveOn: Bool?
	public func body(content: Content) -> some View {
		var animating: Bool {
			if dev_ToggleActiveOn ?? false { return true }
			if additionalConditions != nil {
				return additionalConditions!() && enabled
			}
			return enabled
		}
		
		return makeBodyIndicatorOnly(content: content, animating: animating)
			
	}
	
	@ViewBuilder
	private func overlayIndicator<V: View>(message: String, alignment: Alignment, scaleModifier: CGFloat? = nil, animating: Bool, _ view: () -> V ) -> some View {
		view()
			.overlay(
				GeometryReader { geo in
					ZStack {
						ActivityIndicator(isAnimating: animating)
							.configureUIView {
								$0.color = self.indicatorColor
								$0.hidesWhenStopped = true
						}
						.scaleEffect(scaleModifier ?? self.scaleModifier)
						.opacity(animating ? 1 : 0)
						.position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY + 8)
						Text(message)
							.font(.title).bold()
							.foregroundColor(Color(.white))
							.frame(width: 414, height: 250)
							.position(x: geo.frame(in: .local).midX, y: geo.frame(in: .global).midY - 100)
							
					}
					.background(Color(.quaternarySystemFill).blendMode(.plusDarker).frame(width: 414, height: 260).cornerRadius(8))
				}
				, alignment: alignment)
	}
	
	@ViewBuilder
	private func makeBodyIndicatorOnly(content: Content, animating: Bool) -> some View {
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
	@ViewBuilder
	private func overlayIndicator<V: View>(alignment: Alignment, scaleModifier: CGFloat? = nil, animating: Bool, _ view: () -> V ) -> some View {
		view()
			.overlay(
				ActivityIndicator(isAnimating: animating)
					.configureUIView {
						$0.color = self.indicatorColor
						$0.hidesWhenStopped = true
						#if DEBUG
						//print($0.isAnimating)
						#endif
				}
				.scaleEffect(scaleModifier ?? self.scaleModifier)
				.opacity(animating ? 1 : 0)
				, alignment: alignment)
	}
}

struct ActivityIndicator: UIViewRepresentable {

    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
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
    func configureUIView(_ configuration: @escaping (Self.UIView)->Void) -> Self {
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
