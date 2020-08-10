//
//  UIColor+.swift
//  TagsDemo-iOS13
//
//  Created by Anthony Rosario on 8/9/20.
//

//
//  UIColor+.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

extension UIColor {
	static func random(opacityLowerBound lower: CGFloat, opacityUpperBound upper: CGFloat) -> UIColor {
		let opacityLower = max(min(lower,upper), 0)
		let opacityUpper = min(max(lower,upper), 1)
		
		
		let opacity: CGFloat = stride(from: opacityLower, to: opacityUpper, by: 0.01)
			.map { $0 }
			.shuffled()
			.randomElement() ?? (Bool.random() ? lower : upper)
		
		return random(opacity: opacity)
	}
	
	static func random(opacity: CGFloat = 1) -> UIColor {
		let getRand: () -> CGFloat = {
			return stride(from: 0.0, to: 1.0, by: 0.01)
				.map { $0 }
				.shuffled()
				.randomElement() ?? (Bool.random() ? 0 : 1)
		}
			
		return UIColor(red: getRand(), green: getRand(), blue: getRand(), alpha: opacity)
	}
	
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		return (red, green, blue, alpha)
	}
}
