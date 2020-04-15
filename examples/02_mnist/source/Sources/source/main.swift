import Foundation
import Just
import Path
let _code_git_version  = "d490f33b5cfa3b03f11b0e56d9dcd851498fdc38"
let _code_generation_time  = "01:36:05 of Thursday, 2020-04-16 (GMT+1)"
public extension String {@discardableResult func shell (_ args: String...) -> String{
            let (task, pipe)  = (Process(), Pipe())
        task.executableURL=URL(fileURLWithPath: self)
    (task.arguments, task.standardOutput)=(args, pipe)
    do {
                try task.run()
}catch  {
                print("unexpected error: \(error).")
}
        let data  = pipe.fileHandleForReading.readDataToEndOfFile()
    return (String(data: data, encoding: String.Encoding.utf8)) ?? ("")
}}
print("/bin/ls".shell("-lh"))
// 