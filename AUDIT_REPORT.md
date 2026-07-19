# Audit Report — Uncommitted Ordering / Live Activity Changes

**Date:** 2026-07-19
**Scope:** Uncommitted working-tree changes only (`git status` at time of audit):

- `M  Devkeeters_26.xcodeproj/project.pbxproj`
- `M  Devkeeters_26.xcodeproj/xcuserdata/.../xcschememanagement.plist`
- `M  Devkeeters_26/ContentView.swift`
- `?? Devkeeters_26/Ordering/` (`OrderingCoordinator.swift`, `ZomatoService.swift`, `PlaceZomatoOrderIntent.swift`, `OneBrainShortcuts.swift`)
- `?? Devkeeters_26/ViewModels/OrderViewModel.swift`
- `?? Devkeeters_26Tests/OrderingCoordinatorTests.swift`
- `?? Devkeeters_26Widget/` (Live Activity widget extension target)

**Type:** Combined security + code quality/architecture review.

This is Milestone 3–4 work: a mock Zomato ordering flow reachable from both touch (`ContentView` → `OrderViewModel`) and Siri (`PlaceZomatoOrderIntent`), funneled through one shared `OrderingCoordinator`, driving a new `OrderLiveActivityWidget` extension target.

---

## Summary

No exploitable security vulnerabilities were found — the flow is entirely on-device (FoundationModels routing, canned menu data, no network calls, no persisted PII, no secrets). The two most important findings are **build/project-integrity risks**, not security bugs: an Xcode project-format downgrade and a missing framework link for the new widget target. There is also one real (low-probability) concurrency race in the order-progress state machine.

| # | Severity | Finding |
|---|----------|---------|
| 1 | High | `project.pbxproj` was resaved by an older Xcode, downgrading `objectVersion` 110→77 and stripping `validationLevel` |
| 2 | High | Widget extension imports `FoundationModels` via `RoutedIntent.swift` but never links `FoundationModels.framework` |
| 3 | Medium | Stale Live Activity update can briefly clobber state after an order is superseded |
| 4 | Medium | Widget target pulls in the full `RoutedIntent.swift` (incl. `@Generable`/FoundationModels surface) just for one enum |
| 5 | Low | `PlaceZomatoOrderIntent.perform()` has no catch-all for non-`OrderingCoordinatorError` throws |
| 6 | Low | `OrderingCoordinatorError.errorDescription!` force-unwrap is safe today but structurally fragile |
| 7 | Low | Test synchronizes on a hardcoded `Task.sleep(50ms)` instead of a deterministic signal |
| 8 | Info | `DEVELOPMENT_TEAM` is now committed in plaintext in `project.pbxproj` |

---

## High Severity

### 1. Project file was resaved by a different (older) Xcode, downgrading its format

`git diff Devkeeters_26.xcodeproj/project.pbxproj` shows:

```diff
-	objectVersion = 110;
+	objectVersion = 77;
...
-	validationLevel = 1;
-}
+}
```

...plus every `XCBuildConfiguration` comment being rewritten from the verbose form (`/* Debug configuration for PBXNativeTarget "Devkeeters_26" */`) to the terse form (`/* Debug */`). Both are textbook signatures of the file being opened and saved by an Xcode version older than the one that last touched it, rather than a hand-edit.

This matches a known risk already on file for this project: **there are two Xcode installs on this machine, and the 27.0 beta must be used** (per prior build-status notes). If the widget target in this diff was added from the non-beta Xcode, the project has now been silently downgraded from whatever newer format 110 represented (consistent with `IPHONEOS_DEPLOYMENT_TARGET = 27.0` elsewhere in the file, i.e. an Xcode 27 beta project) down to format 77.

**Risk:** re-opening in the beta Xcode may prompt a project-format upgrade, silently re-strip settings again on next save from either install, or in the worst case corrupt target/scheme references if the two Xcode versions disagree on schema for the newer `PBXFileSystemSynchronizedRootGroup` / package-product-dependency fields already present in this file.

