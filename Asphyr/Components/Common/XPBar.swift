//
//  XPBar.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct XPBar: View {
    var body: some View {
        Rectangle()
            .fill(Color.asphyrSurface)
            .frame(maxWidth: .infinity, maxHeight: 16)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }
}

#Preview {
    XPBar()
}
