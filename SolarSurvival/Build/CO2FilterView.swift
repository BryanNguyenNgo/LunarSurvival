//
//  CO2FilterView.swift
//  SolarSurvival
//
//  Created by Bryan Nguyen on 23/11/24.
//

import SwiftUI

struct CO2FilterView: View {
    @EnvironmentObject var gameState: GameState
    @State private var pressOrder: [Int: Int] = [:] // Maps item IDs to press order
    @State private var pressCount = 0 // Tracks number of selections
    @AppStorage("finishedInfrastructure") var finishedInfrastructure = ""
    @State private var goProgressView = false
    @EnvironmentObject var buildingManager: BuildingManager
    @AppStorage("day") var day = 1
    @State private var neededMetal = 3
    @State private var neededPlastic = 5
    @State private var neededRubber = 2
    @State private var neededElectronics = 3
    @State private var showAlert = false
    @State private var geometryForOrder: CGFloat = 0
    @State private var geometryForFont: CGFloat = 0
    @AppStorage("structure") var goodStructure = true // Defaults to true
    
    @StateObject private var itemManager = ItemManager()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            NavigationLink(destination: ProgressBuilding(), isActive: $goProgressView) {
                EmptyView()
            }
            GeometryReader{ geometry in
                ZStack {
                    Image("moon surface img")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                HStack {
                    // Material requirements display
                    VStack(alignment: .leading, spacing: 20) {
                        materialRequirement(imageName: "questionmark", text: "0/\(neededMetal)")
                        materialRequirement(imageName: "questionmark", text: "0/\(neededPlastic)")
                        materialRequirement(imageName: "questionmark", text: "0/\(neededRubber)")
                        materialRequirement(imageName: "questionmark", text: "0/\(neededElectronics)")
                    }
                    
                    Spacer()
                    
                    // Material selection buttons
                    VStack {
                        Text("Choose 4 wisely")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(itemManager.items.indices, id: \.self) { index in
                                materialButton(id: index, title: itemManager.items[index].name.capitalized)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
//                    Button(action: {
//
//                    }, label: {
//                        /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
//                    })
                    // Confirm button
                    Button(action:{
                        deductResources()
                        addResourcelToBuilding()
                        
                        
                        
                    }, label:{
                        Text("Next")
                            .font(.title2)
                            .padding()
                            .background(canProceed ? Color.green : Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    })
                    .disabled(!canProceed)
                    .onAppear(perform: {
                        geometryForOrder =  geometry.size.width
                    })
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Not enough resources"),
                            message: Text("Please scavenge for more"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }
    
    // Computed property to enable or disable the "Next" button
    private var canProceed: Bool {
        guard pressOrder.count == 4 else { return false }
        
        let requirements = [neededMetal, neededPlastic, neededRubber, neededElectronics]
        return !pressOrder.keys.contains { index in
            let materialIndex = index
            guard materialIndex < itemManager.items.count else { return true }
            let currentAmount = itemManager.items[materialIndex].amount
            let requiredAmount = requirements[pressOrder[index]! - 1]
            return currentAmount < requiredAmount
        }
    }
    private func addResourcelToBuilding() {

        finishedInfrastructure = "co2filter"

    }
    // MARK: - Material Requirement Row
    private func materialRequirement(imageName: String, text: String) -> some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 60, height: 60)
            Text(text)
                .font(.title)
                .foregroundColor(.white)
                .monospaced()
        }
    }
    
    // MARK: - Material Button
    private func materialButton(id: Int, title: String) -> some View {
        Button(action: {
            geometryForFont = geometryForOrder * 0.02
            if let order = pressOrder[id] {
                // Deselect if already selected
                pressOrder[id] = nil
                pressCount -= 1
                // Reorder remaining selections
                pressOrder = pressOrder.mapValues { $0 > order ? $0 - 1 : $0 }
            } else if pressCount < 4 {
                // Select if not already selected
                pressCount += 1
                pressOrder[id] = pressCount
            }
        }) {
            ZStack {
                Color.white
                    .cornerRadius(10)
                    .frame(height: 65)
                
                VStack {
                    Image(itemManager.items[id].name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    Text("\(itemManager.items[id].amount)")
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .monospaced()
                }
                
                HStack{
                    Spacer()
                    VStack{
                        ZStack{
                            if let order = pressOrder[id] {
                                Circle()
                                    .foregroundColor(Color.red)
                                    .frame(width: geometryForOrder * 0.02, height: geometryForOrder * 0.02)
                                Text("\(order)")
                                    .font(.system(size: geometryForFont))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                               
                            }
                        }
                        Spacer()
                    }
                   
                }
            }
        }
    }
    
    // MARK: - Deduct Resources
    private func deductResources() {
        guard canProceed else {
            showAlert = true
            return
        }
        
        let sortedPressOrder = pressOrder.sorted { $0.value < $1.value }
        let requirements = [neededMetal, neededPlastic, neededRubber, neededElectronics]
        var matchedRequirements = 0 // Count of correctly matched materials
        
        for (index, entry) in sortedPressOrder.enumerated() {
            let materialIndex = entry.key
            let requiredAmount = requirements[index]
            itemManager.items[materialIndex].amount -= requiredAmount
            
            // Check if material matches one of the required types
            let selectedMaterial = itemManager.items[materialIndex].name.lowercased()
            if ["metal", "plastic", "rubber", "electronics"].contains(selectedMaterial) {
                matchedRequirements += 1
            }
        }
        
        goodStructure = matchedRequirements >= 3
        goProgressView = true
        
        // Reset selections
        pressOrder.removeAll()
        pressCount = 0
        
    }
}

#Preview{
    CO2FilterView()
}