**Recommendation:** open and save this project exclusively from the Xcode 27.0 beta going forward; confirm `objectVersion` stays at whatever value the beta writes, and treat any future downgrade in a diff as a signal the wrong Xcode was used.

### 2. Widget extension target is missing `FoundationModels.framework`

The new `OrderLiveActivityWidget` target's Sources phase compiles `RoutedIntent.swift` (added to the widget so it gets `ServiceDomain`, since `OrderActivityAttributes` embeds a `ServiceDomain`):

```
3AF0C8B360C8D3A2432DAA97 /* Sources */ = {
    files = (
        ... OrderLiveActivityWidgetBundle.swift,
        ... OrderLiveActivityWidget.swift,
        ... RoutedIntent.swift,
        ... OrderActivityAttributes.swift,
    );
};
```

But `RoutedIntent.swift` starts with `import FoundationModels` and both `RoutedIntent` and `SecondaryAction` are marked `@Generable` (a FoundationModels macro). The widget target's Frameworks phase only links:

```
06088C43E21EB828D790EBB8 /* Frameworks */ = {
    files = (
        Foundation.framework,
        WidgetKit.framework,
        SwiftUI.framework,
        ActivityKit.framework,
    );
};
```

`FoundationModels.framework` is not present. Extensions get their own process and load their own dependency graph — an unlinked-but-imported system framework typically manifests as a build error, or at best a "Library not loaded: FoundationModels" failure the first time the extension process actually launches (e.g., first Live Activity render on the Lock Screen/Dynamic Island).

**Recommendation:** either add `FoundationModels.framework` to the widget's Frameworks build phase, or (preferred, see #4) stop compiling `RoutedIntent.swift` into the widget at all and move `ServiceDomain` into its own file that doesn't import `FoundationModels`.

---

## Medium Severity

### 3. Superseding an order can let a stale Live Activity update overwrite fresh state

`OrderingCoordinator.placeOrder` (`Devkeeters_26/Ordering/OrderingCoordinator.swift:108-146`):

```swift
progressTask?.cancel()
progressTask = nil
if lastOrder != nil {
    await liveActivity.end()   // <- suspension point; old task can resume here
    lastOrder = nil
}
state = .placing
```

`beginAutoProgress`'s loop (`OrderingCoordinator.swift:148-163`) only checks `Task.isCancelled` immediately after `clock.sleep(...)` returns. Cooperative cancellation means: if the old task is currently suspended *inside* `await liveActivity.update(...)` (not inside the sleep) at the moment `progressTask?.cancel()` fires, that in-flight update call is not interrupted — it completes and executes `state = .active(statusText: step.status, ...)`, which can land *after* the new `placeOrder` call has already set `state = .placing` (or later, `.active` for the new order), because `await liveActivity.end()` above yields the MainActor back to the old task.

**Impact:** a transient state glitch — the UI can briefly show the *previous* order's status text/progress after a new order has already been placed — under rapid re-ordering (e.g., double-tapping "Order", or two Siri invocations close together). `test_placeOrder_supersedingOrder_endsPreviousLiveActivityFirst` doesn't catch this because it uses `stepInterval: 9999`, which guarantees the old task is parked in `sleep`, not mid-`update`, when cancellation happens.

**Recommendation:** guard the state writes in `beginAutoProgress`'s loop with an ownership check (e.g., compare against a token/order-id captured at task start) before mutating `state`/`lastOrder`, or re-check `Task.isCancelled` immediately before each `state = ...` assignment.

### 4. Widget target unnecessarily depends on the full brain-routing surface

Per finding #2, the only thing the widget needs from `RoutedIntent.swift` is the four-line `ServiceDomain` enum — but the file also carries `RoutedIntent`, `SecondaryAction`, two `@Guide`-annotated `@Generable` structs, and the `FoundationModels` import into the extension's compiled sources. This is more coupling than an extension should have to the app's LLM-routing layer, and is the root cause of finding #2.

**Recommendation:** split `ServiceDomain` out into its own file (e.g., `Devkeeters_26/Models/ServiceDomain.swift`) with no `FoundationModels` import, and share only that file with the widget target. Keep `RoutedIntent`/`SecondaryAction` app-only.

