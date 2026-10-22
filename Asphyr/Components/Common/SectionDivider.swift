//
//  SectionDivider.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct SectionDivider: View {
    let sectionTitle: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(sectionTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.asphyrTextPrimary)
                
            RectangleView(height: 1)
        }
        
    }
}
