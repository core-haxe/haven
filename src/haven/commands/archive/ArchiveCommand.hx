package haven.commands.archive;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;
import zip.ZipFile;

using StringTools;

class ArchiveCommand extends Command {
    public var source:String;
    public var destination:String;

    public override function exec(project:Project) {
        var finalSource = project.interpolatePath(source);
        var finalDestination = project.interpolatePath(destination);
        if (!FileSystem.exists(finalSource)) {
            throw "directory not found: " + finalSource;
        }

        var destinationPath = new Path(finalDestination).dir;
        if (destinationPath != null && destinationPath.trim().length > 0 && !FileSystem.exists(destinationPath)) {
            FileSystem.createDirectory(destinationPath);
        }

        Sys.println(" - archiving directory " + finalSource.replace(project.rootDir, "") + " => " + finalDestination.replace(project.rootDir, ""));
        var zipFile = new ZipFile();
        archiveDir(finalSource, zipFile, finalSource);
        File.saveBytes(finalDestination, zipFile.bytes);
    }

    private function archiveDir(dir:String, zipFile:ZipFile, baseDir:String) {
        var contents = FileSystem.readDirectory(dir);
        for (item in contents) {
            var fullPath = Path.normalize(dir + "/" + item);
            if (FileSystem.isDirectory(fullPath)) {
                archiveDir(fullPath, zipFile, baseDir);
            } else {
                var relativePath = fullPath.replace(baseDir, "");
                if (relativePath.startsWith("/")) {
                    relativePath = relativePath.substring(1);
                }
                Sys.println("     " + relativePath);

                zipFile.addEntry(relativePath, File.getBytes(fullPath));
            }
        }
    }

    public override function parse(doc:XmlDocument) {
        source = doc.attr("source");
        destination = doc.attr("destination");
    }
}