---

## Low Severity

### 5. No catch-all in `PlaceZomatoOrderIntent.perform()`

```swift
func perform() async throws -> some IntentResult & ProvidesDialog {
    do {
        let summary = try await OrderingCoordinator.shared.placeOrder(from: orderText)
        return .result(dialog: "Placing your order for \(summary.title). I'll keep you posted on the status.")
    } catch let error as OrderingCoordinatorError {
        return .result(dialog: "\(error.errorDescription ?? "Sorry, I couldn't place that order.")")
    }
}
```

Today `placeOrder` only ever throws `OrderingCoordinatorError` (every internal throw site wraps into it), so this is exhaustive in practice. But there's no defensive `catch` for anything else, so if a future edit to `OrderingCoordinator` lets a raw error type escape, Siri will surface a generic system failure dialog instead of a natural-language one, and it'll fail silently (no compiler warning) since `perform()` is itself `throws`.

**Recommendation:** add a trailing `catch { return .result(dialog: "Sorry, I couldn't place that order.") }` for defense in depth.

### 6. Force-unwrapped `errorDescription!`

`OrderingCoordinatorError.errorDescription` is `String?` (a `LocalizedError` requirement), but every switch case returns a non-nil string, and all three throw sites in `OrderingCoordinator.swift` immediately do `mapped.errorDescription!`. It's safe today only because the switch is exhaustive and never falls through to `nil`. A plain non-optional `var message: String` on the enum (used directly, with `errorDescription` implemented in terms of it) would remove the need to force-unwrap a protocol-mandated `Optional` at every call site.

### 7. Flaky-by-construction test synchronization

`OrderingCoordinatorTests.swift:19`:

```swift
try await Task.sleep(for: .milliseconds(50)) // let the detached progress Task drain
```

This is a fixed-delay sleep standing in for "wait until the progress task has run to completion." `InstantClock.sleep(seconds:)` returns immediately, so the progress task's four iterations plus final `end()`/`state = .idle` all have to complete within the 50ms window on whatever machine runs the test — normally fast, but under CI contention or a slow simulator this is a plausible source of intermittent failure.

**Recommendation:** have `OrderingCoordinator` expose a way to await the in-flight `progressTask` (or have the test hold a reference to it) instead of a wall-clock sleep.

---

## Informational

### 8. `DEVELOPMENT_TEAM` committed to `project.pbxproj`

The new widget target's build settings hardcode `DEVELOPMENT_TEAM = 27CZ8S8BXY`. This is a public Apple Developer Team ID, not a secret, and matches normal Xcode-generated project files — flagging only because it's now version-controlled; worth a second look before this repository is ever made public or shared outside the current owner.

---

## What's clean

- **No network egress in the new code.** `ZomatoService` is a pure in-memory canned menu lookup; `OrderingBrain` (unchanged, pre-existing) routes entirely through on-device `FoundationModels`. No API keys, no `URLSession`, no external calls anywhere in this diff.
- **No persisted or transmitted PII.** Order text and Live Activity content stay in memory/ActivityKit; nothing is written to disk or sent off-device.
- **Strict MVVM boundary is respected.** `ContentView` only talks to `OrderViewModel`; `OrderViewModel` and `PlaceZomatoOrderIntent` both funnel through the same `OrderingCoordinator.placeOrder`, matching the file-header comments' stated intent and avoiding logic duplication between the Siri and touch paths.
- **Coordinator is well-seamed for testing** (`IntentRouting`, `LiveActivityDriving`, `OrderProgressClock` protocols), and `OrderingCoordinatorTests` covers the three behaviors that matter most: happy path progression, unsupported-domain rejection, and superseding-order cleanup (modulo finding #7's synchronization style).
- **`NSSupportsLiveActivities = YES`** is correctly set in the main app's Info.plist keys (`project.pbxproj:553,599`) for both Debug and Release — a common Live Activity setup mistake that isn't present here.
