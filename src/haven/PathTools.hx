package haven;

import haxe.io.Path;

using StringTools;

class PathTools {
    public static function relativeTo(path:Path, base:Path):Path {
        if (!path.toString().startsWith(base.toString())) {
            return path;
        }
        return new Path(path.toString().replace(base.toString(), ""));
    }   
}