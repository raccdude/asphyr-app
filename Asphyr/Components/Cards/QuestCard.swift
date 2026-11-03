//
//  QuestCard.swift
//  Asphyr
//
//  Created by Mac-LAB on 8/25/26.
//

import SwiftUI

/// Shows Figma's sample quest until quest data exists.
struct QuestCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image("iconGamepad")
                    .foregroundStyle(Color.asphyrTextPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.asphyrSurfaceElevated, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY QUEST")
                        .font(AppTypography.captionMedium)
                        .foregroundStyle(Color.asphyrTextSecondary)

                    Text("BUILD A SMALL MECHANIC")
                        .font(AppTypography.subheading)
                        .foregroundStyle(Color.asphyrTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image("iconChevronRight")
                    .foregroundStyle(Color.asphyrTextSecondary)
                    .accessibilityHidden(true)
            }

            Text("Turn a simple idea into a working feature.")
                .font(AppTypography.bodySecondary)
                .foregroundStyle(Color.asphyrTextSecondary)
                .padding(.top, 14)

            HStack(spacing: 8) {
                tag {
                    Text("DEVELOPMENT")
                }

                tag {
                    Image("iconClockSmall")
                        .accessibilityHidden(true)
                    Text("30 MIN")
                }
            }
            .padding(.top, 14)

            Rectangle()
                .fill(Color.asphyrBorder)
                .frame(height: 1)
                .padding(.top, 14)

            HStack(spacing: 0) {
                Image("iconLightning")
                    .foregroundStyle(Color.asphyrWarning)
                    .accessibilityHidden(true)

                Text("+100 XP")
                    .padding(.leading, 4)

                Text("+5 CREATIVITY")
                    .padding(.leading, 12)

                Spacer(minLength: 8)

                QuestStatus(status: .available)
            }
            .font(AppTypography.captionMedium)
            .foregroundStyle(Color.asphyrWarning)
            .padding(.top, 14)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(Color.asphyrSurface, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.asphyrBorder, lineWidth: 1)
        }
    }

    private func tag<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 5) {
            content()
        }
        .font(AppTypography.captionMedium)
        .foregroundStyle(Color.asphyrTextSecondary)
        .padding(.horizontal, 10)
        .frame(height: 25)
        .background(Color.asphyrSurfaceElevated, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    QuestCard()
}
