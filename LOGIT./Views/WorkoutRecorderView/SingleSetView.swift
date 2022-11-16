//
//  SingleSetView.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 17.10.22.
//

import SwiftUI

struct SingleSetView: View {
    
    @ObservedObject var workoutSet: StandardSet
    
    var body: some View {
        VStack {
            HStack {
                Text(workoutSet.exercise?.name ?? "Select Exercise")
                    .font(.title.weight(.bold))
                NavigationChevron()
            }.frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                repetitionsView
                weightView
            }
        }.tileStyle()
    }
    
    // MARK: - Supporting Views
    
    private var repetitionsView: some View {
        HStack {
            Image(systemName: "arrow.counterclockwise")
                .fontWeight(.bold)
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                TextField("0", text: Binding(get: { String(workoutSet.repetitions) },
                                             set: { workoutSet.repetitions = Int64($0) ?? 0 }))
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text("RPS")
                    .font(.system(.caption, design: .rounded, weight: .bold))
            }
        }.padding()
            .background(Color.background)
            .cornerRadius(10)
    }
    
    private var weightView: some View {
        HStack {
            Image(systemName: "scalemass")
                .fontWeight(.bold)
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                TextField("0", text: Binding(get: { String(workoutSet.weight) },
                                             set: { workoutSet.weight = Int64($0) ?? 0 }))
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text(WeightUnit.used.rawValue.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .bold))
            }
        }.padding()
            .background(Color.background)
            .cornerRadius(10)
    }
    
}

struct SingleSetView_Previews: PreviewProvider {
    static var previews: some View {
        SingleSetView(workoutSet: Database.preview.fetch(WorkoutSet.self).first as! StandardSet)
    }
}
