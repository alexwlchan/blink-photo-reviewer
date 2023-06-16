import Foundation

/// A basic profiler for timing operations.
///
/// This is based on some code written by JeremyP on Stack Overflow.
/// See https://stackoverflow.com/a/24755958/1558022
/// 
struct Timer {
    private let start: DispatchTime
    private var elapsed: DispatchTime
    
    init() {
        self.start = DispatchTime.now()
        self.elapsed = start
    }
    
    mutating func printTime(_ label: String) -> Void {
        let now = DispatchTime.now()

        let totalInterval = Double(now.uptimeNanoseconds - self.start.uptimeNanoseconds) / 1_000_000_000
        let elapsedInterval = Double(now.uptimeNanoseconds - self.elapsed.uptimeNanoseconds) / 1_000_000_000

        self.elapsed = now
        
        print("Time to \(label):\n  \(elapsedInterval) seconds (\(totalInterval) total)")
    }
}
