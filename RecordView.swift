//
//  SwiftUIView.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/17/24.
//

import SwiftUI
import ARKit

struct RecordView: View {
    @EnvironmentObject var dataController: DataController
    @State private var isRecording = false
    @EnvironmentObject var viewModel: ARFaceViewViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isToggled: Bool
    
    
    var body: some View {
        ZStack {
            ARFaceView(viewModel: viewModel, isToggled: $isToggled)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Toggle(isOn: $isToggled) {

                    }
                    Text(isToggled ? "Mustache" : "Goatee")
                }
                HStack {
                    Spacer()
                    Button(action: {
                        if isRecording {
                            viewModel.stopRecording()
                            dismiss()
                        } else {
                            viewModel.startRecording()
                        }
                        isRecording.toggle()
                    }) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.red, lineWidth: 4)
                            )
                            .padding()
                    }
                    Spacer()
                }
            }
        }
    }
}
