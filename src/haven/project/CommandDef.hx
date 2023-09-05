package haven.project;

import haven.commands.CommandFactory;
import haven.commands.Command;
import haven.util.XmlDocument;

class CommandDef {
    public var id:String;

    public var commands:Array<Command> = [];

    public function new() {

    }

    public function exec(project:Project) {
        for (command in commands) {
            command.exec(project);
        }
    }

    private function parse(doc:XmlDocument) {
        id = doc.nodeName;

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