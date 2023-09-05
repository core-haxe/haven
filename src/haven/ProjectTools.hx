package haven;

import haven.project.Project;

class ProjectTools {
    public static function printStructure(project:Project) {
        _printStructure(project);
    }

    private static function _printStructure(project:Project, indent:String = "") {
        var name = project.name;
        if (project.group != null) {
            name = project.group + "::" + name;
        }
        Sys.println(indent + " - " + name + ":" + project.version);
        for (module in project.modules) {
            _printStructure(module, indent + "  ");
        }
    }
}