package haven.commands.modules;

import haven.util.XmlDocument;
import haven.project.Project;

class ForEachModuleCommand extends Command {
    private var children:Array<XmlDocument>;
    public override function exec(project:Project) {
        trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>> DO IT");
        trace(project.rootProject.name);
        trace(project.rootProject.allModules.length);
        var moduleList = project.rootProject.allModules;
        for (module in moduleList) {
            //trace(module.name, module.path);
            Sys.println(' ${module.name}');
            for (commandDoc in children) {
                var command = CommandFactory.create(commandDoc.nodeName);
                if (command == null) {
                    throw "could not find command for '" + commandDoc.nodeName + "'";
                    continue;
                }
    
                command.parse(commandDoc);
                command.exec(module);
            }
            Sys.println('');
        }
    }

    public override function parse(doc:XmlDocument) {
        this.children = doc.children();
    }
}