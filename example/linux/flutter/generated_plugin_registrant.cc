//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <cas_plugin/cas_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) cas_plugin_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "CasPlugin");
  cas_plugin_register_with_registrar(cas_plugin_registrar);
}
