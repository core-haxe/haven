package haven.util;

class XmlDocument {
    public var xml:Xml;

    public function new(xml:Xml) {
        this.xml = xml;
    }

    public var text(get, null):String;
    private function get_text():String {
        return xml.firstChild().nodeValue;
    }

    public var nodeName(get, null):String;
    private function get_nodeName():String {
        return xml.nodeName;
    }

    public function attr(name:String):String {
        return xml.get(name);
    }

    public function childText(name:String, defaultValue:String = null):String {
        var text = defaultValue;
        var elements = xml.elementsNamed(name);
        var count = 0;
        var first = true;
        for (element in elements) {
            if (first == true) {
                text = element.firstChild().nodeValue;
                first = false;
            }
            count++;
        }

        if (count > 1) {
            trace("WARNING: multiple '" + name + "' nodes found, using first");
        }

        return text;
    }

    public function child(name:String):XmlDocument {
        var c:XmlDocument = null;
        var elements = xml.elementsNamed(name);
        var count = 0;
        var first = true;
        for (element in elements) {
            if (first == true) {
                c = new XmlDocument(element);
                first = false;
            }
            count++;
        }

        if (count > 1) {
            trace("WARNING: multiple '" + name + "' nodes found, using first");
        }

        return c;
    }

    public function children(name:String = null):Array<XmlDocument> {
        var c = [];
        var elements = null;
        if (name != null) {
            elements = xml.elementsNamed(name);
        } else {
            elements = xml.elements();
        }

        for (element in elements) {
            c.push(new XmlDocument(element));
        }

        return c;
    }

    public function hasChild(name:String):Bool {
        var has = false;
        var elements = xml.elementsNamed(name);
        for (element in elements) {
            has = true;
            break;
        }
        return has;
    }
}