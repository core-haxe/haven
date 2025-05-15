package haven.commands;

import haven.commands.Command;

class CommandFactory {
    private static var commands:Map<String, CommandData> = [];

    public static function create(name:String):Command {
        registerInternalCommands();
        var data = commands.get(name);
        if (data == null) {
            return null;
        }
        var c = data.ctor();
        return c;
    }

    public static function register(name:String, ctor:Void->Command) {
        registerInternalCommands();
        commands.set(name, {
            ctor: ctor
        });
    }

    private static var _internalCommandsRegistered:Bool = false;
    private static function registerInternalCommands() {
        if (_internalCommandsRegistered) {
            return;
        }
        _internalCommandsRegistered = true;

        register("cmd", haven.commands.general.CmdCommand.new);
        register("set-env-var", haven.commands.general.SetEnvironmentVariableCommand.new);
        register("set-environment-variable", haven.commands.general.SetEnvironmentVariableCommand.new);
        register("set-var", haven.commands.general.SetVariableCommand.new);
        register("set-variable", haven.commands.general.SetVariableCommand.new);
        register("set-prop", haven.commands.general.SetVariableCommand.new);
        register("set-property", haven.commands.general.SetVariableCommand.new);
        register("for-each", haven.commands.general.ForEachCommand.new);

        register("mkdir", haven.commands.fs.MkDirCommand.new);
        register("copy-file", haven.commands.fs.CopyFileCommand.new);
        register("copy-dir", haven.commands.fs.CopyDirCommand.new);
        register("del-file", haven.commands.fs.DeleteFileCommand.new);
        register("delete-file", haven.commands.fs.DeleteFileCommand.new);

        register("log", haven.commands.util.LogCommand.new);

        register("haxe", haven.commands.haxe.HaxeCommand.new);
        register("haxelib", haven.commands.haxelib.HaxelibCommand.new);

        register("npm", haven.commands.npm.NpmCommand.new);

        register("pm2", haven.commands.pm2.Pm2Command.new);

        register("structure", haven.commands.structure.StructureCommand.new);

        register("archive", haven.commands.archive.ArchiveCommand.new);

        register("git", haven.commands.git.GitCommand.new);

        register("xpath-set", haven.commands.xpath.XPathSetCommand.new);

        register("regexp-replace", haven.commands.regexp.RegExpReplaceCommand.new);

        register("for-each-module", haven.commands.modules.ForEachModuleCommand.new);
        register("with-each-module", haven.commands.modules.ForEachModuleCommand.new);

        register("json-path", haven.commands.json.JsonPathCommand.new);

    }
}

typedef CommandData = {
    var ctor:Void->Command;
}