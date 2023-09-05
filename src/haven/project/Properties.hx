package haven.project;

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
}