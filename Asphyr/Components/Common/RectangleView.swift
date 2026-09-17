//
//  RectangleView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct RectangleView: View {
    var height: CGFloat = 2
    var width: CGFloat = .infinity
    var color: Color = .asphyrBorder
    
    var body: some View {
        Rectangle()
            .frame(maxWidth: width, maxHeight: height)
            .foregroundStyle(color)
    }
}
