package haven.properties;

class PropertyResolverFactory {
    private static var resolvers:Map<String, Void->PropertyResolver> = [];

    public static function registerResolver(name:String, ctor:Void->PropertyResolver) {
        resolvers.set(name, ctor);
    }

    public static function getResolver(name:String):PropertyResolver {
        registerInternalResolvers();

        var ctor = resolvers.get(name);
        if (ctor == null) {
            throw 'could not find property resolver for "${name}"';
        }

        return ctor();
    }

    private static var _internalResolversRegistered:Bool = false;
    private static function registerInternalResolvers() {
        if (_internalResolversRegistered) {
            return;
        }

        _internalResolversRegistered = true;

        registerResolver("env", EnvironmentPropertyResolver.new);
        registerResolver("environment", EnvironmentPropertyResolver.new);
        registerResolver("haxelib", HaxelibPropertyResolver.new);
    }
}