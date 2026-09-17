//
//  AttributeCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/27/26.
//

import SwiftUI

struct AttributeCard: View {
    let attribute: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(attribute)
                .font(.headline)
            
            Text(value)
                .font(.title3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(RoundedRectangle(cornerRadius: 16)
            .fill(Color(.gray))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4))
    }
}
