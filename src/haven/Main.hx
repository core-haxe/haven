package haven;

import haxe.CallStack;
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
        if (!flags.contains("dont-print-header")) {
            Sys.println("\nstarting execution");
            Sys.println(" - app dir: " + Paths.appDir);
            Sys.println(" - working dir: " + Paths.workingDir);
        }

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
        if (!flags.contains("dont-print-header")) {
            Sys.println(" - haven file: " + havenFile);
        }

        try {
            var rootHavenFile = findRootHaven(Paths.workingDir);
            var modulesToExecute = [];
            if (rootHavenFile != null && rootHavenFile != havenFile) {
                var root = Project.fromFile(rootHavenFile);
                var module = Project.fromFile(havenFile);
                if (module.isolated) {
                    rootHavenFile = havenFile;
                    modulesToExecute = [module];
                } else {
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
            }

            // were going to temporarily load the project to see if any of the chains
            // has a skipModuleCheck attribute, if found, we'll then NOT throw an 
            // exception if modules cant be found - this is important for actions
            // like creating entire source trees since the modules wont be there
            // initially
            var throwExceptionOnModuleNotFound = true;
            var temp = Project.fromFile(havenFile, false);
            for (command in commands) {
                var chain = temp.chains.get(command);
                if (chain != null) {
                    if (chain.skipModuleCheck) {
                        throwExceptionOnModuleNotFound = false;
                    }
                }
            }

            var project = Project.fromFile(havenFile, throwExceptionOnModuleNotFound);
            if (!flags.contains("dont-print-header")) {
                Sys.println(" - root haven file: " + havenFile);
            }
            var rootHavenFileParts = rootHavenFile.split("/");
            rootHavenFileParts.pop();
            Paths.rootDir = Path.normalize(rootHavenFileParts.join("/"));
            //project.printStructure();
            Sys.setCwd(project.path);

            if (!flags.contains("dont-print-header")) {
                Sys.println(" - commands: " + commands.join(", "));
                if (flags.length > 0) {
                    Sys.println(" - flags: " + flags.join(", "));
                }
            }

            if (project.isolated) {
                project.properties.merge(modulesToExecute[0].properties);
            }

            project.exec(commands, modulesToExecute, flags);
        } catch (e:Dynamic) {
            Sys.println("");
            Sys.println(e);
            printStack(CallStack.exceptionStack());
            Sys.println("\nexecution errored!\n");
        }
    }

    private static function printStack(stack:Array<StackItem>) {
        for (item in stack) {
            switch (item) {
                case FilePos(s, file, line, column):
                    var sb = new StringBuf();
                    sb.add("  ");
                    sb.add(file);
                    if (line != null) {
                        sb.add(line);
                    }
                    if (column != null) {
                        sb.add(":");
                        sb.add(column);
                    }
                    Sys.println(sb.toString());
                case _:
                    trace(">>>>>>>>>>>>>>>>>>>>> UNKNOWN STACK ITEM", item);
            }
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
                    break;
                }
                //break;
            }
        }
        return s;
    }
}