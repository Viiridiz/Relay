//
//  SettingsView.swift
//  Relay
//
//  Created by user286649 on 11/16/25.
//

import SwiftUI

fileprivate let brandNavy = Color(red: 27/255, green: 30/255, blue: 89/255)

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                brandNavy.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 50) {
                        
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image("relay_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width:350)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                        }
                        .padding(.top, 60)
                        
                        VStack(alignment: .leading) {
 
                            Button(action: {
                                authViewModel.signOut()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .foregroundStyle(.white)
                                .padding()
                                .frame(width: 250, height: 50)
                                .background(Color.red.opacity(0.9))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(brandNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
