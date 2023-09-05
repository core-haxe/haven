package haven.project;

import haven.util.XmlDocument;

class Chain {
    public var id:String;
    public var isDefault:Bool = false;

    public var commands:Array<String> = [];

    public function new() {

    }

    public function parse(doc:XmlDocument) {
        id = doc.nodeName;
        if (doc.attr("default") != null) {
            isDefault = doc.attr("default") == "true";
        }

        for (child in doc.children()) {
            commands.push(child.nodeName);
        }
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new Chain();
        c.parse(doc);
        return c;
    }
}