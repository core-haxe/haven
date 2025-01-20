package haven.commands.fs;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class DeleteFileCommand extends Command {
    public var source:String;

    public override function exec(project:Project) {
        var finalSource = project.interpolatePath(source);
        if (!FileSystem.exists(finalSource)) {
            throw "file not found: " + finalSource;
        }

        Sys.println(" - deleting file " + finalSource.replace(project.rootDir, ""));
        FileSystem.deleteFile(finalSource);
    }

    public override function parse(doc:XmlDocument) {
        source = doc.attr("source");
    }
}