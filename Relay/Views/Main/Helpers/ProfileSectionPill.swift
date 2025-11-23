//
//  ProfileSectionPill.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

struct ProfileSectionPill: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.callout)
                    .frame(width: 20)
                    .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.8)) // Brand Cyan
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
