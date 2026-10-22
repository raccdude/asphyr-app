//
//  WordMarkView.swift
//  Asphyr
//
//  Created by Mac-LAB on 9/24/26.
//

import SwiftUI

struct WordMarkView: View {
    let action: (() -> Void)?
    
    init(action: (() -> Void)? = nil) {
            self.action = action
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let action = action {
                Button {
                    action()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.asphyrTextPrimary)
                }
                .frame(width: 44, alignment: .leading)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text("ASPHYR")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color.asphyrAccentPrimary)
                .tracking(4)
                .offset(x: 2)
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }    
    }
}
