//
//  AuthHeader.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct AuthHeader: View {
    let heading: String
    let subheading: String
    
    var body: some View {
        Text(heading)
            .font(.system(size: 24, weight: .bold)) // change
            .foregroundStyle(Color.asphyrTextPrimary)
            .padding(.top, 40)
        
        Text(subheading)
            .font(.system(size: 16, weight: .medium)) // change
            .foregroundStyle(Color.asphyrTextSecondary)
        
    }
}
