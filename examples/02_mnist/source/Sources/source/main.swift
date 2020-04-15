import Foundation
import Just
import Path

let _code_git_version = "76c40012a8587bf4a8741d47e8431c287ae3d5c1"
let _code_generation_time = "01:53:06 of Thursday, 2020-04-16 (GMT+1)"
extension String {
  @discardableResult public func shell(_ args: String...) -> String {
    let (task, pipe) = (Process(), Pipe())
    task.executableURL = URL(fileURLWithPath: self)
    (task.arguments, task.standardOutput) = (args, pipe)
    do {
      try task.run()
    } catch {
      print("unexpected error: \(error).")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return (String(data: data, encoding: String.Encoding.utf8)) ?? ("")
  }
}
print("/bin/ls".shell("-lh"))
// 
