[#case "codeontap"]
[#case "_codeontap"]
[#case "_hamlet"]
[#case "hamlet"]

    [#assign settings = _context.DefaultEnvironment]

    [#assign dockerStageDir = settings["DOCKER_STAGE_DIR"]!"/tmp/docker-build" ]
    [#assign dockerHostDaemon = settings["DOCKER_HOST_DAEMON"]!"/var/run/docker.sock"]
    [#assign jenkinsAgentImage = settings["DOCKER_AGENT_IMAGE"]!"hamletio/hamlet"]
    [#assign awsAgentAutomationRole = settings["AWS_AUTOMATION_ROLE"]!"codeontap-automation" ]

    [@Attributes image=jenkinsAgentImage /]

    [@DefaultLinkVariables          enabled=false /]
    [@DefaultCoreVariables          enabled=false /]
    [@DefaultEnvironmentVariables   enabled=false /]
    [@DefaultBaselineVariables      enabled=false /]

    [@Settings {
        "AWS_AUTOMATION_USER" : "ROLE",
        "AWS_AUTOMATION_ROLE" : awsAgentAutomationRole,
        "DOCKER_STAGE_DIR" : dockerStageDir
    }/]

    [@Volume
        name="dockerDaemon"
        containerPath="/var/run/docker.sock"
        hostPath=dockerHostDaemon
    /]
    [@Volume
        name="dockerStage"
        containerPath=dockerStageDir
        hostPath=dockerStageDir
    /]

    [#-- Validate that the appropriate settings have been provided for the container to work --]
    [#if settings["CODEONTAPVOLUME"]?has_content ]
        [@Volume
            name="codeontap"
            containerPath="/var/opt/codeontap/"
            hostPath=settings["CODEONTAPVOLUME"]
            readOnly=true
        /]
    [#elseif settings["PROPERTIESVOLUME"]?has_content ]
        [@Volume
            name="codeontap"
            containerPath="/var/opt/codeontap/"
            hostPath=settings["PROPERTIESVOLUME"]
            readOnly=true
        /]
    [/#if]

    [#-- Validate that the appropriate settings have been provided for the container to work --]
    [#if settings["PROPERTIESVOLUME"]?has_content ]
        [@Volume
            name="properties"
            containerPath=(settings["PROPERTIES_DIR"])!"/var/opt/properties/"
            hostPath=settings["PROPERTIESVOLUME"]
            readOnly=true
        /]
    [/#if]

    [#if settings["AWS_AUTOMATION_POLICIES"]?has_content ]
        [@ManagedPolicy settings["AWS_AUTOMATION_POLICIES"]?split(",") /]
    [/#if]

    [#if (settings["AWS_AUTOMATION_ACCOUNTS"]!"")?has_content ]
        [#assign automationAccounts = asArray( (settings["AWS_AUTOMATION_ACCOUNTS"]!"")?eval ) ]

        [#assign automationAccountRoles = []]
        [#list automationAccounts as automationAccount ]
            [#assign automationAccountRoles += [
                                                    formatGlobalArn(
                                                        "iam",
                                                        formatRelativePath("role", awsAgentAutomationRole),
                                                        automationAccount  )
                                                ]]
        [/#list]

        [@Policy
            [
                getPolicyStatement( ["sts:AssumeRole"], automationAccountRoles)
            ]
        /]
    [/#if]
    [#break]

[#case "_jenkinsecs" ]
    [#assign settings = _context.DefaultEnvironment]

    [#-- The docker stage dir is used to provide a staging location for docker in docker based builds which use the host docker instance --]
    [#assign dockerStageDirs =
            (settings["DOCKER_STAGE_DIR"])?has_content?then(
                    asArray(settings["DOCKER_STAGE_DIR"]),
                    settings["DOCKER_STAGE_DIRS"]?has_content?then(
                        asArray( (settings["DOCKER_STAGE_DIRS"]?split(",") )),
                        [ "/tmp/docker-build" ]
                    )
            )]

    [#list dockerStageDirs as dockerStageDir]
        [@Directory
            path=dockerStageDir
            mode="775"
            owner="1000"
            group="1000"
        /]
    [/#list]
    [#break]
