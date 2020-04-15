Import Foundation
Import Just
Import Path
let _code_git_version  = "1ed69f33e4df9862f78c64cd87242ad879bd492d";
let _code_generation_time  = "00:54:25 of Thursday, 2020-04-16 (GMT+1)";
public extension String {@discardableResult func shell (_, args: String...) -> String{
            let (task, pipe)  = (Process(), Pipe());
        task.executableURL=URL(fileURLWithPath: self)
}}