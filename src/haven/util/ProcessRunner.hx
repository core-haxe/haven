package haven.util;

import haxe.io.Eof;
import haxe.io.Input;
import sys.thread.Thread;
import sys.io.Process;

class ProcessRunner {
    public var command:String;
    public var args:Array<String>;
    public var cwd:String;
    public var indent:String = "";
    public var ignoreExitCode:Bool = false;

    public var exitCode:Null<Int>;

    public var result:String;
    public var error:String;

    public function new(command:String, args:Array<String> = null, cwd:String = null, indent:String = "") {
        this.command = command;
        this.args = args;    
        this.cwd = cwd;
        this.indent = indent;
    }

    public function run(stdout:Bool = true, stderr:Bool = true):String {
        if (args == null) {
            //args = [];
        }

        var oldCwd = null;
        if (cwd != null) {
            oldCwd = Sys.getCwd();
            Sys.setCwd(cwd);
        }

        var p = new Process(command, args);

        var stdoutBuffer = new StringBuf();
        var outThread = Thread.create(printStreamThread);
        outThread.sendMessage(p.stdout);
        outThread.sendMessage(stdout);
        outThread.sendMessage(indent);
        outThread.sendMessage(stdoutBuffer);

        var stderrBuffer = new StringBuf();
        var errThread = Thread.create(printStreamThread);
        errThread.sendMessage(p.stderr);
        errThread.sendMessage(stderr);
        errThread.sendMessage(indent);
        errThread.sendMessage(stderrBuffer);
        
        exitCode = p.exitCode(true);
        
        p.close();

        result = stdoutBuffer.toString();

        if (oldCwd != null) {
            Sys.setCwd(oldCwd);
        }

        if (!ignoreExitCode && exitCode != 0) {
            error = stderrBuffer.toString();
            throw error;
        }

        return result;
    }

    private function printStreamThread() {
        var stream:Input = Thread.readMessage(true);
        var print:Bool = Thread.readMessage(true);
        var indent:String = Thread.readMessage(true);
        var result:StringBuf = Thread.readMessage(true);
        printStreamContent(stream, print, indent, result);
    }

    private static function printStreamContent(stream:Input, print:Bool = true, indent:String = "", result:StringBuf = null) {
        while (true) {
            try {
                var bytes = stream.readLine();
                if (bytes.length == 0) {
                    break;
                }
                if (print) {
                    //Sys.stdout().write(bytes);
                    Sys.println(indent + bytes);
                }
                if (result != null) {
                    result.add(bytes);
                    result.add("\n");
                }
                //Sys.print(bytes.toString());
            } catch (e:Eof) {
                break;
            } catch (e:Dynamic) {
                trace(e);
                break;
            }
        }
    }
}