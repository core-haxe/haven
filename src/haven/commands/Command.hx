package haven.commands;

import haven.project.Project;
import haven.util.XmlDocument;

using StringTools;

class Command {
    public function new() {
    }

    public function parse(doc:XmlDocument) {
    }

    public function exec(project:Project) {
    }

    private function displayPathRelativeToRoot(project:Project, path:String, prefix:String = null):String {
        if (path == null) {
            return "";
        }

        var s = path.replace(project.rootDir, "");
        if (prefix != null) {
            s = prefix + s;
        }
        return s;
    }
}