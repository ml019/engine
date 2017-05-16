[#ftl]

[#if idList??][#include idList][/#if]
[#if nameList??][#include nameList][/#if]
[#if policyList??][#include policyList][/#if]
[#include "common.ftl"]

[#-- Standard inputs --]
[#assign blueprintObject = blueprint?eval]
[#assign credentialsObject = (credentials?eval).Credentials]                    
[#assign appSettingsObject = appsettings?eval]
[#assign stackOutputsObject = stackOutputs?eval]

[#-- Reference data --]
[#assign regions = blueprintObject.Regions]
[#assign environments = blueprintObject.Environments]
[#assign categories = blueprintObject.Categories]
[#assign routeTables = blueprintObject.RouteTables]
[#assign networkACLs = blueprintObject.NetworkACLs]
[#assign storage = blueprintObject.Storage]
[#assign processors = blueprintObject.Processors]
[#assign ports = blueprintObject.Ports]
[#assign portMappings = blueprintObject.PortMappings]
[#assign powersOf2 = blueprintObject.PowersOf2]

[#-- Region --]
[#if region??]
    [#assign regionId = region]
    [#assign regionObject = regions[regionId]]
    [#assign regionName = regionObject.Name]
[/#if]

[#-- Tenant --]
[#if blueprintObject.Tenant??]
    [#assign tenantObject = blueprintObject.Tenant]
    [#assign tenantId = tenantObject.Id]
    [#assign tenantName = tenantObject.Name]
[/#if]

[#-- Account --]
[#if blueprintObject.Account??]
    [#assign accountObject = blueprintObject.Account]
    [#assign accountId = accountObject.Id]
    [#assign accountName = accountObject.Name]
    [#if accountRegion??]
        [#assign accountRegionId = accountRegion]
        [#assign accountRegionObject = regions[accountRegionId]]
        [#assign accountRegionName = accountRegionObject.Name]
    [/#if]
    [#assign credentialsBucket = getKey("s3","account", "credentials")]
    [#assign codeBucket = getKey("s3","account","code")]
    [#assign registryBucket = getKey("s3", "account", "registry")]
[/#if]

[#-- Product --]
[#if blueprintObject.Product??]
    [#assign productObject = blueprintObject.Product]
    [#assign productId = productObject.Id]
    [#assign productName = productObject.Name]
    [#if productRegion??]
        [#assign productRegionId = productRegion]
        [#assign productRegionObject = regions[productRegionId]]
        [#assign productRegionName = productRegionObject.Name]
    [/#if]
[/#if]

[#-- Segment --]
[#if blueprintObject.Segment??]
    [#assign segmentObject = blueprintObject.Segment]
    [#assign segmentId = segmentObject.Id]
    [#assign segmentName = segmentObject.Name]
    [#assign sshPerSegment = segmentObject.SSHPerSegment]
    [#assign internetAccess = segmentObject.InternetAccess]
    [#assign jumpServer = internetAccess && segmentObject.NAT.Enabled]
    [#assign jumpServerPerAZ = jumpServer && segmentObject.NAT.MultiAZ]
    [#assign operationsBucket = "unknown"]
    [#assign operationsBucketSegment = "segment"]
    [#assign operationsBucketType = "ops"]
    [#if getKey(formatSegmentS3Id("ops"))?has_content]
        [#assign operationsBucket = getKey(formatSegmentS3Id("ops"))]        
    [/#if]
    [#if getKey(formatSegmentS3Id("operations"))?has_content]
        [#assign operationsBucket = getKey(formatSegmentS3Id("operations"))]        
        [#assign operationsBucketType = "operations"]
    [/#if]
    [#if getKey(formatSegmentS3Id("logs"))?has_content]
        [#assign operationsBucket = getKey(formatSegmentS3Id("logs"))]        
        [#assign operationsBucketType = "logs"]
    [/#if]
    [#if getKey(formatContainerS3Id("logs"))?has_content]
        [#assign operationsBucket = getKey(formatContainerS3Id("logs"))]        
        [#assign operationsBucketSegment = "container"]
        [#assign operationsBucketType = "logs"]
    [/#if]
    [#assign dataBucket = "unknown"]
    [#assign dataBucketSegment = "segment"]
    [#assign dataBucketType = "data"]
    [#if getKey(formatSegmentS3Id("data"))?has_content]
        [#assign dataBucket = getKey(formatSegmentS3Id("data"))]        
    [/#if]
    [#if getKey(formatSegmentS3Id("backups"))?has_content]
        [#assign dataBucket = getKey(formatSegmentS3Id("backups"))]        
        [#assign dataBucketType = "backups"]
    [/#if]
    [#if getKey(formatContainerS3Id("backups"))?has_content]
        [#assign dataBucket = getKey(formatContainerS3Id("backups"))]        
        [#assign dataBucketSegment = "container"]
        [#assign dataBucketType = "backups"]
    [/#if]
    [#assign segmentDomain = getKey(formatSegmentDomainId())]
    [#assign segmentDomainQualifier = getKey(formatSegmentDomainQualifierId())]
    [#assign certificateId = getKey(formatSegmentDomainCertificateId())]
    [#assign vpc = getKey(formatVPCId())]
    [#assign securityGroupNAT = getKey(formatComponentSecurityGroupId(
                                        "mgmt",
                                        "nat"))]
    [#if segmentObject.Environment??]
        [#assign environmentId = segmentObject.Environment]
        [#assign environmentObject = environments[environmentId]]
        [#assign environmentName = environmentObject.Name]
        [#assign categoryId = segmentObject.Category!environmentObject.Category]
        [#assign categoryObject = categories[categoryId]]
    [/#if]
[/#if]

[#-- Solution --]
[#if blueprintObject.Solution??]
    [#assign solutionObject = blueprintObject.Solution]
    [#assign solnMultiAZ = solutionObject.MultiAZ!(environmentObject.MultiAZ)!false]
[/#if]

[#-- Required tiers --]
[#assign tiers = []]
[#list segmentObject.Tiers.Order as tierId]
    [#if isTier(tierId)]
        [#assign tier = getTier(tierId)]
        [#if tier.Components??
            || ((tier.Required)?? && tier.Required)
            || (jumpServer && (tierId == "mgmt"))]
            [#assign tiers += [tier + 
                {"Index" : tierId?index}]]
        [/#if]
    [/#if]
[/#list]

[#-- Required zones --]
[#assign zones = []]
[#list segmentObject.Zones.Order as zoneId]
    [#if regions[region].Zones[zoneId]??]
        [#assign zone = regions[region].Zones[zoneId]]
        [#assign zones += [zone +  
            {"Index" : zoneId?index}]]
    [/#if]
[/#list]


