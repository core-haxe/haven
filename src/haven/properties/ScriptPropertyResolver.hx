package haven.properties;

class ScriptPropertyResolver extends PropertyResolver {
    public override function resolve(name:String):String {
        var expr = name;
        var parser = new hscript.Parser();
        var ast = parser.parseString(expr);
        var interp = new hscript.Interp();

        interp.variables.set("Date", Date);
        interp.variables.set("now", Date.now);
        interp.variables.set("DateTools", DateTools);
        interp.variables.set("formatDate", DateTools.format);

        interp.variables.set("Std", Std);
        interp.variables.set("str", Std.string);

        return Std.string(interp.execute(ast));
    }
}