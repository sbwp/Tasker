//
//  ColorOptionTile.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import SwiftUI

struct ColorOptionTile: View {
    let colorOption: ColorOption
    let selected: Bool
    
    var body: some View {
        Text(colorOption.label)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: 175, height: 75, alignment: .center)
            .background(colorOption.color)
            .foregroundStyle(colorOption.contrastingFontColor)
            .cornerRadius(20)
            .border(selected ? Color.white.opacity(0.3) : .clear, width: 3, cornerRadius: 20)
    }
}

#Preview {
    ColorOptionTile(colorOption: .brickRed, selected: true)
}
