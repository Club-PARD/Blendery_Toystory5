//
//  OptionButton.swift
//  Blendery
//
//  Created by 박영언 on 12/28/25.
//

import SwiftUI

struct OptionButton: View {
    @Binding var temperature: Temperature
    @Binding var size: Size

    var body: some View {
        VStack(spacing: 16) {
            TemperatureSegment(selected: $temperature)
            SizeSegment(selected: $size)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 247/255, green: 247/255, blue: 247/255, opacity: 1))
        )
        .frame(width: 176.34)
    }
}
