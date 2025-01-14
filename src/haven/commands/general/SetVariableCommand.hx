package haven.commands.general;

import haven.util.XmlDocument;
import haven.project.Project;

class SetVariableCommand extends Command {
    public var name:String;
    public var value:String;

    public override function exec(project:Project) {
        var finalName = project.interpolate(name);
        var finalValue = project.interpolate(value);

        Sys.println(" - setting variable " + finalName + ":" + finalValue);
        Sys.putEnv(finalName, finalValue);
        project.properties.add(finalName, finalValue);
    }

    public override function parse(doc:XmlDocument) {
        name = doc.attr("name");
        value = doc.attr("value");
    }
}