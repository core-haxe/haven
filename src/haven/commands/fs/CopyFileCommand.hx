package haven.commands.fs;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class CopyFileCommand extends Command {
    public var source:String;
    public var destination:String;

    public override function exec(project:Project) {
        var finalSource = project.interpolatePath(source);
        var finalDestination = project.interpolatePath(destination);
        if (!FileSystem.exists(finalSource)) {
            throw "file not found: " + finalSource;
        }

        var desintationPath = new Path(finalDestination).dir;
        if (desintationPath != null && desintationPath.trim().length > 0 && !FileSystem.exists(desintationPath)) {
            FileSystem.createDirectory(desintationPath);
        }

        Sys.println(" - copying file " + finalSource.replace(project.rootDir, "") + " => " + finalDestination.replace(project.rootDir, ""));
        var srcBytes = File.getBytes(finalSource);
        File.saveBytes(finalDestination, srcBytes);
        //File.copy(finalSource, finalDestination);
    }

    public override function parse(doc:XmlDocument) {
        source = doc.attr("source");
        destination = doc.attr("destination");
    }
}