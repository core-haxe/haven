package haven.properties;

import haxe.io.Path;
import sys.FileSystem;
import haven.util.ProcessRunner;

using StringTools;

class HaxelibPropertyResolver extends PropertyResolver {
    public override function resolve(name:String):String {
        return getHaxelibPath(name);
    }

    public static function getHaxelibPath(name:String):String {
        var path = null;
        var haxelibPath = new ProcessRunner("haxelib", ["path", name]);

        var output = haxelibPath.run(false, false);
        var lines = output.split("\n");
        for (line in lines) {
            line = line.trim();
            if (line.length == 0) {
                continue;
            }

            if (FileSystem.exists(line)) {
                path = Path.normalize(line);
                break;
            }
        }

        return path;
    }

    public static function getHaxelibVersion(name:String):String {
        var version = null;
        var haxelibPath = new ProcessRunner("haxelib", ["list", name]);

        var output = haxelibPath.run(false, false);
        var lines = output.split("\n");
        var candidate = null;
        for (line in lines) {
            line = line.trim();
            if (line.length == 0) {
                continue;
            }

            candidate = line;
        }

        if (candidate != null) {
            var n1 = candidate.indexOf("[");
            var n2 = candidate.indexOf("]");
            if (n1 != -1 && n2 != -1) {
                version = candidate.substring(n1 + 1, n2).trim();
                if (version.startsWith("dev:")) {
                    version = "dev";
                }
            }
        }

        return version;
    }

}