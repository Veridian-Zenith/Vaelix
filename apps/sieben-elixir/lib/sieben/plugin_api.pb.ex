defmodule Vaelix.Plugin.PluginInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :name, 2, type: :string
  field :version, 3, type: :string
  field :description, 4, type: :string
  field :author, 5, type: :string
  field :permissions, 6, repeated: true, type: :string
  field :dependencies, 7, repeated: true, type: :string
  field :is_enabled, 8, type: :bool, json_name: "isEnabled"
  field :is_loaded, 9, type: :bool, json_name: "isLoaded"
  field :cpu_usage, 10, type: :double, json_name: "cpuUsage"
  field :memory_usage, 11, type: :int64, json_name: "memoryUsage"
end

defmodule Vaelix.Plugin.PluginLoadRequest.ConfigEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.PluginLoadRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_path, 1, type: :string, json_name: "pluginPath"
  field :plugin_id, 2, type: :string, json_name: "pluginId"
  field :enable_immediately, 3, type: :bool, json_name: "enableImmediately"
  field :config, 4, repeated: true, type: Vaelix.Plugin.PluginLoadRequest.ConfigEntry, map: true
end

defmodule Vaelix.Plugin.PluginLoadResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :plugin_info, 3, type: Vaelix.Plugin.PluginInfo, json_name: "pluginInfo"
  field :warnings, 4, repeated: true, type: :string
end

defmodule Vaelix.Plugin.PluginUnloadRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :force_unload, 2, type: :bool, json_name: "forceUnload"
end

defmodule Vaelix.Plugin.PluginUnloadResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :cleanup_tasks, 3, repeated: true, type: :string, json_name: "cleanupTasks"
end

defmodule Vaelix.Plugin.PluginEvent.DataEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.PluginEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :event_type, 1, type: :string, json_name: "eventType"
  field :plugin_id, 2, type: :string, json_name: "pluginId"
  field :data, 3, repeated: true, type: Vaelix.Plugin.PluginEvent.DataEntry, map: true
  field :timestamp, 4, type: :int64
end

defmodule Vaelix.Plugin.PluginEventHook do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :event_type, 1, type: :string, json_name: "eventType"
  field :plugin_id, 2, type: :string, json_name: "pluginId"
  field :handler_name, 3, type: :string, json_name: "handlerName"
  field :is_active, 4, type: :bool, json_name: "isActive"
end

defmodule Vaelix.Plugin.RegisterEventHookRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :event_type, 2, type: :string, json_name: "eventType"
  field :handler_name, 3, type: :string, json_name: "handlerName"
end

defmodule Vaelix.Plugin.RegisterEventHookResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :hook_id, 3, type: :string, json_name: "hookId"
end

defmodule Vaelix.Plugin.UnregisterEventHookRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :event_type, 2, type: :string, json_name: "eventType"
  field :hook_id, 3, type: :string, json_name: "hookId"
end

defmodule Vaelix.Plugin.UnregisterEventHookResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.ThemeInfo.PropertiesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.ThemeInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :theme_id, 1, type: :string, json_name: "themeId"
  field :name, 2, type: :string
  field :author, 3, type: :string
  field :version, 4, type: :string
  field :description, 5, type: :string
  field :variants, 6, repeated: true, type: :string
  field :preview_image, 7, type: :bytes, json_name: "previewImage"
  field :properties, 8, repeated: true, type: Vaelix.Plugin.ThemeInfo.PropertiesEntry, map: true
end

defmodule Vaelix.Plugin.ApplyThemeRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :theme_id, 1, type: :string, json_name: "themeId"
  field :variant, 2, type: :string
  field :restart_required, 3, type: :bool, json_name: "restartRequired"
end

defmodule Vaelix.Plugin.ApplyThemeResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :affected_components, 3, repeated: true, type: :string, json_name: "affectedComponents"
end

defmodule Vaelix.Plugin.GetThemesRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :include_preview_images, 4, type: :bool, json_name: "includePreviewImages"
  field :category, 5, type: :string
end

defmodule Vaelix.Plugin.GetThemesResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :themes, 1, repeated: true, type: Vaelix.Plugin.ThemeInfo
  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.PluginConfigUpdate.ConfigEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.PluginConfigUpdate do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :config, 2, repeated: true, type: Vaelix.Plugin.PluginConfigUpdate.ConfigEntry, map: true
  field :updated_by, 3, type: :string, json_name: "updatedBy"
  field :timestamp, 4, type: :int64
end

defmodule Vaelix.Plugin.GetPluginConfigRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :config_keys, 2, repeated: true, type: :string, json_name: "configKeys"
end

