//
//  ColorOptionPicker.swift
//  Tasker
//
//  Created by Sabrina Bea on 6/20/24.
//

import SwiftUI

struct ColorOptionPicker: View {
    @Binding var colorOption: ColorOption
    @State var showPopover: Bool = false
    
    var body: some View {
        ColorOptionTile(colorOption: colorOption, selected: true)
            .onTapGesture {
                showPopover = true
            }
            .popover(isPresented: $showPopover) {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(ColorOption.rainbow, id: \.self) { option in
                            ColorOptionTile(colorOption: option, selected: colorOption == option)
                                .onTapGesture {
                                    colorOption = option
                                    showPopover = false
                                }
                        }
                    }
                    .padding(.vertical, 50)
                }
            }
    }
}

#Preview {
    struct Preview: View {
        @State var color: ColorOption = .brickRed
        var body: some View {
            ColorOptionPicker(colorOption: $color)
        }
    }
    
    return Preview()
}
