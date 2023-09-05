package haven;

class Platform {
    public static var isWindows(get, null):Bool;
    private static function get_isWindows():Bool {
        return Sys.systemName().toLowerCase() == "windows";
    }
}