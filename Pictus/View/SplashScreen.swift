//
//  SplashScreen.swift
//  Pictus
//
//  Created by Andre on 23/08/26.
//

import SwiftUI

struct SplashScreen: View {
    @StateObject var viewModel = EyeViewModel()
    var body: some View {
        GeometryReader { geo in
            
            
            ZStack {
                Circle()
                    .fill(
                           RadialGradient(
                               gradient: Gradient(colors: [
                                Color("AccentColor"),
                                Color("AccentColor").opacity(0.3),
                                 
                               ]),
                               center: .top,
                               startRadius: 200,
                               endRadius: 400
                           )
                       )
                    .frame(width: 300, height: 300)
                // Esclera (branco)
                Circle()
                    .fill(.corFundoOlho)
                    .frame(width: 230, height: 230)
                    .position(x: geo.size.width/2, y: geo.size.height*0.466)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                // Pupila
                Circle()
                    .fill(Color("AccentColor"))
                    .frame(width: 130, height: 130)
                    .position(x: geo.size.width/2, y: geo.size.height * 0.466)
                    .offset(viewModel.pupilOffset)
                                }
                            }
                            .onAppear {
                                viewModel.startMovement()
                            }
                            .onDisappear {
                                viewModel.stopMovement()
                            }
      
        Spacer()
        
            }
        }
                
    


#Preview {
    LoadingView()
}
