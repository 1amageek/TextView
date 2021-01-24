//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2021/01/24.
//

import SwiftUI
import TextView

struct ContentView: View {

    @State var text: String = ""

    var body: some View {
        TextView($text, placeholder: "wwwww")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
