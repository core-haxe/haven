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
    public var mustExist:Bool = true;

    public override function exec(project:Project) {
        var finalSource = project.interpolatePath(source);
        var finalDestination = project.interpolatePath(destination);
        if (mustExist && !FileSystem.exists(finalSource)) {
            throw "file not found: " + finalSource;
        }

        var destinationPath = new Path(finalDestination).dir;
        if (destinationPath != null && destinationPath.trim().length > 0 && !FileSystem.exists(destinationPath)) {
            FileSystem.createDirectory(destinationPath);
        }

        Sys.println(" - copying file " + finalSource.replace(project.rootDir, "") + " => " + finalDestination.replace(project.rootDir, ""));
        var srcBytes = File.getBytes(finalSource);
        File.saveBytes(finalDestination, srcBytes);
        //File.copy(finalSource, finalDestination);
    }

    public override function parse(doc:XmlDocument) {
        source = doc.attr("source");
        destination = doc.attr("destination");
        if (doc.attr("mustExist") != null) {
            mustExist = (doc.attr("mustExist") == "true");
        }
    }
}