//
//  UnitView.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 21.12.21.
//

import SwiftUI


struct UnitView: View {
    
    let value: String
    let unit: String
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(value)
                .font(.body.weight(.medium).monospacedDigit())
            Text(unit)
                .font(.caption2.weight(.medium))
        }.frame(minWidth: 60)
    }
    
}


struct UnitView_Previews: PreviewProvider {
    static var previews: some View {
        UnitView(value: "12", unit: "RPS")
    }
}
