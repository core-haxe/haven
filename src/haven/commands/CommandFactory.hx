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

        register("mkdir", haven.commands.fs.MkDirCommand.new);
        register("copy-file", haven.commands.fs.CopyFileCommand.new);

        register("log", haven.commands.util.LogCommand.new);

        register("haxe", haven.commands.haxe.HaxeCommand.new);
        register("haxelib", haven.commands.haxelib.HaxelibCommand.new);

        register("npm", haven.commands.npm.NpmCommand.new);

        register("pm2", haven.commands.pm2.Pm2Command.new);

        register("structure", haven.commands.structure.StructureCommand.new);
    }
}

typedef CommandData = {
    var ctor:Void->Command;
}