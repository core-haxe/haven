package haven.commands.util;

import haven.project.Project;
import haven.util.XmlDocument;

class LogCommand extends Command {
    public var message:String;

    public override function exec(project:Project) {
        var finalMessage = project.interpolate(message);
        Sys.println(" " + finalMessage);
    }

    public override function parse(doc:XmlDocument) {
        message = doc.attr("message");
    }
}