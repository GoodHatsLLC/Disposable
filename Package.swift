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
      name: "Disposable"
    ),
    .testTarget(
      name: "DisposableTests",
      dependencies: ["Disposable"]
    ),
  ]
)
