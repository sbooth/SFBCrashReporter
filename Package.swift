// swift-tools-version: 5.6
//
// SPDX-FileCopyrightText: 2026 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/SFBCrashReporter
//

import PackageDescription

let package = Package(
    name: "SFBCrashReporter",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "SFBCrashReporter",
            targets: [
                "SFBCrashReporter",
            ]),
    ],
    targets: [
        .target(
            name: "SFBCrashReporter",
            resources: [
                .process("Resources"),
            ],
            linkerSettings: [
                .linkedFramework("Contacts"),
            ]),
        .testTarget(
            name: "SFBCrashReporterTests",
            dependencies: [
                "SFBCrashReporter",
            ]),
    ]
)
