import Foundation
import Just
import Path
import TensorFlow
let _code_git_version  = "15c965f7f2d998b55e2b18a8e2fb78df2b8d4931"
let _code_generation_time  = "11:14:43 of Saturday, 2020-04-18 (GMT+1)"
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
public func downloadFile (_ url: String, dest: String? = nil, force: Bool = false){
            let dest_name  = (dest) ?? (((Path.cwd)/(url.split(separator: "/").last!)).string)
    let url_dest  = URL(fileURLWithPath: (dest) ?? (((Path.cwd)/(url.split(separator: "/").last!)).string))
    if  ((!(force))&&((Path(dest_name))!.exists))  {
                        return
}
    print("Downloading \(url)...")
        if      let cts  = Just.get(url).content  {
                do {
                        try cts.write(to: URL(fileURLWithPath: dest_name))
}catch  {
                        print("Can't write to \(url_dest).\n \(error)")
}
} else {
                print("Can't reach \(url).")
}
}
downloadFile("https://storage.googleapis.com/cvdf-datasets/mnist/train-images-idx3-ubyte.gz")
func loadMNIST (training: Bool, labels: Bool, path: Path, flat: Bool) -> Tensor<Float>{
            let split  = (training) ? ("train") : ("t10k")
    let kind  = (labels) ? ("labels") : ("images")
    let batch  = (training) ? (60000) : (10000)
    let shape: TensorShape  = (labels) ? ([batch]) : ((flat) ? ([batch, 784]) : ([batch, 28, 28]))
    let dropK  = (labels) ? (8) : (16)
    let baseURL  = "https://storage.googleapis.com/cvdf-datasets/mnist/"
    let fname  = (split+"-"+kind+"-idx\(labels ? 1 : 3)-ubyte")
    let file  = ((path)/(fname))
    if  !(file.exists)  {
                                let gz  = ((path)/("\(fname).gz")).string
        downloadFile("\(baseURL)\(fname).gz", dest: gz)
        "/bin/gunzip".shell("-fq", gz)
}
        let data  = try! Data(contentsOf: URL(fileURLWithPath: file.string)).dropFirst(dropK)
    if  labels  {
                return Tensor(data.map, Float.init)
} else {
                return Tensor(data.map, Float.init).reshaped(to: shape)
}
}
func loadMNIST (training: Bool, labels: Bool, path: Path, flat: Bool) -> Tensor<Int32>{
            let split  = (training) ? ("train") : ("t10k")
    let kind  = (labels) ? ("labels") : ("images")
    let batch  = (training) ? (60000) : (10000)
    let shape: TensorShape  = (labels) ? ([batch]) : ((flat) ? ([batch, 784]) : ([batch, 28, 28]))
    let dropK  = (labels) ? (8) : (16)
    let baseURL  = "https://storage.googleapis.com/cvdf-datasets/mnist/"
    let fname  = (split+"-"+kind+"-idx\(labels ? 1 : 3)-ubyte")
    let file  = ((path)/(fname))
    if  !(file.exists)  {
                                let gz  = ((path)/("\(fname).gz")).string
        downloadFile("\(baseURL)\(fname).gz", dest: gz)
        "/bin/gunzip".shell("-fq", gz)
}
        let data  = try! Data(contentsOf: URL(fileURLWithPath: file.string)).dropFirst(dropK)
    if  labels  {
                return Tensor(data.map, Int32.init)
} else {
                return Tensor(data.map, Int32.init).reshaped(to: shape)
}
}
// 