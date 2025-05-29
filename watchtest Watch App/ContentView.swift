//
//  ContentView.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/30/25.
//

import AVFoundation
import CoreMotion
import SwiftUI

struct ContentView: View {

    @State private var motionManager = CMMotionManager()
    @State private var middle: Double = 0.0
    @State private var state: String = "중간"

    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            Text("\(state)")
        }.onAppear {
            startMotion()
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func startMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            print("unavailable")

            return
        }
        motionManager.deviceMotionUpdateInterval = 0.1

        motionManager.startDeviceMotionUpdates(to: .main) {
            (deviceMotion: CMDeviceMotion?, error: Error?) in
            guard let data = deviceMotion, error == nil else {
                print(
                    "Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")"
                )
                return
            }

            let roll = data.attitude.roll
            let value = roll - self.middle
            if abs(value) > 0.3 {
                var newState = self.state

                if abs(value) < 0.05 {
                    newState = "중간"
                } else if value > 0 {
                    newState = "오른쪽"
                } else {
                    newState = "왼쪽"
                }

                if newState != self.state {
                    self.state = newState
                    print(newState)
                    self.speak(newState)
                }

                self.middle = roll
            }

            //            if abs(value) > 0.3 {
            //                if value == 0 {
            //                    state = "중간입니다"
            //                    print("중간입니다")
            //                } else if value > 0 {
            //                    state = "오른쪽입니다"
            //                    print("오른쪽")
            //                } else {
            //                    state = "왼쪽입니다"
            //                    print("왼쪽")
            //                }
            //                middle = roll
            //            }
        }

    }
}

#Preview {
    ContentView()
}