defmodule Vaelix.Plugin.GetPluginConfigResponse.ConfigEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.GetPluginConfigResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :config, 1,
    repeated: true,
    type: Vaelix.Plugin.GetPluginConfigResponse.ConfigEntry,
    map: true

  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.SetPluginConfigRequest.ConfigEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.SetPluginConfigRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"

  field :config, 2,
    repeated: true,
    type: Vaelix.Plugin.SetPluginConfigRequest.ConfigEntry,
    map: true

  field :validate, 3, type: :bool
end

defmodule Vaelix.Plugin.SetPluginConfigResponse.ValidatedConfigEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.SetPluginConfigResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"

  field :validated_config, 3,
    repeated: true,
    type: Vaelix.Plugin.SetPluginConfigResponse.ValidatedConfigEntry,
    json_name: "validatedConfig",
    map: true
end

defmodule Vaelix.Plugin.NetworkRequest.HeadersEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.NetworkRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId"
  field :url, 2, type: :string
  field :method, 3, type: :string
  field :headers, 4, repeated: true, type: Vaelix.Plugin.NetworkRequest.HeadersEntry, map: true
  field :body, 5, type: :bytes
  field :allow_redirects, 6, type: :bool, json_name: "allowRedirects"
  field :timeout_ms, 7, type: :int32, json_name: "timeoutMs"
end

defmodule Vaelix.Plugin.NetworkResponse.HeadersEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.NetworkResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId"
  field :status_code, 2, type: :int32, json_name: "statusCode"
  field :headers, 3, repeated: true, type: Vaelix.Plugin.NetworkResponse.HeadersEntry, map: true
  field :body, 4, type: :bytes
  field :response_time_ms, 5, type: :int64, json_name: "responseTimeMs"
  field :success, 6, type: :bool
  field :error_message, 7, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.MakeNetworkRequestRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :request, 2, type: Vaelix.Plugin.NetworkRequest
end

defmodule Vaelix.Plugin.MakeNetworkRequestResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :request_id, 1, type: :string, json_name: "requestId"
  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.WidgetCreateRequest.PropertiesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.WidgetCreateRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :widget_type, 2, type: :string, json_name: "widgetType"
  field :widget_id, 3, type: :string, json_name: "widgetId"
  field :window_id, 4, type: :int32, json_name: "windowId"
  field :tab_id, 5, type: :int32, json_name: "tabId"

  field :properties, 6,
    repeated: true,
    type: Vaelix.Plugin.WidgetCreateRequest.PropertiesEntry,
    map: true
end

defmodule Vaelix.Plugin.WidgetCreateResponse.WidgetDataEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.WidgetCreateResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :widget_id, 7, type: :string, json_name: "widgetId"
  field :success, 8, type: :bool
  field :error_message, 9, type: :string, json_name: "errorMessage"

  field :widget_data, 10,
    repeated: true,
    type: Vaelix.Plugin.WidgetCreateResponse.WidgetDataEntry,
    json_name: "widgetData",
    map: true
end

defmodule Vaelix.Plugin.WidgetModifyRequest.PropertiesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.WidgetModifyRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugin_id, 1, type: :string, json_name: "pluginId"
  field :widget_id, 2, type: :string, json_name: "widgetId"

  field :properties, 3,
    repeated: true,
    type: Vaelix.Plugin.WidgetModifyRequest.PropertiesEntry,
    map: true

  field :partial_update, 4, type: :bool, json_name: "partialUpdate"
end

defmodule Vaelix.Plugin.WidgetModifyResponse.UpdatedPropertiesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Plugin.WidgetModifyResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"

  field :updated_properties, 3,
    repeated: true,
    type: Vaelix.Plugin.WidgetModifyResponse.UpdatedPropertiesEntry,
    json_name: "updatedProperties",
    map: true
end

defmodule Vaelix.Plugin.PluginListRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :include_disabled, 1, type: :bool, json_name: "includeDisabled"
  field :filter_type, 2, type: :string, json_name: "filterType"
end

defmodule Vaelix.Plugin.PluginListResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :plugins, 1, repeated: true, type: Vaelix.Plugin.PluginInfo
  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.PluginEventHooksResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :hooks, 1, repeated: true, type: Vaelix.Plugin.PluginEventHook
  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Plugin.InstallThemeRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :theme_path, 1, type: :string, json_name: "themePath"
  field :theme_id, 2, type: :string, json_name: "themeId"
  field :make_default, 3, type: :bool, json_name: "makeDefault"
end

defmodule Vaelix.Plugin.InstallThemeResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :theme_info, 3, type: Vaelix.Plugin.ThemeInfo, json_name: "themeInfo"
end
