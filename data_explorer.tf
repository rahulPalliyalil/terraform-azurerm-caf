module "kusto_clusters" {
  source   = "./modules/databases/data_explorer/kusto_clusters"
  for_each = local.database.data_explorer.kusto_clusters

  global_settings     = local.global_settings
  client_config       = local.client_config
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  base_tags           = try(local.global_settings.inherit_tags, false) ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags : {}

  combined_resources = {
    vnets              = local.combined_objects_networking
    pips               = local.combined_objects_public_ip_addresses
    managed_identities = local.combined_objects_managed_identities
  }
}
output "kusto_clusters" {
  value = module.kusto_clusters
}

module "kusto_databases" {
  source   = "./modules/databases/data_explorer/kusto_databases"
  for_each = local.database.data_explorer.kusto_databases

  global_settings     = local.global_settings
  client_config       = local.client_config
  settings            = each.value
  location            = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  cluster_name        = can(each.value.kusto_cluster.name) ? each.value.kusto_cluster.name : local.combined_objects_kusto_clusters[try(each.value.kusto_cluster.lz_key, local.client_config.landingzone_key)][each.value.kusto_cluster.key].name

}
output "kusto_databases" {
  value = module.kusto_clusters
}

module "kusto_attached_database_configurations" {
  source   = "./modules/databases/data_explorer/kusto_attached_database_configurations"
  for_each = local.database.data_explorer.kusto_attached_database_configurations

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  location        = lookup(each.value, "region", null) == null ? local.resource_groups[each.value.resource_group.key].location : local.global_settings.regions[each.value.region]


  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name
  cluster_name        = can(each.value.kusto_cluster.name) ? each.value.kusto_cluster.name : local.combined_objects_kusto_clusters[try(each.value.kusto_cluster.lz_key, local.client_config.landingzone_key)][each.value.kusto_cluster.key].name
  cluster_resource_id = can(each.value.kusto_cluster.id) ? each.value.kusto_cluster.id : local.combined_objects_kusto_clusters[try(each.value.kusto_cluster.lz_key, local.client_config.landingzone_key)][each.value.kusto_cluster.key].id
  database_name       = can(each.value.kusto_database.name) ? each.value.kusto_database.name : local.combined_objects_kusto_databases[try(each.value.kusto_database.lz_key, local.client_config.landingzone_key)][each.value.database.key].name
}

output "kusto_attached_database_configurations" {
  value = module.kusto_attached_database_configurations
}
module "kusto_database_principal_assignments" {
  source   = "./modules/databases/data_explorer/kusto_database_principal_assignments"
  for_each = local.database.data_explorer.kusto_database_principal_assignments

  global_settings     = local.global_settings
  client_config       = local.client_config
  settings            = each.value
  location            = lookup(each.value, "region", null) == null ? local.resource_groups[each.value.resource_group.key].location : local.global_settings.regions[each.value.region]
  resource_group_name = can(each.value.resource_group.name) || can(each.value.resource_group_name) ? try(each.value.resource_group.name, each.value.resource_group_name) : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group_key, each.value.resource_group.key)].name

  cluster_name  = can(each.value.kusto_cluster.name) ? each.value.kusto_cluster.name : local.combined_objects_kusto_clusters[try(each.value.kusto_cluster.lz_key, local.client_config.landingzone_key)][each.value.kusto_cluster.key].name
  database_name = can(each.value.kusto_database.name) ? each.value.kusto_database.name : local.combined_objects_kusto_databases[try(each.value.kusto_database.lz_key, local.client_config.landingzone_key)][each.value.database.key].name
  principal_id  = can(each.value.principal.id) ? each.value.principal.id : local.combined_objects_azuread_service_principals[try(each.value.principal.lz_key, local.client_config.landingzone_key)][each.value.principal.key].object_id
  tenant_id     = can(each.value.principal.tenant_id) ? each.value.principal.tenant_id : local.combined_objects_azuread_service_principals[try(each.value.principal.lz_key, local.client_config.landingzone_key)][each.value.principal.key].tenant_id
}

output "kusto_database_principal_assignments" {
  value = module.kusto_database_principal_assignments
}
