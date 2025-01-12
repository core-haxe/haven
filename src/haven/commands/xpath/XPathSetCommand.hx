package haven.commands.xpath;

import sys.io.File;
import haven.util.XmlDocument;
import haven.project.Project;
import haxe.io.Path;
import sys.FileSystem;

class XPathSetCommand extends Command {
    public var file:String;
    
    public override function exec(project:Project) {
        var finalFile = project.interpolatePath(file);
        if (!FileSystem.exists(finalFile)) {
            throw "file not found: " + finalFile;
        }

        var fileContent = File.getContent(finalFile);
        trace(fileContent);
    }

    public override function parse(doc:XmlDocument) {
        file = doc.attr("file");
    }
}