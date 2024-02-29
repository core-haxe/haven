package haven;

import haven.project.Project;
import sys.FileSystem;
import haxe.io.Path;

using haven.ProjectTools;
using StringTools;

class Main {

    static function main() {
        var args = Sys.args().copy();

        var cwd = null;
        if (args.length > 0) {
            cwd = args.pop();
        }

        var commands = args.copy();
        var flags = [];
        var finalCommands = [];
        for (c in commands) {
            if (c.startsWith("--")) {
                flags.push(c.substr(2));
            } else {
                finalCommands.push(c);
            }
        }

        commands = finalCommands;


        Paths.appDir = Path.normalize(Sys.getCwd());
        if (cwd != null) {
            Paths.workingDir = Path.normalize(cwd);
        }
        Sys.println("\nstarting execution");
        Sys.println(" - app dir: " + Paths.appDir);
        Sys.println(" - working dir: " + Paths.workingDir);

        var havenFile = Path.normalize(Paths.workingDir + "/haven.xml");
        if (!FileSystem.exists(havenFile)) {
            havenFile = Path.normalize(Paths.workingDir + "/.haven/haven.xml");
            if (!FileSystem.exists(havenFile)) {
                Sys.println("");
                Sys.println("ERROR: haven file not found");
                Sys.exit(1);
                return;
            }
        }
        Sys.println(" - haven file: " + havenFile);

        try {
            var rootHavenFile = findRootHaven(Paths.workingDir);
            var modulesToExecute = [];
            if (rootHavenFile != null && rootHavenFile != havenFile) {
                var root = Project.fromFile(rootHavenFile);
                var module = Project.fromFile(havenFile);
                var actualModule = root.findModule(module);
                var refModule = actualModule;
                while (refModule != null) {
                    modulesToExecute.push(refModule);
                    refModule = refModule.parentProject;
                }
                for (module in actualModule.allModules) {
                    if (!modulesToExecute.contains(module)) {
                        modulesToExecute.push(module);
                    }
                }
                havenFile = rootHavenFile;
            }
            var project = Project.fromFile(havenFile);
            Sys.println(" - root haven file: " + havenFile);
            //project.printStructure();
            Sys.setCwd(project.path);

            Sys.println(" - commands: " + commands.join(", "));
            if (flags.length > 0) {
                Sys.println(" - flags: " + flags.join(", "));
            }
            project.exec(commands, modulesToExecute, flags);
        } catch (e:Dynamic) {
            Sys.println("");
            Sys.println(e);
            Sys.println("\nexecution errored!\n");
        }
    }

    private static function findRootHaven(dir:String) {
        var parts = Path.normalize(dir).split("/");
        var s = null;
        while (parts.length > 0) {
            var current = parts.pop();
            var testPath1 = Path.normalize(parts.join("/") + "/haven.xml");
            var testPath2 = Path.normalize(parts.join("/") + "/.haven/haven.xml");
            if (!FileSystem.exists(testPath1) && !FileSystem.exists(testPath2)) {
                var candidate1 = Path.normalize(parts.join("/") + "/" + current + "/haven.xml");
                var candidate2 = Path.normalize(parts.join("/") + "/" + current + "/.haven/haven.xml");
                if (FileSystem.exists(candidate1)) {
                    s = candidate1;
                } else if (FileSystem.exists(candidate2)) {
                    s = candidate2;
                }
                break;
            }
        }
        return s;
    }
}