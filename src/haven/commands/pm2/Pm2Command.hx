package haven.commands.pm2;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class Pm2Command extends Command {
    public var operation:String;
    public var params:String;
    public var path:String;
    public var stdout:Bool = true;
    
    public override function exec(project:Project) {
        var finalPath = project.interpolatePath(path);
        var finalParams = project.interpolatePath(params);

        if (finalParams == null) {
            Sys.println(" - executing pm2 " + operation + displayPathRelativeToRoot(project, finalPath, " in "));
        } else {
            Sys.println(" - executing pm2 " + operation + " " + finalParams + displayPathRelativeToRoot(project, finalPath, " in "));
        }

        var cmd = "pm2 " + operation;
        if (finalParams != null) {
            cmd += " " + finalParams;
        }
        //cmd += " --no-color";
        var p = new ProcessRunner(cmd, null, finalPath);
        p.run(stdout);

        if (p.exitCode != 0) {
            throw "problem executing pm2 (code: " + p.exitCode + ")";
        }
    }

    public override function parse(doc:XmlDocument) {
        operation = doc.attr("operation");
        params = doc.attr("params");
        path = doc.attr("path");
        if (doc.attr("stdout") != null) {
            stdout = doc.attr("stdout") == "true";
        }
    }
}