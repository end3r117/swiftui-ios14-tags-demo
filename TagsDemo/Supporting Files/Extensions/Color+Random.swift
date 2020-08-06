//
//  Color+Random.swift
//  TagsDemo
//
//  Created by Anthony Rosario on 8/5/20.
//

import SwiftUI

extension Color {
	static func random() -> Color {
		random(opacityRange: 1...1)
	}
	
	static func random(opacityRange: ClosedRange<Double>) -> Color {
		let opacityLower = max(opacityRange.lowerBound, 0)
		let opacityUpper = min(opacityRange.upperBound, 1)
		let opacity = Double.random(in: opacityLower...opacityUpper)
		
		return Color(red: Double.random(in: 0...255) / 255, green: Double.random(in: 0...255) / 255, blue: Double.random(in: 0...255) / 255, opacity: opacity)
	}
}
