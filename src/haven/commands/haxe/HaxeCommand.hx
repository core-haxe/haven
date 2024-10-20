package haven.commands.haxe;

import sys.FileSystem;
import haven.util.ProcessRunner;
import sys.io.File;
import haxe.io.Path;
import haven.project.Project;
import haven.util.XmlDocument;

class HaxeCommand extends Command {
    public var target:String;
    public var output:String;
    public var main:String;
    public var cleanUp:Bool = true;
    public var outputFilename = null;

    public var dependencies:Array<HaxeDependency> = [];
    public var classPaths:Array<HaxeClassPath> = [];
    public var compilerArgs:Array<HaxeCompilerArg> = [];
    public var compilerDefines:Array<HaxeCompilerDefine> = [];
    public var classItems:Array<HaxeClassItem> = [];
    public var macroItems:Array<HaxeMacroItem> = [];
    public var postBuildItems:Array<HaxePostBuildItem> = [];

    public override function exec(project:Project) {
        buildHxml(project);
    }

    private function buildHxml(project:Project) {
        var sb = new StringBuf();

        sb.add("# generated file - do not edit\n\n");

        sb.add("# dependencies\n");
        for (dependency in dependencies) {
            sb.add("--library ");
            sb.add(project.interpolate(dependency.name));
            sb.add("\n");
        }

        sb.add("\n");

        sb.add("# class paths\n");
        for (classPath in classPaths) {
            sb.add("--class-path ");
            sb.add(project.interpolatePath(classPath.path));
            sb.add("\n");
        }

        sb.add("\n");

        if (classItems.length > 0) {
            sb.add("# classes\n");
            for (classItem in classItems) {
                sb.add(project.interpolate(classItem.path));
                sb.add("\n");
            }
            sb.add("\n");
        }

        if (macroItems.length > 0) {
            sb.add("# macros\n");
            for (macroItem in macroItems) {
                sb.add("--macro " + project.interpolate(macroItem.macroData));
                sb.add("\n");
            }
            sb.add("\n");
        }

        sb.add("# compiler args\n");
        for (compilerArg in compilerArgs) {
            sb.add(project.interpolate(compilerArg.arg));
            sb.add("\n");
        }

        sb.add("\n");

        sb.add("# compiler defines\n");
        for (compilerDefine in compilerDefines) {
            sb.add("-D ");
            sb.add(project.interpolate(compilerDefine.define));
            sb.add("\n");
        }

        sb.add("\n");

        if (main != null) {
            sb.add("--main ");
            sb.add(project.interpolate(main));
            sb.add("\n");
        }
        
        sb.add("--");
        sb.add(project.interpolate(target));
        sb.add(" ");
        sb.add(project.interpolatePath(output));

        sb.add("\n");

        if (postBuildItems.length > 0) {
            sb.add("\n");
            sb.add("# post build\n");
            for (postBuildItem in postBuildItems) {
                sb.add("--cmd " + project.interpolate(postBuildItem.command));
                sb.add("\n");
            }
        }

        var filename = hxmlFullPath(project);
        Sys.println(" - executing haxe (" + hxmlFilename() + ")");
        File.saveContent(filename, sb.toString());

        var p = new ProcessRunner("haxe", [hxmlFilename()], project.path);
        p.run();

        if (cleanUp == true) {
            FileSystem.deleteFile(filename);
        }

        if (p.exitCode != 0) {
            throw "problem executing haxe (code: " + p.exitCode + ")";
        }
    }

    private function hxmlFullPath(project:Project) {
        return Path.normalize(project.path + "/" + hxmlFilename());
    }

    private function hxmlFilename() {
        if (outputFilename != null) {
            return outputFilename;
        }
        return "haven-build-" + target + ".hxml";
    }

    public override function parse(doc:XmlDocument) {
        target = doc.attr("target");
        output = doc.attr("output");
        main = doc.attr("main");
        outputFilename = doc.attr("outputFilename");
        if (doc.attr("cleanUp") != null) {
            cleanUp = (doc.attr("cleanUp") == "true");
        }

        var dependenciesDoc = doc.child("dependencies");
        if (dependenciesDoc != null) {
            for (dependencyDoc in dependenciesDoc.children("dependency")) {
                var dependency = HaxeDependency.fromXml(dependencyDoc);
                dependencies.push(dependency);
            }
        }

        var classPathsDoc = doc.child("class-paths");
        if (classPathsDoc != null) {
            for (classPathDoc in classPathsDoc.children("class-path")) {
                var classPath = HaxeClassPath.fromXml(classPathDoc);
                classPaths.push(classPath);
            }
        }

        var compilerArgsDoc = doc.child("compiler-args");
        if (compilerArgsDoc != null) {
            for (compilerArgDoc in compilerArgsDoc.children("compiler-arg")) {
                var compilerArg = HaxeCompilerArg.fromXml(compilerArgDoc);
                compilerArgs.push(compilerArg);
            }
        }

        var compilerDefinesDoc = doc.child("compiler-defines");
        if (compilerDefinesDoc != null) {
            for (compilerDefineDoc in compilerDefinesDoc.children("compiler-define")) {
                var compilerDefine = HaxeCompilerDefine.fromXml(compilerDefineDoc);
                compilerDefines.push(compilerDefine);
            }
        }

        var classesDoc = doc.child("classes");
        if (classesDoc != null) {
            for (classDoc in classesDoc.children("class")) {
                var classItem = HaxeClassItem.fromXml(classDoc);
                classItems.push(classItem);
            }
        }

        var macrosDoc = doc.child("macros");
        if (macrosDoc != null) {
            for (macroDoc in macrosDoc.children("macro")) {
                var macroItem = HaxeMacroItem.fromXml(macroDoc);
                macroItems.push(macroItem);
            }
        }

        var postBuildDoc = doc.child("post-build");
        if (postBuildDoc != null) {
            for (commandDoc in postBuildDoc.children("command")) {
                var postBuildItem = HaxePostBuildItem.fromXml(commandDoc);
                postBuildItems.push(postBuildItem);
            }
        }
    }

}

private class HaxeDependency {
    public var name:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        name = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeDependency();
        c.parse(doc);
        return c;
    }
}

private class HaxeClassPath {
    public var path:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        path = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeClassPath();
        c.parse(doc);
        return c;
    }
}

private class HaxeCompilerArg {
    public var arg:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        arg = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeCompilerArg();
        c.parse(doc);
        return c;
    }
}

private class HaxeCompilerDefine {
    public var define:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        define = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeCompilerDefine();
        c.parse(doc);
        return c;
    }
}

private class HaxeClassItem {
    public var path:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        path = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeClassItem();
        c.parse(doc);
        return c;
    }
}

private class HaxeMacroItem {
    public var macroData:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        macroData = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxeMacroItem();
        c.parse(doc);
        return c;
    }
}

private class HaxePostBuildItem {
    public var command:String;

    public function new() {
    }

    private function parse(doc:XmlDocument) {
        command = doc.text;
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new HaxePostBuildItem();
        c.parse(doc);
        return c;
    }
}