package haven.commands.fs;

import sys.FileSystem;
import haven.project.Project;
import haven.util.XmlDocument;

using StringTools;

class MkDirCommand extends Command {
    public var path:String;

    public override function exec(project:Project) {
        var finalPath = project.interpolatePath(path);
        Sys.println(" - creating directory " + finalPath.replace(project.rootDir, ""));
        if (!FileSystem.exists(finalPath)) {
            FileSystem.createDirectory(project.interpolatePath(finalPath));
        }
    }

    public override function parse(doc:XmlDocument) {
        path = doc.attr("path");
    }
}