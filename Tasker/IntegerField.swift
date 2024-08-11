//
//  IntegerField.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import SwiftUI

struct IntegerField: View {
    let label: String
    @Binding var value: Int?
    
    init(_ label: String, value: Binding<Int?>) {
        self.label = label
        self._value = value
    }
    
    init(_ label: String, value: Binding<Int>) {
        self.label = label
        self._value = Binding(get: { value.wrappedValue }, set: { value.wrappedValue = $0 ?? 0 })
    }
    
    var body: some View {
        TextField(label, value: $value, format: .number)
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
            .fullyTappable()
    }
}

#Preview {
    IntegerField("Calories", value: .constant(50))
}
