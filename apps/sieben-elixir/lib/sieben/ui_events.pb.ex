defmodule Vaelix.Ui.WindowInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :width, 2, type: :int32
  field :height, 3, type: :int32
  field :is_fullscreen, 4, type: :bool, json_name: "isFullscreen"
  field :is_maximized, 5, type: :bool, json_name: "isMaximized"
  field :title, 6, type: :string
  field :screen_x, 7, type: :int32, json_name: "screenX"
  field :screen_y, 8, type: :int32, json_name: "screenY"
  field :opacity, 9, type: :double
  field :always_on_top, 10, type: :bool, json_name: "alwaysOnTop"
end

defmodule Vaelix.Ui.TabStateInfo do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :title, 2, type: :string
  field :url, 3, type: :string
  field :is_active, 4, type: :bool, json_name: "isActive"
  field :is_loading, 5, type: :bool, json_name: "isLoading"
  field :is_pinned, 6, type: :bool, json_name: "isPinned"
  field :favicon, 7, type: :bytes
  field :unread_count, 8, type: :int32, json_name: "unreadCount"
  field :status, 9, type: :string
end

defmodule Vaelix.Ui.WindowResizeEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :new_width, 2, type: :int32, json_name: "newWidth"
  field :new_height, 3, type: :int32, json_name: "newHeight"
  field :old_width, 4, type: :int32, json_name: "oldWidth"
  field :old_height, 5, type: :int32, json_name: "oldHeight"
  field :timestamp, 6, type: :int64
end

defmodule Vaelix.Ui.WindowMoveEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :new_x, 2, type: :int32, json_name: "newX"
  field :new_y, 3, type: :int32, json_name: "newY"
  field :old_x, 4, type: :int32, json_name: "oldX"
  field :old_y, 5, type: :int32, json_name: "oldY"
  field :timestamp, 6, type: :int64
end

defmodule Vaelix.Ui.KeyboardEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :key_code, 3, type: :string, json_name: "keyCode"
  field :key_name, 4, type: :string, json_name: "keyName"
  field :is_pressed, 5, type: :bool, json_name: "isPressed"
  field :is_ctrl, 6, type: :bool, json_name: "isCtrl"
  field :is_alt, 7, type: :bool, json_name: "isAlt"
  field :is_shift, 8, type: :bool, json_name: "isShift"
  field :is_meta, 9, type: :bool, json_name: "isMeta"
  field :repeat_count, 10, type: :int32, json_name: "repeatCount"
end

defmodule Vaelix.Ui.MouseEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :x, 3, type: :double
  field :y, 4, type: :double
  field :button, 5, type: :string
  field :is_pressed, 6, type: :bool, json_name: "isPressed"
  field :click_count, 7, type: :int32, json_name: "clickCount"
  field :wheel_delta, 8, type: :int32, json_name: "wheelDelta"
end

defmodule Vaelix.Ui.NavigationRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :url, 3, type: :string
  field :new_tab, 4, type: :bool, json_name: "newTab"
  field :background_tab, 5, type: :bool, json_name: "backgroundTab"
  field :force_reload, 6, type: :bool, json_name: "forceReload"
end

defmodule Vaelix.Ui.TabOperationRequest.ParametersEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Ui.TabOperationRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :operation, 3, type: :string

  field :parameters, 4,
    repeated: true,
    type: Vaelix.Ui.TabOperationRequest.ParametersEntry,
    map: true
end

defmodule Vaelix.Ui.WindowOperationRequest.ParametersEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Ui.WindowOperationRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :operation, 2, type: :string

  field :parameters, 3,
    repeated: true,
    type: Vaelix.Ui.WindowOperationRequest.ParametersEntry,
    map: true
end

defmodule Vaelix.Ui.ThemeChangeEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :theme_name, 4, type: :string, json_name: "themeName"
  field :variant, 5, type: :string
  field :animation_enabled, 6, type: :bool, json_name: "animationEnabled"
  field :animation_speed, 7, type: :double, json_name: "animationSpeed"
