package haven.project;

import haven.commands.CommandFactory;
import haven.commands.Command;
import haven.util.XmlDocument;

using StringTools;

class CommandDef {
    public var id:String;

    public var commands:Array<Command> = [];

    public var unlessFlags:Array<String> = [];

    public function new() {

    }

    public function exec(project:Project, flags:Array<String>) {
        var use = true;
        if (unlessFlags.length > 0) {
            for (unlessFlag in unlessFlags) {
                if (flags.contains(unlessFlag)) {
                    use = false;
                    break;
                }
            }
        }

        if (!use) {
            return;
        }

        for (command in commands) {
            command.exec(project);
        }
    }

    private function parse(doc:XmlDocument) {
        id = doc.nodeName;

        var unless = doc.attr("unless");
        unlessFlags = [];
        if (unless != null) {
            var parts = unless.split(" ");
            for (part in parts) {
                part = part.trim();
                if (part.length == 0) {
                    continue;
                }
                unlessFlags.push(part);
            }
        }

        for (commandDoc in doc.children()) {
            var command = CommandFactory.create(commandDoc.nodeName);
            if (command == null) {
                throw "could not find command for '" + commandDoc.nodeName + "'";
                continue;
            }

            command.parse(commandDoc);
            commands.push(command);
        }
    }

    public static function fromXml(doc:XmlDocument) {
        var c = new CommandDef();
        c.parse(doc);
        return c;
    }
}