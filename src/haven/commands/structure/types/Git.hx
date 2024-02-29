package haven.commands.structure.types;

import haxe.io.Path;
import haven.util.ProcessRunner;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;

class Git extends StructureType {
    public override function execute(project:Project, node:XmlDocument, currentPath:String, basePath:String, indent:String) {
        var source = project.interpolate(node.attr("source"));
        var name = node.nodeName;
        var branch = node.attr("branch");
        if (branch == null) {
            branch = "master";
        }

        var cwd = Path.normalize(currentPath + "/" + name);
        var hasGit = FileSystem.exists(Path.normalize(cwd + "/.git"));
        if (!hasGit) {
            var gitClone = new ProcessRunner("git", ["clone", source], null, indent + "   ");
            gitClone.run();
        } else {
            var gitPull = new ProcessRunner("git", ["pull", "origin", branch], cwd, indent + "   ");
            gitPull.run();
        }
    }
}