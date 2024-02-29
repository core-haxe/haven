package haven.project;

import haven.properties.PropertyResolverFactory;
import sys.FileSystem;
import haxe.io.Path;
import haven.util.XmlDocument;
import sys.io.File;

using StringTools;
using haven.PathTools;

class Project {
    public var filename:String;

    public var group:String;
    public var name:String;
    public var version:String;

    public var modules:Array<Project> = [];
    public var commands:Map<String, CommandDef> = [];

    public var parentProject:Project = null;

    public var properties:Properties = new Properties();
    public var chains:Map<String, Chain> = [];

    public function new() {
        
    }

    private function buildCommandList(commands:Array<String>):Array<String> {
        var finalCommands = [];
        for (c in commands) {
            if (chains.exists(c)) {
                var chain = chains.get(c);
                for (cc in chain.commands) {
                    finalCommands.push(cc);
                }
            } else {
                finalCommands.push(c);
            }
        }

        for (module in modules) {
            var moduleFinalCommands = module.buildCommandList(commands);
            for (command in moduleFinalCommands) {
                if (!finalCommands.contains(command)) {
                    finalCommands.push(command);
                }
            }
        }


        return finalCommands;
    }

    public function findModule(module:Project):Project {
        var found:Project = null;
        for (m in modules) {
            if (m.path == module.path) {
                return m;
            }
        }

        for (m in modules) {
            var t = m.findModule(module);
            if (t != null) {
                return t;
            }
        }

        return found;
    }

    public function exec(commands:Array<String>, modulesToExecute:Array<Project> = null) {
        if (modulesToExecute.length == 0) {
            modulesToExecute = null;
        }
        var finalCommands = buildCommandList(commands);

        if (finalCommands == null || finalCommands.length == 0 && defaultChain != null) {
            for (c in defaultChain.commands) {
                finalCommands.push(c);
            }
            Sys.print("  \nno commands specified, using default chain '" + defaultChain.id + "' [" +  finalCommands.join(", ") + "]\n");
        }

        if (finalCommands == null || finalCommands.length == 0) {
            throw "no commands specified or resolved";
        }

        var failed = false;
        for (command in finalCommands) {
            if (!execCommand(command, modulesToExecute)) {
                failed = true;
                break;
            }
        }

        if (failed) {
            Sys.println("\nexecution errored!\n");
        } else {
            Sys.println("\nexecution successful!\n");
        }
    }

    public function execCommand(command:String, modulesToExecute:Array<Project> = null) {
        var use = true;
        if (modulesToExecute != null) {
            use = moduleListContainsProject(modulesToExecute, this);
        }

        if (use) {
            var commandDef = commands.get(command);
            if (commandDef != null) {
                Sys.println("");
                Sys.println("--------------------------------------------------------------------------------");
                var line = command + ": ";
                var name = this.name;
                if (this.group != null) {
                    name = this.group + "::" + name;
                }
                line += name;
                line += " [" +  Path.normalize(Sys.getCwd()) + "]";
                Sys.println(line);
                Sys.println("--------------------------------------------------------------------------------");
                try {
                    commandDef.exec(this);
                } catch (e:Dynamic) {
                    Sys.println("     " + e);
                    return false;
                }
            }
        }

        for (module in modules) {
            var oldCwd = Sys.getCwd();
            Sys.setCwd(module.path);
            if (!module.execCommand(command, modulesToExecute)) {
                return false;
            }
            Sys.setCwd(oldCwd);
        }
        return true;
    }

    private static function moduleListContainsProject(list:Array<Project>, project:Project):Bool {
        for (item in list) {
            if (item.equals(project)) {
                return true;
            }
        }
        return false;
    }

    public var rootProject(get, null):Project;
    private function get_rootProject():Project {
        var r = this;
        while (r.parentProject != null) {
            r = r.parentProject;
        }
        return r;
    }

    public var rootDir(get, null):String;
    private function get_rootDir():String {
        return rootProject.path;
    }

    public var path(get, null):String;
    private function get_path():String {
        var parts = Path.normalize(filename).split("/");
        parts.pop();
        return Path.normalize(parts.join("/"));
    }

    public function relativePath(path:String, base:String = null):String {
        if (base == null) {
            base = this.path;
        }
        return PathTools.relativeTo(new Path(path), new Path(base)).toString();
    }

    private function parse(xml:Xml) {
        var doc = new XmlDocument(xml);
        group = doc.childText("group");
        name = doc.childText("name");
        version = doc.childText("version");

        parseModules(doc.child("modules"));
        parseCommands(doc.child("commands"));
        parseProperties(doc.child("properties"));
        parseChains(doc.child("chains"));
    }

