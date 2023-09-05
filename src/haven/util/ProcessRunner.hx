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

        var oldCwd = Sys.getCwd();
        if (cwd != null) {
            Sys.setCwd(cwd);
        }

        var p = new Process(command, args);

        if (stdout) {
            var outThread = Thread.create(printStreamThread);
            outThread.sendMessage(p.stdout);
        }

        if (stderr) {
            var errThread = Thread.create(printStreamThread);
            errThread.sendMessage(p.stderr);
        }
        
        exitCode = p.exitCode(true);
        p.close();

        Sys.setCwd(oldCwd);
    }

    private function printStreamThread() {
        var stream:Input = Thread.readMessage(true);
        while (true) {
            try {
                var line = stream.readLine();
                Sys.println("     " + line);
            } catch (e:Eof) {
                break;
            } catch (e:Dynamic) {
                trace(e);
                break;
            }
        }
    }
}