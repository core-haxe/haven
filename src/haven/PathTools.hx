package haven;

import haxe.io.Path;

using StringTools;

class PathTools {
    public static function relativeTo(path:Path, base:Path):Path {
        trace(path.toString());
        trace(base.toString());
        if (!path.toString().startsWith(base.toString())) {
            return path;
        }
        return null;
    }   
}