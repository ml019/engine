[#ftl]

[#macro shared_entrance_deployment ]

    [#local options = getInputCommandLineOptions() ]

    [#local deploymentGroupDetails = getDeploymentGroupDetails(getDeploymentGroup())]
    [#local compositeTemplateContent = (.vars[deploymentGroupDetails.CompositeTemplate])!"" ]

    [#-- ResourceSets  --]
    [#-- Seperates resources from their component templates in to their own deployment --]
    [#list ((deploymentGroupDetails.ResourceSets)!{})?values?filter(s -> s.Enabled ) as resourceSet ]
        [#if getDeploymentUnit() == resourceSet["deployment:Unit"] ]

            [#assign groupDeploymentUnits = true]
            [#assign ignoreDeploymentUnitSubsetInOutputs = true]

            [#assign contractSubsets = []]
            [#list resourceSet.ResourceLabels as label ]
                [#assign resourceLabel = getResourceLabel(label, getDeploymentLevel()) ]
                [#assign contractSubsets = combineEntities( contractSubsets, (resourceLabel.Subsets)![], UNIQUE_COMBINE_BEHAVIOUR ) ]
            [/#list]

            [#if (options.Deployment.Unit.Subset!"") == "generationcontract"]
                [#assign groupDeploymentUnits = false]
                [#assign ignoreDeploymentUnitSubsetInOutputs = false]

                [#-- We need to initialise the outputs here since we are adding to it out side of the component flow --]
                [@addDefaultGenerationContract subsets=contractSubsets /]
            [/#if]
        [/#if]
    [/#list]

    [@generateOutput
        deploymentFramework=options.Deployment.Framework.Name
        type=options.Deployment.Output.Type
        format=options.Deployment.Output.Format
        level=getDeploymentLevel()
        include=compositeTemplateContent
    /]

[/#macro]

[#-- Extra command line options --]
[#macro shared_entrance_deployment_seeder ]

  [#local inputSeeder = "deployment" ]

  [@addInputSeeder
      id=inputSeeder
      description="Entrance options"
  /]

  [@addSeederToInputStage
  inputStage=COMMANDLINEOPTIONS_SHARED_INPUT_STAGE
  inputSeeder=inputSeeder
  /]

[/#macro]

[#function deployment_input_commandlineoptions_seeder filter state ]

    [#local options = state.CommandLineOptions!{} ]
    [#local deploymentGroupDetails = getDeploymentGroupDetails(getDeploymentGroup())]

    [#list ((deploymentGroupDetails.ResourceSets)!{})?values?filter(s -> s.Enabled ) as resourceSet ]
        [#if getDeploymentUnit() == resourceSet["deployment:Unit"] ]

            [#if !(options.Deployment.Unit.Subset?has_content)]
                [#local options =
                    mergeObjects(
                        options,
                        {
                            "Deployment" : {
                                "Unit" : {
                                    "Subset" : getDeploymentUnit()
                                }
                            }
                        }
                    )
                ]
            [/#if]
        [/#if]
    [/#list]

    [#return
        mergeObjects(
            state,
            {
                "CommandLineOptions" : options
            }
        )
    ]
[/#function]