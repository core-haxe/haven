package haven.commands.fs;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import haven.project.Project;
import haven.util.XmlDocument;

using StringTools;

class CopyDirCommand extends Command {
    public var source:String;
    public var destination:String;

    public override function exec(project:Project) {
        var finalSource = project.interpolatePath(source);
        var finalDestination = project.interpolatePath(destination);
        if (!FileSystem.exists(finalSource)) {
            throw "dir not found: " + finalSource;
        }

        if (finalDestination != null && finalDestination.trim().length > 0 && !FileSystem.exists(finalDestination)) {
            FileSystem.createDirectory(finalDestination);
        }

        Sys.println(" - copying dir " + finalSource.replace(project.rootDir, "") + " => " + finalDestination.replace(project.rootDir, ""));
        copyFilesRecursively(finalSource, finalDestination, project);
    }

    private function copyFilesRecursively(src:String, dst:String, project:Project) {
        src = Path.normalize(src);
        dst = Path.normalize(dst);
        var sourceItems = FileSystem.readDirectory(src);
        for (sourceItem in sourceItems) {
            var srcFullPath = Path.normalize(src + "/" + sourceItem);
            var dstFullPath = Path.normalize(dst + "/" + sourceItem);
            if (FileSystem.isDirectory(srcFullPath)) {
                if (!FileSystem.exists(dstFullPath)) {
                    FileSystem.createDirectory(dstFullPath);
                }
                copyFilesRecursively(srcFullPath, dstFullPath, project);
            } else {
                //Sys.println("   - copying file " + srcFullPath.replace(project.rootDir, "") + " => " + dstFullPath.replace(project.rootDir, ""));
                var srcBytes = File.getBytes(srcFullPath);
                File.saveBytes(dstFullPath, srcBytes);
            }

        }
    }

    public override function parse(doc:XmlDocument) {
        source = doc.attr("source");
        destination = doc.attr("destination");
    }
}