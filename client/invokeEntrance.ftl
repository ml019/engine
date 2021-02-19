[#ftl]
[#include "/bootstrap.ftl" ]

[#-- Load the entrance to make sure that it is defined --]
[#assign entranceType = getInputCommandLineOptions().Entrance.Type ]
[#assign entranceEntry = getEntrance(entranceType) ]

[#--
Ensure any entrance specific input seeding is performed before attempting to validate the inputs.
--]
[@addEntranceSeeder entranceType /]

[#-- Validate Command line options are right for the entrance --]
[#assign validCommandLineOptions = getCompositeObject(entranceEntry.Configuration, getInputCommandLineOptions()) ]

[#-- Find and invoke the Entrance Macro --]
[#-- Entrances provided by explicit providers are preferred over the shared provider --]
[@invokeEntranceMacro
    type=entranceType
/]
