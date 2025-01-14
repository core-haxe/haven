package haven.commands.general;

import haven.util.XmlDocument;
import haven.project.Project;

class SetEnvironmentVariableCommand extends Command {
    public var name:String;
    public var value:String;

    public override function exec(project:Project) {
        var finalName = project.interpolate(name);
        var finalValue = project.interpolate(value);

        Sys.println(" - setting environment variable " + finalName + ":" + finalValue);
        Sys.putEnv(finalName, finalValue);
    }

    public override function parse(doc:XmlDocument) {
        name = doc.attr("name");
        value = doc.attr("value");
    }
}