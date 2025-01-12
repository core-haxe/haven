package haven.commands.regexp;

import sys.io.File;
import haven.util.XmlDocument;
import haven.project.Project;
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

class RegExpReplaceCommand extends Command {
    public var file:String;
    public var regexp:String;
    public var replacement:String;
    
    public override function exec(project:Project) {
        var finalFile = project.interpolatePath(file);
        var finalRegExp = project.interpolatePath(regexp);
        var finalReplacement = project.interpolatePath(replacement);
        if (!FileSystem.exists(finalFile)) {
            throw "file not found: " + finalFile;
        }

        // haxe xml parse seems to do some odd things with slashes (i think)
        finalRegExp = finalRegExp.replace("/s", "\\s");
        finalRegExp = finalRegExp.replace("/", "\\/");
        finalRegExp = finalRegExp.replace("\\/s", "\\s");
        finalRegExp = finalRegExp.replace("\"", "\\\"");

        var fileContent = File.getContent(finalFile);

        var ereg = new EReg(finalRegExp, "gm");
        var newFileContent = ereg.map(fileContent, (r) -> {
            var newLine = r.matched(0).replace(r.matched(1), finalReplacement);
            return newLine;
        });

        File.saveContent(finalFile, newFileContent);
    }

    public override function parse(doc:XmlDocument) {
        file = doc.attr("file");
        regexp = doc.attr("regexp");
        replacement = doc.attr("replacement");
    }
}