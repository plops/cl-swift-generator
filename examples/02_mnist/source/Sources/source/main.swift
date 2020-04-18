import Foundation
import Just
import Path
import TensorFlow
let _code_git_version  = "392e6480300521d6d6b27e130066daa2c68cbdfc"
let _code_generation_time  = "11:28:30 of Saturday, 2020-04-18 (GMT+1)"
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
protocol ConvertibleFromByte: TensorFlowScalar {
        init(_ d: UInt8)
}
extension Float : ConvertibleFromByte {}
extension Int32 : ConvertibleFromByte {}
extension Data {
        func asTensor<T: ConvertibleFromByte> () -> Tensor<T>{
                return Tensor(map(T.init))
}
}
func loadMNIST<T: ConvertibleFromByte> (training: Bool, labels: Bool, path: Path, flat: Bool) -> Tensor<T>{
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
                return data.asTensor()
} else {
                return data.asTensor().reshaped(to: shape)
}
}
// 