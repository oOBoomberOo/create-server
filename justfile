build mem="2G":
    just build_raw 'out/raw.zip'
    just build_instance 'out/instance.zip'
    just build_server 'out/server.zip' 'forge-installer.jar' {{mem}}

prepare:
    mkdir -p out/

build_server dest installer mem="2G": prepare
    #!/usr/bin/env sh
    workdir=$(mktemp -d -t liviryn-XXXXXXX)

    cp -r "input/.minecraft/config/" $workdir/config
    cp -r "input/.minecraft/mods/" $workdir/mods

    java -jar {{installer}} --installServer $workdir/

    cd $workdir

    echo "Debug:" $(ls .)

    mv forge*.jar server.jar
    echo "java -Xmx{{mem}} -jar server.jar --nogui" > start.sh

    rm installer.jar

    zip -r compress.zip *
    cd {{invocation_directory()}}
    mv $workdir/compress.zip {{dest}}

    rm -rf $workdir

build_instance dest: prepare
    #!/usr/bin/env sh
    workdir=$(mktemp -d -t liviryn-XXXXXXX)

    cp -r "input/.packignore" "input/instance.cfg" "input/mmc-pack.json" $workdir
    mkdir -p $workdir/.minecraft
    cp -r "input/.minecraft/config/" "input/.minecraft/mods/" $workdir/.minecraft
    
    cd $workdir
    zip -r compress.zip * .minecraft .packignore
    cd {{invocation_directory()}}
    mv $workdir/compress.zip {{dest}}

    rm -rf $workdir

build_raw dest: prepare
    #!/usr/bin/env sh
    workdir=$(mktemp -d -t liviryn-XXXXXXX)
    cp -r "input/.minecraft/config/" "input/.minecraft/mods/" $workdir
    rm {{dest}}

    cd $workdir
    zip -r compress.zip *
    cd {{invocation_directory()}}
    mv $workdir/compress.zip {{dest}}

    rm -rf $workdir
