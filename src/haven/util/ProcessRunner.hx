package haven.util;

import haxe.io.Eof;
import haxe.io.Input;
import sys.thread.Thread;
import sys.io.Process;

class ProcessRunner {
    public var command:String;
    public var args:Array<String>;
    public var cwd:String;

    public var exitCode:Null<Int>;

    public function new(command:String, args:Array<String> = null, cwd:String = null) {
        this.command = command;
        this.args = args;    
        this.cwd = cwd;
    }

    public function run(stdout:Bool = true, stderr:Bool = true) {
        if (args == null) {
            //args = [];
        }

        var oldCwd = null;
        if (cwd != null) {
            oldCwd = Sys.getCwd();
            Sys.setCwd(cwd);
        }

        var p = new Process(command, args);

        var outThread = Thread.create(printStreamThread);
        outThread.sendMessage(p.stdout);
        outThread.sendMessage(stdout);

        var errThread = Thread.create(printStreamThread);
        errThread.sendMessage(p.stderr);
        errThread.sendMessage(stderr);
        
        exitCode = p.exitCode(true);

        printStreamContent(p.stdout, stdout);
        printStreamContent(p.stderr, stderr);

        p.close();

        if (oldCwd != null) {
            Sys.setCwd(oldCwd);
        }
    }

    private function printStreamThread() {
        var stream:Input = Thread.readMessage(true);
        var print:Bool = Thread.readMessage(true);
        printStreamContent(stream, print);
    }

    private static function printStreamContent(stream:Input, print:Bool = true) {
        while (true) {
            try {
                var bytes = stream.readLine();
                if (bytes.length == 0) {
                    break;
                }
                if (print) {
                    //Sys.stdout().write(bytes);
                    Sys.println(bytes);
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