//
//  DeathView.swift
//  SolarSurvival
//
//  Created by Bryan Nguyen on 23/11/24.
//

import SwiftUI

struct DeathView: View {
    @State private var showAlert = false
    var body: some View {
        NavigationStack{
            Group{
                if showAlert == true{
                    StartView()
                } else {
                    VStack {
                        Text("Game Over")
                            .font(.largeTitle)
                            .bold()
                        Button(action: {
                            showAlert = true
                        }, label: {
                            Text("Restart")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        })
                        // Automatically trigger alert as soon as the view appears
                        
                    }
                    
                    //
                    .navigationBarBackButtonHidden()
                }
            }
        }
    }
    
    //struct DeathView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        DeathView(playCutscene: playCutscene)
    //    }
    //}
}
