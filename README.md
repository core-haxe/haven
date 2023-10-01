# haven

Haven is a build automation tool inspired by Maven written in Haxe. Hence the name.

There are multiple reasons to use it.

- it uses a **Project Object Model (POM)** which describes a project, its dependencies and the build order.
- it has multiple predefined commands that are compatible with both Linux/Windows



## Installing the haven library



```bash
haxelib git haven https://github.com/core-haxe/haven.git
```



## Building a project that uses haven



Every project that uses haven, will have a `haven.xml` in the root folder.

To build it simply do

``` bash
haxelib run haven
```



What does it do, we can check the `haven.xml`

```xml
<chains>
    <all default="true">
        <copy-config />
        <build />
        <install />
    </all>
</chains>
```



We see it does simply

```bash
haxelib run haven copy-config
haxelib run haven build
haxelib run haven install
```



There are no way to see all commands for now. So you have to open the different `haven.xml` and look at the commands

```xml
<commands>
    <copy-config>
        <!---->
    </copy-config>
    <build>
        <!---->
    </build>
</commands>
```





??? If it doesn't have chains

(??? can a chain make a reference to another chain)

## Understanding the POM description file



Every `haven.xml` has this structure

```xml
<project>
    <group>blabla::blabla::examples</group>
    <name>example</name>
    <version>0.0.0</version>
    
    <!-- optional -->
    <modules>
		<!---->
	</modules>
    <dependencies>
		<!---->
	</dependencies>
    <commands>
        <!---->
    </commands>
    <chains>
		<!---->
	</chains>
    <properties>
        <!---->
    </properties>
</project>
```



For now, `group`  `name` and `version` is only used for logging purpose.  



### modules

```xml
<modules>
    <module>libs</module>
    <module>../../other-libs</module>
</modules>
```

module makes reference  to the path to a folder containing a pom file relative to the folder of the actual haven.xml.

You cannot use absolute paths for now.

What does it mean ?  When running a chain, it will look for all commands in the chain in order and if it exists run the command in each module.



For example, if have the modules 

```xml
<modules>
    <module>carrots</module>
    <module>potatoes</module>
    <module>frozen-peas</module>
</modules>
```

and we have the chain

```xml
<chains>
	<all default="true">
        <unfreeze/>
        <peel/>
        <cut/>
    </all>
</chains>
```

It will unfreeze the frozen peas, peel the carrots and the potatoes,  cut the carrots and the potatoes



### commands

```xml
<commands>
    <hello>
        <log message="hello everyone!" />
    </hello>
    <copy-stuff>
        <copy-file source="${baseDir}/first.json" destination="${configDir}/first.json" />
        <copy-file source="${baseDir}/second.json" destination="${configDir}/second.json" />
    </copy-stuff>
    <build>
        <haxe target="js" output="${buildDir}/example.js" main="examples.Example" cleanUp="false" outputFilename="html5.hxml">
    </build>
</commands>
```

You can create tasks in the the pom file. Here you can see there are 3 tasks `hello` `copy-stuff` and `build`

These 3 tasks are made of a number commands with parameters.

Here are the most important predefined commands

#### The `haxe` command

The `haxe` command creates a `.hxml` that it builds.

As such, you have access to all usual haxe compiler flags

```xml
<haxe target="js" output="${buildDir}/bundle-test.js" main="esb.core.BundleLoader" cleanUp="false" outputFilename="nodejs.hxml">
    <dependencies>
        <dependency>promises</dependency>
    </dependencies>
    <class-paths>
        <class-path>src</class-path>
    </class-paths>
    <compiler-args>
        <compiler-arg>--macro include('impact.bundles.test')</compiler-arg>
        <compiler-arg>-cmd haxelib run haven copy-config</compiler-arg>
    </compiler-args>
    <compiler-defines>
        <compiler-define>no-deprecation-warnings</compiler-define>
    </compiler-defines>
</haxe>
```

Everything is self explanatory.

Only a few  differences  `dependency` is used instead of `library`

`cleanUp="true"` means the hxml file will be deleted



#### The `cmd` command

```xml 
<cmd command=""  workingDir="" stdout="false" />
```





##  chains



```xml
<chains>
    <all default="true">
        <stop-esb />
        <copy-config />
        <build />
        <install />
        <start-esb />
    </all>
</chains>
```





## properties



```xml
<properties>
    <property name="buildDir" value="${rootDir}/bin" />
    <property name="configDir" value="${buildDir}/config" />
</properties>
```



These properties will be easily accessible in other haven.xml files





By default there are a few defined properties `rootDir` where the top haven.xml with a chain is (????)    and  `baseDir`  the directory where the `haven.xml` is



