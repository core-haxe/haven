package haven.commands.general;

import haven.util.ProcessRunner;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class ForEachCommand extends Command {
    public var list:String = null;
    public var property:String = null;
    private var children:Array<XmlDocument>;

    public override function exec(project:Project) {
        var finalList = project.interpolate(list);
        var finalProperty = project.interpolate(property);

        var array = stringToArray(finalList);
        if (array != null) {
            for (item in array) {
                for (commandDoc in children) {
                    var command = CommandFactory.create(commandDoc.nodeName);
                    if (command == null) {
                        throw "could not find command for '" + commandDoc.nodeName + "'";
                        continue;
                    }
        
                    command.parse(commandDoc);
                    var originalValue = project.properties.get(finalProperty);
                    project.properties.add(finalProperty, item);
                    command.exec(project);
                    if (originalValue != null) {
                        project.properties.add(finalProperty, originalValue);
                    }
                }
            }
        }
    }

    private function stringToArray(stringValue:String):Array<String> {
        if (stringValue == null) {
            return [];
        }
        stringValue = stringValue.trim();
        var finalArray:Array<String> = [];
        if (stringValue.startsWith("[") && stringValue.endsWith("]")) {
            stringValue = stringValue.substring(1, stringValue.length - 1);
        }
        if (stringValue.length == 0) {
            return [];
        }
        if (stringValue.contains(",")) {
            var parts = stringValue.split(",");
            for (part in parts) {
                part = part.trim();
                if (part.length == 0) { // maybe a property to allow this?
                    continue;
                }

                finalArray.push(part);
            }
        }
        return finalArray;
    }

    public override function parse(doc:XmlDocument) {
        list = doc.attr("list");
        property = doc.attr("property");
        this.children = doc.children();
    }
}