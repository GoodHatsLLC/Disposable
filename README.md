# Disposable 🗑️

A `Disposable` is an async oriented cancellation handler.  
Disposables can represent handles to any long running behaviors like Combine `Cancellables` and Swift `Tasks`.  
`Disposable` is used internally within the [https://github.com/GoodHatsLLC/StateTree](`StateTree` framework) and [https://github.com/GoodHatsLLC/Emitter](`Emitter` reactive streams library).

## Purpose

A `Disposable` is intended to bridge different cancellable sources including:
* Combine's `Cancellable's` `cancel()`
* Swift's `Task's` `cancel()`
* RxSwift's `Disposable's` `dispose()`

This package also provides a `DisposableStage` which allows for grouping `Disposables`
and handling them as a single entity — i.e. as Combine uses `Set<AnyCancellable>`
and RxSwift uses `DisposeBag`.
