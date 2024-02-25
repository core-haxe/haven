package haven.commands.structure;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haven.util.XmlDocument;
import haven.project.Project;

class StructureCommand extends Command {
    private var root:String;
    private var source:String;
    private var sourceDocument:XmlDocument;

    private var structureTypes:Map<String, Void->StructureType> = [];

    public function new() {
        super();

        structureTypes.set("haxelib-dev", haven.commands.structure.types.HaxelibDevType.new);
        structureTypes.set("git-submodule", haven.commands.structure.types.GitSubmodule.new);
    }

    public override function exec(project:Project) {
        var finalRoot = project.interpolatePath(root);
        Sys.println(" creating structure in " + finalRoot + "");

        if (source != null) {
            var finalSource = project.interpolatePath(source);
            Sys.println(" using source file " + finalSource + "");
            var contents = File.getContent(finalSource);
            sourceDocument = new XmlDocument(Xml.parse(contents)).child("structure");
        }

        if (sourceDocument == null) {
            throw "no structure source found";
        }

        for (child in sourceDocument.children()) {
            handleNode(project, child, finalRoot, " ");
        }
    }

    private function handleNode(project:Project, node:XmlDocument, currentPath:String, indent:String) {
        var type = project.interpolate(node.attr("type"));
        var name = node.nodeName;
        if (type == null) { // no type indicates its a folder
            var newPath = Path.normalize(currentPath + "/" + name);
            if (FileSystem.exists(newPath)) {
                Sys.println(indent + " " + project.relativePath(newPath, project.interpolatePath(currentPath)) + "");
            } else {
                Sys.println(indent + " " + project.relativePath(newPath, project.interpolatePath(currentPath)) + " (create)");
                FileSystem.createDirectory(newPath);
            }
            currentPath = newPath;
        } else {
            var typeExecutorCtor = structureTypes.get(type);
            if (typeExecutorCtor == null) {
                throw "unknown type '" + type + "'";
            }

            var newPath = Path.normalize(currentPath + "/" + name);
            Sys.println(indent + " " + project.relativePath(newPath, project.interpolatePath(currentPath)) + " [" + type + "]");

            var typeExecutor:StructureType = typeExecutorCtor();
            typeExecutor.execute(project, node, currentPath, indent);
        }

        for (child in node.children()) {
            handleNode(project, child, currentPath, indent + " ");
        }
    }

    public override function parse(doc:XmlDocument) {
        root = doc.attr("root");
        if (root == null) {
            root = "${rootDir}";
        }
        source = doc.attr("source");
        sourceDocument = doc;
    }
    
}