package haven.project;

import sys.io.File;
import sys.FileSystem;

using StringTools;

class Properties {
    public var map:Map<String, String> = [];

    public function new() {
        
    }

    public function add(name:String, value:String) {
        map.set(name, value);
    }

    public function get(name:String):String {
        return map.get(name);
    }

    public function has(name:String):Bool {
        return map.exists(name);
    }

    public function merge(other:Properties) {
        if (other == null) {
            return;
        }

        for (key in other.map.keys()) {
            map.set(key, other.map.get(key));
        }
    }

    public static function fromFile(path:String):Properties {
        if (!FileSystem.exists(path)) {
            return null;
        }

        var content = File.getContent(path);
        var lines = content.split("\n");

        var props = new Properties();
        for (line in lines) {
            line = line.trim();
            if (line.length == 0) {
                continue;
            }
            if (line.startsWith("#")) {
                continue;
            }

            var n = line.indexOf("=");
            var name = line.substring(0, n);
            var value = line.substring(n + 1);
            props.map.set(name.trim(), value.trim());
        }
        return props;
    }
}