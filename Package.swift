// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "Disposable",
  platforms: [
    .macOS("12.3"),
    .iOS("15.4"),
    .tvOS("15.4"),
    .watchOS("8.5"),
    .macCatalyst("15.4"),
  ],
  products: [
    .library(
      name: "Disposable",
      targets: [
        "Disposable",
      ]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Disposable",
      dependencies: [],
      swiftSettings: Env.swiftSettings
    ),
    .testTarget(
      name: "DisposableTests",
      dependencies: ["Disposable"]
    ),
  ]
)

// MARK: - Env

private enum Env {
  static let swiftSettings: [SwiftSetting] = {
    var settings: [SwiftSetting] = []
    settings.append(contentsOf: [
      .enableUpcomingFeature("ConciseMagicFile"),
      .enableUpcomingFeature("ExistentialAny"),
      .enableUpcomingFeature("StrictConcurrency"),
      .enableUpcomingFeature("ImplicitOpenExistentials"),
      .enableUpcomingFeature("BareSlashRegexLiterals"),
    ])
    return settings
  }()
}
