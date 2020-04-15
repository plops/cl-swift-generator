import Foundation
import Just
import Path
let _code_git_version  = "5e88a4ad0357f612a857686ac258d62c81bd3bb3"
let _code_generation_time  = "01:08:27 of Thursday, 2020-04-16 (GMT+1)"
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