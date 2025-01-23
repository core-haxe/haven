package haven.commands.json;

import json.JSONData;
import json.path.JSONPath;
import haxe.Json;
import haven.util.XmlDocument;
import haven.project.Project;

using StringTools;

class JsonPathCommand extends Command {
    public var document:String;
    public var path:String;
    public var storeIn:String = null;

    public override function exec(project:Project) {
        var finalDocument = project.interpolate(document);
        var finalPath = project.interpolate(path);
        var finalStoreIn = project.interpolatePath(storeIn);

        var json = JSONData.parse(finalDocument);
        var result = JSONPath.query(finalPath, json);

        if (finalStoreIn != null) {
            Sys.println(' - storing result in "${finalStoreIn}" property');
            if (result != null) {
                project.properties.add(finalStoreIn, Std.string(result));
            }
        }
    }

    public override function parse(doc:XmlDocument) {
        document = doc.attr("document");
        path = doc.attr("path");
        storeIn = doc.attr("storeIn");
    }
}