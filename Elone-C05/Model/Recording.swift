//
//  Recording.swift
//  Elone-C05
//
//  Created by Walker Valentinus Simanjuntak on 02/09/26.
//

import Foundation

struct Recording: Identifiable {
    let id: UUID
    let audioURL: URL
    let createdAt: Date
    let duration: TimeInterval
    var transcript: String?
}
