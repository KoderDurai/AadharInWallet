//
//  AboutMw.swift
//  AadharInWallet
//
//  Created by Karthikeyan Duraivel on 15/07/2024.
//

import SwiftUI

struct aboutMeSheet: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.teal, Color.teal, Color.blue], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea()

            VStack {
                // Top section for the profile picture and name
                HStack {
                    Image("me")
                        .clipShape(Circle())
                        .frame(width: 125, height: 125)
                    VStack(alignment: .leading) {
                        Text("Karthikeyan Duraivel")
                            .font(.largeTitle)
                            .fontWeight(.black)
                    }
                }
                .padding(.top, 25)
                .padding(10)

                Spacer(minLength: 25) // Adjust minLength as needed

                // Main content area
                VStack {
                    ZStack {
                        Rectangle()
//                            .frame(width: .infinity)
                            .opacity(0.3)
                            .cornerRadius(30.0)
                            .foregroundStyle(Color.white)

                        VStack(spacing: 10) {
                            Text("Just a small-time data wizard with an aerospace degree, turning tea into code and launching possibly brilliant iOS apps into the stratosphere. Currently learning to combine my analytical skills with tech to create something great! When I'm not wrestling with algorithms, you can find me exploring new tech trends or indulging in a good sci-fi novel. Always up for a challenge, whether it's coding or calculating flight trajectories!")
                                .fontWeight(.regular)
                                .multilineTextAlignment(.leading)
                            Spacer()

                            HStack {
                                Text("[GitHub](https://github.com/KoderDurai)")
                                    .bold()
                                    .tint(Color.blue)
                                Text("    |    ")
                                    .bold()
                                Text("[LinkedIn](https://www.linkedin.com/in/kduraivel/)")
                                    .bold()
                                    .tint(Color.blue)
                            }
                            Spacer()
                        }
                        .padding(15)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 15)
                }
                Spacer() // Final spacer to add space at the bottom
            }
        }
        .navigationTitle("About Me")
    }
}

#Preview {
    aboutMeSheet()
}

