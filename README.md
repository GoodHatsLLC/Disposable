# Disposable 🗑️

A `Disposable` is a cancellation handler representing arbitrary long running work.

This library is used in the [`Emitter`](https://github.com/GoodHatsLLC/Emitter) reactive streams library and internally within the [`StateTree`](https://github.com/GoodHatsLLC/StateTree) framework.

## Purpose

A `Disposable` is intended to bridge different cancellable sources including:
* Combine's `Cancellable's` `cancel()`
* Swift's `Task's` `cancel()`
* RxSwift's `Disposable's` `dispose()`

This package also provides a `DisposableStage` which allows for grouping `Disposables`
and handling them as a single entity — i.e. as Combine uses `Set<AnyCancellable>`
and RxSwift uses `DisposeBag`.
