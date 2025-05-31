//
//  End.swift
//  watchtest Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct End: View {

    let synthesizer = AVSpeechSynthesizer()
    let message =
        "게임이 끝났습니다"

    var body: some View {
        NavigationStack {
            VStack {
                Text(message)
            }.onAppear { speak(message) }
        }
    }
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }
}

#Preview {
    End()
}
