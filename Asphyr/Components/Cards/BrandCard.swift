//
//  BrandCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/15/26.
//

import SwiftUI

struct BrandCard: View {
    let brandLogo: String
    let brandName: String
    
    var isSystemSymbol: Bool = false
    
    var body: some View {
        HStack {
            // BRAND LOGO
            if isSystemSymbol {
                Image(systemName: brandLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.asphyrTextPrimary)
            } else {
                Image(brandLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
            }
            
            // BRAND NAME
            Text(brandName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.asphyrTextPrimary)
            
        }
        .frame(width: 170, height: 50)
        .background(Color.asphyrSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
