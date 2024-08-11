//
//  View.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import Foundation
import SwiftUI

extension View {
    func border(_ color: Color, width: CGFloat, cornerRadius: CGFloat) -> some View {
        return overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(color, lineWidth: width)
        )
    }
    
    func fullyTappable() -> some View {
        return contentShape(Rectangle())
    }
}
