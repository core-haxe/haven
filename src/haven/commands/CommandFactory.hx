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

        register("haxe", haven.commands.haxe.HaxeCommand.new);

        register("mkdir", haven.commands.fs.MkDirCommand.new);
        register("copy-file", haven.commands.fs.CopyFileCommand.new);

        register("npm", haven.commands.npm.NpmCommand.new);
    }
}

typedef CommandData = {
    var ctor:Void->Command;
}