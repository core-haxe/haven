package haven.commands.npm;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class NpmCommand extends Command {
    public var operation:String;
    public var path:String;

    public override function exec(project:Project) {
        var finalPath = project.interpolatePath(path);
        if (operation == null || operation == "") {
            operation = "install";
        }

        Sys.println(" - executing npm " + operation + displayPathRelativeToRoot(project, finalPath, " in "));

        var p = new ProcessRunner("npm " + operation + " --quiet", null, finalPath);
        p.run(false);

        if (p.exitCode != 0) {
            throw "problem executing npm (code: " + p.exitCode + ")";
        }
    }

    public override function parse(doc:XmlDocument) {
        operation = doc.attr("operation");
        path = doc.attr("path");
    }
}