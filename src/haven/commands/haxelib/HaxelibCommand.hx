package haven.commands.haxelib;

import haven.properties.HaxelibPropertyResolver;
import haxe.io.Path;
import sys.FileSystem;
import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class HaxelibCommand extends Command {
    public var command:String;
    public var name:String;
    public var source:String;
    public var version:String;

    public override function exec(project:Project) {
        var finalCommand = project.interpolate(command);
        var finalName = project.interpolate(name);
        var finalSource = project.interpolate(source);
        var finalVersion = project.interpolate(version);

        Sys.println(" haxelib " + finalCommand + " " + finalName);
        var currentVersion = HaxelibPropertyResolver.getHaxelibVersion(finalName);
        if (currentVersion == "dev") {
            var currentPath = HaxelibPropertyResolver.getHaxelibPath(finalName);
            var hasGit = FileSystem.exists(Path.normalize(currentPath + "/.git"));
            if (hasGit) {
                var gitPull = new ProcessRunner("git", ["pull"], Path.normalize(currentPath), "   ");
                gitPull.run();
            } else { // not sure what to do if its dev, but isnt a git dir... do we just clone into it??
                //var gitClone = new ProcessRunner("git", ["clone", source], Path.normalize(currentPath), "   ");
                //gitClone.run();
            }
        } else if (currentVersion != finalVersion) {
            if (finalVersion == "git") {
                var haxelibInstallGit = new ProcessRunner("haxelib", ["git", finalName, finalSource], null, "   ");
                haxelibInstallGit.run();
            } else {
                var haxelibInstall = new ProcessRunner("haxelib", ["install", finalName, finalVersion], null, "   ");
                haxelibInstall.run();
            }
        } else {
            var haxelibUpdate = new ProcessRunner("haxelib", ["update", finalVersion], null, "   ");
            haxelibUpdate.run();
        }
    }

    public override function parse(doc:XmlDocument) {
        command = doc.attr("command");
        name = doc.attr("name");
        source = doc.attr("source");
        version = doc.attr("version");
    }
}