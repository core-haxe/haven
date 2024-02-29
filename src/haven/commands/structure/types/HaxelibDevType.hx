package haven.commands.structure.types;

import haven.util.ProcessRunner;
import sys.FileSystem;
import haxe.io.Path;
import haven.util.XmlDocument;
import haven.project.Project;

class HaxelibDevType extends StructureType {
    public override function execute(project:Project, node:XmlDocument, currentPath:String, basePath:String, indent:String) {
        var source = project.interpolate(node.attr("source"));
        var name = node.nodeName;
        if (source != null) {
            var hasGit = FileSystem.exists(Path.normalize(currentPath + "/" + name + "/.git"));
            if (hasGit) {
                var gitPull = new ProcessRunner("git", ["pull"], Path.normalize(currentPath + "/" + name), indent + "   ");
                gitPull.run();
            } else {
                var gitClone = new ProcessRunner("git", ["clone", source], Path.normalize(currentPath), indent + "   ");
                gitClone.run();
            }
        }

        var haxelibDev = new ProcessRunner("haxelib", ["dev", name, "."], Path.normalize(currentPath + "/" + name), indent + "   ");
        haxelibDev.run();
    }
}