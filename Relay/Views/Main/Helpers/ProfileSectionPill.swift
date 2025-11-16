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
                    .foregroundStyle(.primary)
            
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(30)
        }
    }
}
