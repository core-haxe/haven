package haven.commands.structure.types;

import sys.io.File;
import haven.util.ProcessRunner;
import haxe.io.Path;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class GitSubmodule extends StructureType {
    public override function execute(project:Project, node:XmlDocument, currentPath:String, basePath:String, indent:String) {
        var source = project.interpolate(node.attr("source"));
        var name = node.nodeName;

        var cwd = basePath;
        var hasGit = FileSystem.exists(Path.normalize(cwd + "/.git"));
        if (!hasGit) {
            var gitInit = new ProcessRunner("git", ["init"], null, indent + "   ");
            gitInit.run();
        }

        if (!hasSubModule(name, cwd)) {
            var relativePath = Path.normalize(project.relativePath(currentPath, basePath) + "/" + name);
            if (relativePath.startsWith("/")) {
                relativePath = relativePath.substring(1);
            }
            if (!relativePath.endsWith("/")) {
                relativePath += "/";
            }
            var gitSubmoduleAdd = new ProcessRunner("git", ["submodule", "add", source, relativePath], null, indent + "   ");
            gitSubmoduleAdd.run();
        } else {
            var relativePath = Path.normalize(project.relativePath(currentPath, basePath) + "/" + name);
            if (relativePath.startsWith("/")) {
                relativePath = relativePath.substring(1);
            }
            if (!relativePath.endsWith("/")) {
                relativePath += "/";
            }

            var gitSubmoduleUpdate = new ProcessRunner("git", ["submodule", "update", "--remote", "--init", relativePath], null, indent + "   ");
            gitSubmoduleUpdate.run();
        }

    }

    private function hasSubModule(name:String, cwd:String) {
        var filename = Path.normalize(cwd + "/.gitmodules");
        if (!FileSystem.exists(filename)) {
            return false;
        }

        var contents = File.getContent(filename);
        var regex = new EReg('^\\[submodule ".*(' + name + ')"\\]', "gm");
        return regex.match(contents);
    }
}