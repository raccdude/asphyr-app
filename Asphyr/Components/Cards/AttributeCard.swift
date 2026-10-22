//
//  AttributeCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/27/26.
//

import SwiftUI

struct AttributeCard: View {
    let attribute: UserAttribute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(attribute.name)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.asphyrTextSecondary)
            
            Text(attribute.value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.asphyrTextPrimary)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.asphyrSurface)
                .stroke(Color.asphyrBorder, lineWidth: 1)
        )
    }
}
