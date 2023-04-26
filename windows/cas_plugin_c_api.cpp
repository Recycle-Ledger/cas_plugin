#include "include/cas_plugin/cas_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "cas_plugin.h"

void CasPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  cas_plugin::CasPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
