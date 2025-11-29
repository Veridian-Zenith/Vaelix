defmodule Vaelix.Control.TabInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :url, 2, type: :string
  field :title, 3, type: :string
  field :is_loading, 4, type: :bool, json_name: "isLoading"
  field :can_go_back, 5, type: :bool, json_name: "canGoBack"
  field :can_go_forward, 6, type: :bool, json_name: "canGoForward"
  field :favicon_data, 7, type: :bytes, json_name: "faviconData"
  field :content_type, 8, type: :string, json_name: "contentType"
end

defmodule Vaelix.Control.StartTabRequest.HeadersEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Control.StartTabRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :url, 1, type: :string
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :headers, 3, repeated: true, type: Vaelix.Control.StartTabRequest.HeadersEntry, map: true
  field :private_mode, 4, type: :bool, json_name: "privateMode"
  field :user_agent, 5, type: :string, json_name: "userAgent"
end

defmodule Vaelix.Control.StartTabResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :initial_favicon, 3, type: :bytes, json_name: "initialFavicon"
end

defmodule Vaelix.Control.StopTabRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :force_close, 2, type: :bool, json_name: "forceClose"
end

defmodule Vaelix.Control.StopTabResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Control.NavigateRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :url, 2, type: :string
  field :force_reload, 3, type: :bool, json_name: "forceReload"
end

defmodule Vaelix.Control.NavigateResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :redirected_url, 3, type: :string, json_name: "redirectedUrl"
end

defmodule Vaelix.Control.GetTabInfoRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
end

defmodule Vaelix.Control.GetTabInfoResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_info, 1, type: Vaelix.Control.TabInfo, json_name: "tabInfo"
  field :success, 2, type: :bool
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Vaelix.Control.TabClosedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :close_reason, 2, type: :int32, json_name: "closeReason"
end

defmodule Vaelix.Control.TabUpdatedEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :tab_info, 2, type: Vaelix.Control.TabInfo, json_name: "tabInfo"
  field :update_type, 3, type: :string, json_name: "updateType"
end

defmodule Vaelix.Control.BrowserShutdownRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :force_kill, 1, type: :bool, json_name: "forceKill"
  field :reason, 2, type: :string
end

defmodule Vaelix.Control.BrowserShutdownResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :success, 1, type: :bool
  field :remaining_tabs, 2, repeated: true, type: :int32, json_name: "remainingTabs"
  field :shutdown_delay_ms, 3, type: :int32, json_name: "shutdownDelayMs"
end

defmodule Vaelix.Control.BrowserMetrics do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :active_tabs, 1, type: :int32, json_name: "activeTabs"
  field :memory_usage_mb, 2, type: :int64, json_name: "memoryUsageMb"
  field :cpu_usage_percent, 3, type: :double, json_name: "cpuUsagePercent"
  field :network_bytes_received, 4, type: :int64, json_name: "networkBytesReceived"
  field :network_bytes_sent, 5, type: :int64, json_name: "networkBytesSent"
  field :render_time_ms, 6, type: :double, json_name: "renderTimeMs"
end

defmodule Vaelix.Control.GetBrowserMetricsRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :include_detailed_stats, 1, type: :bool, json_name: "includeDetailedStats"
end

defmodule Vaelix.Control.GetBrowserMetricsResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :metrics, 1, type: Vaelix.Control.BrowserMetrics
  field :success, 2, type: :bool
  field :timestamp, 3, type: :string
end

defmodule Vaelix.Control.TabEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  oneof :event, 0

  field :closed, 1, type: Vaelix.Control.TabClosedEvent, oneof: 0
  field :updated, 2, type: Vaelix.Control.TabUpdatedEvent, oneof: 0
  field :browser_event, 3, type: :string, json_name: "browserEvent", oneof: 0
  field :error_event, 4, type: :string, json_name: "errorEvent", oneof: 0
  field :performance_metric, 5, type: :double, json_name: "performanceMetric", oneof: 0
end
