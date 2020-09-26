//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-09-26.
//

import Foundation

enum KeytoolError: Error {
    /// Keytool exited with a non zero exit code
    case failed
}

private func keytool(arguments: [String]) throws  {
    let path = "/usr/bin/keytool"
    let process = Process()
    process.launchPath = path
    process.arguments = arguments
    process.launch()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw KeytoolError.failed
    }
}

func generateKeystores(keystorePath: String,
                       truststorePath: String,
                      alias: String,
                      validity: Int,
                      password: String,
                      distinguishedName: String,
                      dnsName: String) throws {
    if FileManager.default.fileExists(atPath: keystorePath) {
        try FileManager.default.removeItem(atPath: keystorePath)
    }

    try keytool(arguments: ["-keystore", keystorePath,
                        "-alias", dnsName,
                        "-validity", "\(validity)",
                        "-genkey",
                        "-keyalg", "RSA",
                        "-storepass", password,
                        "-keypass", password,
                        "-dname", distinguishedName,
                        "-ext", "SAN=dns:\(dnsName)"
                    ])
    let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    let caKeyPath = temporaryDirectory.appendingPathComponent("ca-key.pem")
    let caCertPath = temporaryDirectory.appendingPathComponent("ca-cert.pem")
    let certPath = temporaryDirectory.appendingPathComponent("server-cert.pem")
    // Generate a key for the CA certificate
    try openssl(arguments: ["genrsa", "-out", caKeyPath.path, "2048"])
    // Generate the CA
    try openssl(arguments: ["req", "-new", "-x509",
                            "-key", caKeyPath.path, "-out",
                            caCertPath.path, "-days", "\(validity)",
                            "-subj", "/C=CA/ST=Ontario/O=Kafka-NIO/CN=Kafka Test CA"])
    // Import the CA into the trust truststore
    try keytool(arguments: ["-keystore", truststorePath, "-alias", "CARoot", "-import",
                        "-file", caCertPath.path, "-storepass", password, "-noprompt"])

    try keytool(arguments: ["-keystore", keystorePath, "-alias", "localhost", "-certreq",
                            "-file", certPath.path, "-storepass", password])
    try openssl(arguments: ["x509", "-req",
                            "-CA", caCertPath.path,
                            "-CAkey", caKeyPath.path,
                            "-in", certPath.path,
                            "-out", certPath.path,
                            "-days", "\(validity)",
                            "-CAcreateserial",
                            "-passin", "pass:\(password)"])

    try keytool(arguments: ["-keystore", keystorePath, "-alias", "CARoot", "-import", "-file", caCertPath.path, "-storepass", password, "-noprompt"])
    try keytool(arguments: ["-keystore", keystorePath, "-alias", dnsName, "-import", "-file",  certPath.path, "-storepass", password, "-noprompt"])
}

enum OpenSSLError: Error {
    /// OpenSSL exited with a non zero exit code
    case failed
}

private func openssl(arguments: [String]) throws {
    let path = "/usr/bin/openssl"
    let process = Process()
    process.launchPath = path
    process.arguments = arguments
    process.launch()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw OpenSSLError.failed
    }
}


