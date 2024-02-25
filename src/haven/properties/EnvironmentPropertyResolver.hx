package haven.properties;

class EnvironmentPropertyResolver extends PropertyResolver {
    public override function resolve(name:String):String {
        var value = Sys.getEnv(name);
        if (value == null) {
            throw 'environment variable "${name}" not found';
        }

        return value;
    }
}