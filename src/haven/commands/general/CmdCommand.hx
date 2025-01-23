package haven.commands.general;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

class CmdCommand extends Command {
    public var command:String;
    public var workingDir:String = null;
    public var storeIn:String = null;
    public var stdout:Bool = true;
    public var stderr:Bool = true;

    public override function exec(project:Project) {
        var finalCommand = project.interpolate(command);
        var finalWorkingDir = project.interpolatePath(workingDir);
        var finalStoreIn = project.interpolatePath(storeIn);

        var p = new ProcessRunner(finalCommand, null, finalWorkingDir);
        p.run(stdout, stderr);

        if (p.exitCode != 0) {
            throw "problem executing command (code: " + p.exitCode + ")";
        }

        if (finalStoreIn != null) {
            Sys.println(' - storing result in "${finalStoreIn}" property');
            project.properties.add(finalStoreIn, p.result);
        }
    }

    public override function parse(doc:XmlDocument) {
        command = doc.attr("command");
        workingDir = doc.attr("workingDir");
        storeIn = doc.attr("storeIn");
        if (doc.attr("stdout") != null) {
            stdout = doc.attr("stdout") == "true";
        }
        if (doc.attr("stderr") != null) {
            stderr = doc.attr("stderr") == "true";
        }
    }
}