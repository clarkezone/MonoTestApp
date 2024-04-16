//
//  SliderBindingTestView.swift
//  MonoTestApp
//
//  Created by James Clarke on 4/16/24.
//

//import Sliders
import SwiftUI

#if COOL
struct SliderBindingTestView: View {
    @State var value = 0.5
    @State var range = 0.2...0.8
    @State var x = 0.5
    @State var y = 0.5
    
    var body: some View {
        Group {
            ValueSlider(value: $value)
            RangeSlider(range: $range)
            PointSlider(x: $x, y: $y)
        }
    }
}

#Preview {
    SliderBindingTestView()
}
#endif
