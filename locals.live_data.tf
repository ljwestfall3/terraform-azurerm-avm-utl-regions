# Implement an anti-coprruption layer to transform the data from the Azure API into a format that is easier to work with in the rest of the module.
locals {
  live_locations_list = !var.use_cached_data ? tolist([
    for location in data.azapi_resource_action.locations[0].output.value : {
      display_name       = location.displayName
      geography          = location.metadata.geography
      geography_group    = lookup(location.metadata, "geographyGroup", null)
      name               = location.name
      paired_region_name = try(one(location.metadata.pairedRegion).name, null)
      recommended        = location.metadata.regionCategory == "Recommended"
      zones              = tolist([for zone in try(location.availabilityZoneMappings, []) : tonumber(zone.logicalZone)])
      geo_code           = try(local.geo_codes_by_name[location.name], null)
    } if location.metadata.regionType == "Physical"
  ]) : []
}