end

defmodule Vaelix.Ui.FocusChangeEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :old_tab_id, 2, type: :int32, json_name: "oldTabId"
  field :new_tab_id, 3, type: :int32, json_name: "newTabId"
  field :window_focus, 4, type: :bool, json_name: "windowFocus"
end

defmodule Vaelix.Ui.UIStateUpdate.UiStateEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Vaelix.Ui.UIStateUpdate do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tabs, 2, repeated: true, type: Vaelix.Ui.TabStateInfo
  field :window_info, 3, type: Vaelix.Ui.WindowInfo, json_name: "windowInfo"
  field :status_message, 4, type: :string, json_name: "statusMessage"
  field :loading_indicator, 5, type: :bool, json_name: "loadingIndicator"
  field :progress_indicator, 6, type: :double, json_name: "progressIndicator"

  field :ui_state, 7,
    repeated: true,
    type: Vaelix.Ui.UIStateUpdate.UiStateEntry,
    json_name: "uiState",
    map: true
end

defmodule Vaelix.Ui.ShortcutEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :shortcut, 1, type: :string
  field :window_id, 2, type: :int32, json_name: "windowId"
  field :consume, 3, type: :bool
end

defmodule Vaelix.Ui.PermissionRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :tab_id, 2, type: :int32, json_name: "tabId"
  field :permission_type, 3, type: :string, json_name: "permissionType"
  field :origin, 4, type: :string
  field :details, 5, type: :string
end

defmodule Vaelix.Ui.FileDownloadEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :tab_id, 1, type: :int32, json_name: "tabId"
  field :url, 2, type: :string
  field :filename, 3, type: :string
  field :content_length, 4, type: :int64, json_name: "contentLength"
  field :content_type, 5, type: :string, json_name: "contentType"
  field :is_auto_download, 6, type: :bool, json_name: "isAutoDownload"
end

defmodule Vaelix.Ui.WindowEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  oneof :event, 0

  field :resize, 1, type: Vaelix.Ui.WindowResizeEvent, oneof: 0
  field :move, 2, type: Vaelix.Ui.WindowMoveEvent, oneof: 0
  field :focus_change, 3, type: Vaelix.Ui.FocusChangeEvent, json_name: "focusChange", oneof: 0
  field :theme_change, 4, type: Vaelix.Ui.ThemeChangeEvent, json_name: "themeChange", oneof: 0
  field :window_error, 5, type: :string, json_name: "windowError", oneof: 0
  field :window_id, 6, type: :int32, json_name: "windowId"
  field :timestamp, 7, type: :int64
end

defmodule Vaelix.Ui.TabEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  oneof :event, 0

  field :navigation, 1, type: Vaelix.Ui.NavigationRequest, oneof: 0
  field :operation, 2, type: Vaelix.Ui.TabOperationRequest, oneof: 0
  field :download, 3, type: Vaelix.Ui.FileDownloadEvent, oneof: 0
  field :tab_error, 4, type: :string, json_name: "tabError", oneof: 0
  field :tab_id, 5, type: :int32, json_name: "tabId"
  field :window_id, 6, type: :int32, json_name: "windowId"
  field :timestamp, 7, type: :int64
end

defmodule Vaelix.Ui.InputEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  oneof :event, 0

  field :keyboard, 1, type: Vaelix.Ui.KeyboardEvent, oneof: 0
  field :mouse, 2, type: Vaelix.Ui.MouseEvent, oneof: 0
  field :shortcut, 3, type: Vaelix.Ui.ShortcutEvent, oneof: 0
  field :window_id, 4, type: :int32, json_name: "windowId"
  field :timestamp, 5, type: :int64
end

defmodule Vaelix.Ui.UIStateQuery do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :fields, 2, repeated: true, type: :string
end

defmodule Vaelix.Ui.WindowInfoRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
end

defmodule Vaelix.Ui.TabStatesRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :window_id, 1, type: :int32, json_name: "windowId"
  field :include_inactive, 2, type: :bool, json_name: "includeInactive"
end
