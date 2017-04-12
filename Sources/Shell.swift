//
//  Shell.swift
//  House
//
//  Created by Shaun Merchant on 14/08/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// An interface to execute arbitrary shell commands.
///
/// - Important: Improper use could cause severe security issues. Avoid use altogether, but if use is required ensure commants are fixed and secure.
public struct Shell {
    
    /// The location of the bash environment binary.
    private static let bashEnvironment = "/usr/bin/env"
    
    
    /// Execute a program with arguments in shell.
    ///
    /// - Parameters:
    ///   - program: The program to execute, defaulting to the bash environment.
    ///   - arguments: The arguments to pass the program.
    /// - Returns: The reponse from shell execution.
    ///
    /// - Important: This will only return when the shell task has finished executing.
    @discardableResult
    public static func execute(_ program: String = Shell.bashEnvironment, arguments: [String]) -> String {
        #if os(Linux)
            let task = Task()
            task.launchPath = program
            task.arguments = arguments
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            if let output = output {
                return output
            }
            return ""
        #elseif os(macOS)
            let task = Process()
            task.launchPath = program
            task.arguments = arguments
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            if let output = output {
                return output
            }
            return ""
        #else
            fatalError("Unsupported OS")
        #endif
    }
    
    
    /// Execute a command in a bash shell.
    ///
    /// - Parameter command: The command to execute in bash.
    /// - Returns: The reponse from shell execution.
    ///
    /// - Important: This will only return when the shell task has finished executing.
    @discardableResult
    public static func execute(_ command: String) -> String {
        return Shell.execute(Shell.bashEnvironment, arguments: ["bash", "-c", command])
    }
    
    
    /// An interface to execute arbitrary shell commands asynchronously.
    ///
    /// - important: Improper use could cause severe security issues. Avoid use altogether, but if use is required ensure commants are fixed and secure.
    public static let async = AsynchronousShell()
    
    
    /// A structure to enable shell functions to execute asynchronously with callbacks to pipe output.
    public struct AsynchronousShell {
        
        /// The concurrent queue to handle execution.
        private static let concurrentQueue = DispatchQueue(label: "houseShell", qos: .userInitiated, attributes: .concurrent)

        /// Execute a program asynchronously in shell.
        ///
        /// - Parameters:
        ///   - program: The program to execute, defaulting to the bash environment.
        ///   - arguments: The arguments to pass the program.
        ///   - responder: The callback to pass the output of shell to after asynchronous execution has finished.
        /// - Returns: The reponse from shell execution.
        ///
        /// - Important: This will only return when the shell task has finished executing.
        public static func execute(_ program: String = Shell.bashEnvironment, arguments: [String], with responder: ((String) -> ())? = nil) {
            self.concurrentQueue.async {
                let response = Shell.execute(program, arguments: arguments)
                if let responder = responder {
                    responder(response)
                }
            }
        }

        /// Execute a command asynchronously in shell.
        ///
        /// - Parameter command: The command to execute in bash.
        public static func execute(_ command: String, with responder: ((String) -> ())? = nil) {
            self.concurrentQueue.async {
                let response = Shell.execute(Shell.bashEnvironment, arguments: ["bash", "-c", command])
                if let responder = responder {
                    responder(response)
                }
            }
        }
    }
    
}
