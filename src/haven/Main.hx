package haven;

import haven.project.Project;
import sys.FileSystem;
import haxe.io.Path;

using haven.ProjectTools;

class Main {

    static function main() {
        var args = Sys.args().copy();

        var cwd = null;
        if (args.length > 0) {
            cwd = args.pop();
        }

        var commands = args.copy();

        Paths.appDir = Path.normalize(Sys.getCwd());
        Paths.workingDir = Path.normalize(cwd);
        Sys.println("\nstarting execution");
        Sys.println(" - app dir: " + Paths.appDir);
        Sys.println(" - working dir: " + Paths.workingDir);

        var havenFile = Path.normalize(Paths.workingDir + "/haven.xml");
        if (!FileSystem.exists(havenFile)) {
            trace("ERROR: haven file not found");
            Sys.exit(1);
            return;
        }

        try {
            var rootHavenFile = findRootHaven(Paths.workingDir);
            var modulesToExecute = [];
            if (rootHavenFile != null && rootHavenFile != havenFile) {
                modulesToExecute.push(Project.fromFile(havenFile));
                havenFile = rootHavenFile;
            }
            var project = Project.fromFile(havenFile);
            //project.printStructure();
            Sys.setCwd(project.path);

            Sys.println(" - commands: " + commands.join(", "));
            project.exec(commands, modulesToExecute);
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
            var testPath = Path.normalize(parts.join("/") + "/haven.xml");
            if (!FileSystem.exists(testPath)) {
                s = Path.normalize(parts.join("/") + "/" + current + "/haven.xml");
                break;
            }
        }
        return s;
    }
}