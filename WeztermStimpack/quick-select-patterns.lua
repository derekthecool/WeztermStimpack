return {
    -- Windows paths
    '[C-Z]:\\S+',

    -- Command-line args from help print outs
    '--\\S+',

    -- IMEI numbers
    [[\b\d{15}\b]],

    -- ICCID numbers
    [[\b\d{20}\b]],
}
