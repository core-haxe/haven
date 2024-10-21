package haven.properties;

import sys.FileSystem;
import haxe.io.Path;
import haven.project.Properties;

using StringTools;

class ProfilePropertyResolver extends PropertyResolver {
    public override function resolve(name:String):String {
        var props:Properties = null;
        var candidate1 = Path.normalize(Paths.rootDir + "/.haven-profile");
        var candidate2 = Path.normalize(Paths.rootDir + "/../.haven-profile");
        var candidate3 = Path.normalize(Paths.workingDir + "/.haven-profile");
        var props1:Properties = Properties.fromFile(candidate1);
        var props2:Properties = Properties.fromFile(candidate2);
        var props3:Properties = Properties.fromFile(candidate3);
        var finalProps:Properties = new Properties();
        finalProps.merge(props1);
        finalProps.merge(props2);
        finalProps.merge(props3);

        var propValue = finalProps.get(name);
        if (propValue == null || propValue.trim().length == 0) {
            throw 'profile variable "${name}" not found';
        }

        return propValue;
    }
}