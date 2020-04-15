Import Foundation
Import Just
Import Path
let _code_git_version  = "356bf3931a3687984695bcd4cccf0b21c208812d";
let _code_generation_time  = "00:42:00 of Thursday, 2020-04-16 (GMT+1)";
public extension String {@discardableResult func shell (_, args: String...) -> String{
            let (task, pipe)  = (Process(), Pipe());
        task.executableURL=URL(fileURLWithPath, self)
}}