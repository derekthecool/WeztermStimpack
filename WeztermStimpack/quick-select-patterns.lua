return {
    -- Windows paths
    '[C-Z]:\\S+',

    -- Command-line args from help print outs
    -- --help
    -- --version
    -- -H
    '--\\S+',

    -- IMEI numbers
    -- 123450678912345
    [[\b\d{15}\b]],

    -- ICCID numbers
    -- 12345067891234506789
    [[\b\d{20}\b]],

    -- Powershell item variables
    -- $env:APPDATA
    -- $env:LOCALAPPDATA/test/file.txt
    -- $env:LOCALAPPDATA\test\file.txt
    [[\$[eE][nN][vV]:\S+]],

    -- Common filenames
    --[[
    MyFile.log
    test.txt
    ]]
    [[\S+?\.(?:log|txt)]],
}
