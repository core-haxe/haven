package haven.commands.git;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class GitCommand extends Command {
    public var command:String;
    public var path:String;

    public override function exec(project:Project) {
        var finalPath = project.interpolatePath(path);
        var finalCommand = project.interpolatePath(command);

        Sys.println(" - executing git command '" + finalCommand + displayPathRelativeToRoot(project, finalPath, "' in "));

        var p = new ProcessRunner("git " + finalCommand, null, finalPath);
        p.run(false);

        if (p.exitCode != 0) {
            throw "problem executing git command (code: " + p.exitCode + ")";
        }
    }

    public override function parse(doc:XmlDocument) {
        command = doc.attr("command");
        path = doc.attr("path");
    }
}