    private function parseModules(doc:XmlDocument) {
        modules = [];
        if (doc == null) {
            return;
        }

        for (moduleDoc in doc.children("module")) {
            var moduleHavenFile = Path.normalize(this.path + "/" + moduleDoc.text + "/haven.xml");
            if (!FileSystem.exists(moduleHavenFile)) {
                throw "haven file for module '" + moduleDoc.text + "' not found at '" + moduleHavenFile + "'";
                continue;
            }
            var moduleProjectFile = Project.fromFile(moduleHavenFile);
            moduleProjectFile.parentProject = this;
            modules.push(moduleProjectFile);
        }
    }

    private function parseCommands(doc:XmlDocument) {
        commands = [];
        if (doc == null) {
            return;
        }

        for (commandDoc in doc.children()) {
            var command = CommandDef.fromXml(commandDoc);
            commands.set(command.id, command);
        }
    }

    private function parseProperties(doc:XmlDocument) {
        properties = new Properties();
        if (doc == null) {
            return;
        }

        for (properyDoc in doc.children("property")) {
            var name = properyDoc.attr("name");
            var value = properyDoc.attr("value");
            properties.add(name, value);
        }
    }

    private function parseChains(doc:XmlDocument) {
        chains = [];
        if (doc == null) {
            return;
        }

        for (chainDoc in doc.children()) {
            var chain = Chain.fromXml(chainDoc);
            chains.set(chain.id, chain);
        }
    }

    public var defaultChain(get, null):Chain;
    private function get_defaultChain():Chain {
        for (chain in chains) {
            if (chain.isDefault) {
                return chain;
            }
        }
        return null;
    }

    private static var reg = new EReg("\\${(.*?)\\}", "gm");
    public function getProperty(name:String) {
        var v = null;

        if (name == "rootDir") {
            return rootDir;
        }
        if (name == "baseDir") {
            return this.path;
        }
        if (name == "cwd" || name == "currentWorkingDir") {
            return Path.normalize(Sys.getCwd());
        }

        if (name.indexOf(":") != -1) {
            var n = name.indexOf(":");
            var prefix = name.substring(0, n);
            var resolver = PropertyResolverFactory.getResolver(prefix);
            if (resolver == null) {
                throw 'could not find property resolver for "${prefix}"';
            }
            return resolver.resolve(name.substring(n + 1));
        }

        if (properties.has(name)) {
            v = properties.get(name);
        } else if (parentProject != null) {
            v = parentProject.getProperty(name);
        }

        if (v != null) {
            if (v.contains("${") && v.contains("}")) {
                v = reg.map(v, f -> {
                    var p = getProperty(f.matched(1));
                    if (p == null) {
                        p = "";
                    }
                    return p;
                });
            }
        }

        return v;
    }

    public function getPropertyAsPath(name:String) {
        var v = getProperty(name);
        if (v == null) {
            return null;
        }
        return Path.normalize(v);
    }

    public function interpolate(s:String) {
        if (s == null) {
            return null;
        }
        if (s.contains("${") && s.contains("}")) {
            s = reg.map(s, f -> {
                var p = getProperty(f.matched(1));
                if (p == null) {
                    p = "";
                }
                return p;
            });
        }
        return s;
    }

    public function interpolatePath(s:String) {
        if (s == null) {
            return null;
        }
        if (s.trim() == ".") {
            return ".";
        }
        if (s.contains("${") && s.contains("}")) {
            s = reg.map(s, f -> {
                var p = getProperty(f.matched(1));
                if (p == null) {
                    p = "";
                }
                return p;
            });
        }
        if (s == null) {
            return s;
        }

        var path = Path.normalize(s);
        if (path.startsWith("/") && Platform.isWindows) {
            path = path.substring(1);
        }

        /*
        var relativePath = new Path(path).relativeTo(new Path(rootDir));
        trace(">>>>>>>>>>>>>>>", path, rootDir);
        trace(relativePath);
        */

        return path;
    }

    public function equals(other:Project):Bool {
        if (other == null) {
            return false;
        }

        return this.path == other.path;
    }

    public static function fromFile(path:String):Project {
        var contents = File.getContent(path);
        var xml = Xml.parse(contents);
        var p = new Project();
        p.filename = Path.normalize(path.replace("/.haven", ""));
        p.parse(xml.firstElement());
        return p;
    }
}