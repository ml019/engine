[#ftl]

[@addInputSeeder
    id=SHARED_INPUT_SEEDER
    description="Shared inputs"
/]

[@addSeederToInputStage
    inputStage=COMMANDLINEOPTIONS_SHARED_INPUT_STAGE
    inputSeeder=SHARED_INPUT_SEEDER
/]

[@addSeederToInputStage
    inputStage=MASTERDATA_SHARED_INPUT_STAGE
    inputSeeder=SHARED_INPUT_SEEDER
/]

[@addSeederToInputStage
    inputStage=QUALIFY_SHARED_INPUT_STAGE
    inputSeeder=SHARED_INPUT_SEEDER
/]

[#macro shared_input_loader path]
    [#assign shared_cmdb_masterdata =
        (
            getPluginTree(
                path,
                {
                    "AddStartingWildcard" : false,
                    "AddEndingWildcard" : false,
                    "MinDepth" : 1,
                    "MaxDepth" : 1,
                    "FilenameGlob" : "masterdata.json"
                }
            )[0].ContentsAsJSON
        )!{}
    ]
[/#macro]

[#function shared_input_masterdata_seeder filter state]

    [#return
        mergeObjects(
            state,
            {
                "Masterdata" : shared_cmdb_masterdata
            }
        )
    ]

[/#function]

[#function shared_input_commandlineoptions_seeder filter state]

    [#return
        mergeObjects(
            state,
            {
                "CommandLineOptions" : {
                    [#-- Entrance --]
                    "Entrance" : {
                        "Type" : entrance!"deployment"
                    },
                    [#-- Flows --]
                    "Flow" : {
                        "Names" : asArray( flows?split(",") )![]
                    },
                    [#-- Input data control --]
                    "Input" : {
                        "Source" : inputSource!"composite"
                    },
                    [#-- load the plugin state from setup --]
                    "Plugins" : {
                        "State" : (pluginState!"")?has_content?then(
                                        pluginState?eval,
                                        {}
                        )
                    },
                    [#-- Deployment Details --]
                    "Deployment" : {
                        "Provider" : {
                            "Names" : (providers!"")?has_content?then(
                                            providers?split(","),
                                            []
                            )
                        },
                        "Framework" : {
                            "Name" : deploymentFramework!"default"
                        },
                        "Output" : {
                            "Type" : outputType!"",
                            "Format" : outputFormat!"",
                            "Prefix" : outputPrefix!""
                        },
                        "Group" : {
                            "Name" : deploymentGroup!""
                        },
                        "Unit" : {
                            "Name" : deploymentUnit!"",
                            "Subset" : deploymentUnitSubset!"",
                            "Alternative" : alternative!""
                        },
                        "ResourceGroup" : {
                            "Name" : resourceGroup!""
                        },
                        "Mode" : deploymentMode!""
                    },
                    [#-- Layer Details --]
                    "Layers" : {
                        "Tenant" : tenant!"",
                        "Account" : account!"",
                        "Product" : product!"",
                        "Environment" : environment!"",
                        "Segment" : segment!""
                    },
                    [#-- Logging Details --]
                    "Logging" : {
                        "Level" : logLevel!""
                    },
                    [#-- RunId details --]
                    "Run" : {
                        "Id" : runId!""
                    }
                }
            }
        )
    ]
[/#function]

[#function shared_input_commandlineoptions_composite_seeder filter state]
    [#return
        mergeObjects(
            shared_input_commandlineoptions_seeder(filter, state),
            {
                "CommandLineOptions" : {
                    "References" : {
                        "Request" : requestReference!"",
                        "Configuration" : configurationReference!""
                    },
                    "Composites" : {
                        "Blueprint" : (blueprint!"")?has_content?then(
                                            blueprint?eval,
                                            {}
                        ),
                        "Settings" : (settings!"")?has_content?then(
                                            settings?eval,
                                            {}
                        ),
                        "Definitions" : ((definitions!"")?has_content && (!definitions?contains("null")))?then(
                                            definitions?eval,
                                            {}
                        ),
                        "StackOutputs" : (stackOutputs!"")?has_content?then(
                                            stackOutputs?eval,
                                            []
                        )
                    },
                    "Regions" : {
                        "Segment" : region!"",
                        "Account" : accountRegion!""
                    }
                }
            }
        )
    ]
[/#function]

[#function shared_input_commandlineoptions_mock_seeder filter state]
    [#return
        mergeObjects(
            shared_input_commandlineoptions_seeder(filter, state),
            {
                "CommandLineOptions" : {
                    "Regions" : {
                        "Segment" : "mock-region-1",
                        "Account" : "mock-region-1"
                    },
                    "References" : {
                        "Request" : "SRVREQ01",
                        "Configuration" : "configRef_v123"
                    },
                    "Run" : {
                        "Id" : "runId098"
                    }
                }
            }
        )
    ]
[/#function]

[#function shared_input_commandlineoptions_whatif_seeder filter state]
    [#return shared_input_commandlineoptions_composite_seeder(filter, state)]
[/#function]

[#function shared_input_qualify_seeder filter state]
    [#return qualifyEntity(state, filter) ]
[/#function]
