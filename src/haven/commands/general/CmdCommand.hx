package haven.commands.general;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

class CmdCommand extends Command {
    public var command:String;
    public var workingDir:String = null;
    public var stdout:Bool = true;

    public override function exec(project:Project) {
        var finalCommand = project.interpolate(command);
        var finalWorkingDir = project.interpolatePath(workingDir);

        var p = new ProcessRunner(finalCommand, null, finalWorkingDir);
        p.run(stdout);

        if (p.exitCode != 0) {
            throw "problem executing command (code: " + p.exitCode + ")";
        }

    }

    public override function parse(doc:XmlDocument) {
        command = doc.attr("command");
        workingDir = doc.attr("workingDir");
        if (doc.attr("stdout") != null) {
            stdout = doc.attr("stdout") == "true";
        }
    }
}