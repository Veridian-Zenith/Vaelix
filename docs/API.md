# Vaelix Component API Reference

This document provides comprehensive API documentation for all Vaelix components and interfaces.

## Table of Contents

1. [API Overview](#api-overview)
2. [Elixir Core APIs](#elixir-core-apis)
3. [C++ Native APIs](#c-native-apis)
4. [Racket Plugin APIs](#racket-plugin-apis)
5. [EFL UI APIs](#efl-ui-apis)
6. [IPC Protocols](#ipc-protocols)
7. [Configuration APIs](#configuration-apis)
8. [Extension APIs](#extension-apis)

## API Overview

Vaelix provides multiple API layers for different use cases and access levels:

```
┌─────────────────────────────────────────────────────────┐
│                     High-Level APIs                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │    User     │  │    Plugin   │  │    Theme        │  │
│  │   Interface │  │   API       │  │   API           │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                  Component APIs                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │    Elixir   │  │   C++ Core  │  │   Racket Host   │  │
│  │    Core     │  │             │  │                 │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────┐
│                    Low-Level APIs                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │    gRPC     │  │  JSON-RPC   │  │    Direct       │  │
│  │   Protocol  │  │  Protocol   │  │   Functions     │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Elixir Core APIs

### Sieben.Application

Main application supervisor and entry point.

```elixir
defmodule Sieben.Application do
  @moduledoc """
  Vaelix main application supervisor.
  """

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Sieben.Registry},
      {DynamicSupervisor, name: Sieben.Tab.Supervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Sieben.Plugin.Supervisor, strategy: :one_for_one},
      Sieben.IPC.Router,
      Sieben.Permission.Manager,
      Sieben.Config.Manager,
      Sieben.Security.Monitor
    ]

    opts = [strategy: :one_for_one, name: Sieben.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Sieben.Tab.Manager

Tab lifecycle and management API.

```elixir
defmodule Sieben.Tab.Manager do
  @moduledoc """
  Manages browser tab creation, navigation, and destruction.
  """

  use GenServer

  # API Functions

  @spec create_tab(url :: String.t(), options :: keyword()) ::
          {:ok, tab_id()} | {:error, reason :: String.t()}
  def create_tab(url, options \\ []) do
    GenServer.call(__MODULE__, {:create_tab, url, options})
  end

  @spec navigate(tab_id(), url :: String.t(), options :: keyword()) ::
          :ok | {:error, reason :: String.t()}
  def navigate(tab_id, url, options \\ []) do
    GenServer.call(__MODULE__, {:navigate, tab_id, url, options})
  end

  @spec close_tab(tab_id()) :: :ok | {:error, reason :: String.t()}
  def close_tab(tab_id) do
    GenServer.call(__MODULE__, {:close_tab, tab_id})
  end

  @spec get_tab_info(tab_id()) :: {:ok, tab_info()} | {:error, reason :: String.t()}
  def get_tab_info(tab_id) do
    GenServer.call(__MODULE__, {:get_tab_info, tab_id})
  end

  @spec list_tabs() :: [tab_info()]
  def list_tabs do
    GenServer.call(__MODULE__, :list_tabs)
  end

  @spec set_active_tab(tab_id()) :: :ok | {:error, reason :: String.t()}
  def set_active_tab(tab_id) do
    GenServer.call(__MODULE__, {:set_active_tab, tab_id})
  end

  @spec get_active_tab() :: {:ok, tab_id()} | {:error, reason :: String.t()}
  def get_active_tab do
    GenServer.call(__MODULE__, :get_active_tab)
  end

  # Tab information structure
  @type tab_id :: String.t()
  @type tab_info :: %{
          id: tab_id(),
          url: String.t(),
          title: String.t(),
          status: :loading | :loaded | :error,
          created_at: non_neg_integer(),
          last_activity: non_neg_integer()
        }
end
```

### Sieben.IPC.Router

Inter-process communication routing and management.

```elixir
defmodule Sieben.IPC.Router do
  @moduledoc """
  Routes messages between components and enforces security policies.
  """

  use GenServer

  # API Functions

  @spec register_component(component_id :: atom(), component_module :: module()) ::
          :ok | {:error, reason :: String.t()}
  def register_component(component_id, component_module) do
    GenServer.call(__MODULE__, {:register_component, component_id, component_module})
  end

  @spec send_message(target :: atom(), message :: term()) ::
          :ok | {:error, reason :: String.t()}
  def send_message(target, message) do
    GenServer.call(__MODULE__, {:send_message, target, message})
  end

  @spec broadcast_message(source :: atom(), message :: term()) ::
          :ok
  def broadcast_message(source, message) do
    GenServer.cast(__MODULE__, {:broadcast_message, source, message})
  end

  @spec register_route(source :: atom(), target :: atom(), route_opts :: keyword()) ::
          :ok | {:error, reason :: String.t()}
  def register_route(source, target, route_opts \\ []) do
    GenServer.call(__MODULE__, {:register_route, source, target, route_opts})
  end

  @spec get_route_info(source :: atom(), target :: atom()) ::
          {:ok, route_info()} | {:error, reason :: String.t()}
  def get_route_info(source, target) do
    GenServer.call(__MODULE__, {:get_route_info, source, target})
  end
end
```

### Sieben.Permission.Manager

Permission management and enforcement.

```elixir
defmodule Sieben.Permission.Manager do
  @moduledoc """
  Manages permissions for plugins and components.
  """

  use GenServer

  # Permission types
  @permission_types ~w(
    network_access
    file_access
    ui_injection
    tab_control
    history_access
    cookie_access
    local_storage
    camera_access
    microphone_access
    notification_access
    clipboard_access
    system_info
  )a

  # API Functions

  @spec request_permission(
          requester_id :: term(),
          permission :: atom(),
          resource :: term() | nil
        ) ::
          {:ok, decision :: :granted | :denied | :pending} | {:error, reason :: String.t()}
  def request_permission(requester_id, permission, resource \\ nil) do
    GenServer.call(__MODULE__, {:request_permission, requester_id, permission, resource})
  end

  @spec check_permission(
          requester_id :: term(),
          permission :: atom(),
          resource :: term() | nil
        ) :: :ok | {:error, reason :: String.t()}
  def check_permission(requester_id, permission, resource \\ nil) do
    GenServer.call(__MODULE__, {:check_permission, requester_id, permission, resource})
  end

  @spec grant_permission(
          requester_id :: term(),
          permission :: atom(),
          resource :: term() | nil,
          duration :: timeout()
        ) :: :ok
  def grant_permission(requester_id, permission, resource \\ nil, duration \\ :infinity) do
    GenServer.call(__MODULE__, {:grant_permission, requester_id, permission, resource, duration})
  end

  @spec revoke_permission(
          requester_id :: term(),
          permission :: atom(),
          resource :: term() | nil
        ) :: :ok
  def revoke_permission(requester_id, permission, resource \\ nil) do
    GenServer.call(__MODULE__, {:revoke_permission, requester_id, permission, resource})
  end

  @spec list_permissions(requester_id :: term()) :: [permission_info()]
  def list_permissions(requester_id) do
    GenServer.call(__MODULE__, {:list_permissions, requester_id})
  end

  @spec set_permission_policy(
          permission :: atom(),
          policy :: :allow | :deny | :prompt
        ) :: :ok
  def set_permission_policy(permission, policy) do
    GenServer.call(__MODULE__, {:set_permission_policy, permission, policy})
  end

  @spec get_permission_policy(permission :: atom()) ::
          {:ok, policy :: :allow | :deny | :prompt}
  def get_permission_policy(permission) do
    GenServer.call(__MODULE__, {:get_permission_policy, permission})
  end
end
```

## C++ Native APIs

### BrowserManager Class

Main browser management interface.

```cpp
// apps/sieben-native/include/sieben/browser_manager.h
namespace sieben {

class BrowserManager {
 public:
  /**
   * Creates a new browser manager instance.
   */
  BrowserManager();

  /**
   * Destroys the browser manager and cleans up resources.
   */
  ~BrowserManager();

  /**
   * Creates a new browser window with the given URL.
   * @param url The URL to load in the new browser window
   * @param parent_window Optional parent window handle
   * @return Browser ID if successful, -1 if failed
   */
  int CreateBrowser(const std::string& url, void* parent_window = nullptr);

  /**
   * Closes a browser window.
   * @param browser_id ID of the browser to close
   * @return true if successful, false otherwise
   */
  bool CloseBrowser(int browser_id);

  /**
   * Navigates a browser to a new URL.
   * @param browser_id ID of the browser
   * @param url The URL to navigate to
   * @return true if successful, false otherwise
   */
  bool NavigateToURL(int browser_id, const std::string& url);

  /**
   * Gets browser information.
   * @param browser_id ID of the browser
   * @param info Browser information structure
   * @return true if successful, false otherwise
   */
  bool GetBrowserInfo(int browser_id, BrowserInfo& info);

  /**
   * Sets browser focus.
   * @param browser_id ID of the browser
   * @param focused true to focus, false to unfocus
   * @return true if successful, false otherwise
   */
  bool SetBrowserFocus(int browser_id, bool focused);

  /**
   * Resizes a browser window.
   * @param browser_id ID of the browser
   * @param width New width in pixels
   * @param height New height in pixels
   * @return true if successful, false otherwise
   */
  bool ResizeBrowser(int browser_id, int width, int height);

  /**
   * Gets the current URL of a browser.
   * @param browser_id ID of the browser
   * @return Current URL, empty string if error
   */
  std::string GetCurrentURL(int browser_id);

  /**
   * Gets the title of a browser.
   * @param browser_id ID of the browser
   * @return Browser title, empty string if error
   */
  std::string GetBrowserTitle(int browser_id);

  /**
   * Reloads the current page in a browser.
   * @param browser_id ID of the browser
   * @param ignore_cache true to ignore cache, false otherwise
   * @return true if successful, false otherwise
   */
  bool ReloadBrowser(int browser_id, bool ignore_cache = false);

  /**
   * Stops page loading in a browser.
   * @param browser_id ID of the browser
   * @return true if successful, false otherwise
   */
  bool StopLoading(int browser_id);

  /**
   * Execute JavaScript in a browser.
   * @param browser_id ID of the browser
   * @param javascript JavaScript code to execute
   * @param callback Optional callback for result
   * @return true if successful, false otherwise
   */
  bool ExecuteJavaScript(int browser_id,
                        const std::string& javascript,
                        JavaScriptCallback callback = nullptr);

  /**
   * Handles browser lifecycle events.
   */
  class BrowserDelegate {
   public:
    virtual void OnBrowserCreated(int browser_id, const std::string& url) = 0;
    virtual void OnBrowserClosed(int browser_id) = 0;
    virtual void OnNavigation(int browser_id, const std::string& url, bool success) = 0;
    virtual void OnTitleChanged(int browser_id, const std::string& title) = 0;
    virtual void OnLoadingStateChanged(int browser_id, bool is_loading) = 0;
    virtual void OnFrameReady(int browser_id, const FrameBuffer& frame) = 0;
    virtual void OnError(int browser_id, const std::string& error_message) = 0;
    virtual ~BrowserDelegate() = default;
  };

  void SetDelegate(BrowserDelegate* delegate) { delegate_ = delegate; }

 private:
  class Impl;
  std::unique_ptr<Impl> impl_;
  BrowserDelegate* delegate_;

  // Singleton pattern
  BrowserManager(const BrowserManager&) = delete;
  BrowserManager& operator=(const BrowserManager&) = delete;
};

/**
 * Browser information structure.
 */
struct BrowserInfo {
  int id;
  std::string url;
  std::string title;
  int width;
  int height;
  bool is_loading;
  bool has_focus;
  int64_t created_timestamp;
  int64_t last_activity;
};

} // namespace sieben
```

### IPC Bridge

Inter-process communication bridge between C++ and Elixir.

```cpp
// apps/sieben-native/include/sieben/ipc_bridge.h
namespace sieben {

class IPCBridge {
 public:
  /**
   * Creates an IPC bridge for communication with Elixir core.
   */
  IPCBridge();

  /**
   * Destroys the IPC bridge.
   */
  ~IPCBridge();

  /**
   * Starts the IPC bridge.
   * @param socket_path Path to Unix domain socket
   * @return true if successful, false otherwise
   */
  bool Start(const std::string& socket_path);

  /**
   * Stops the IPC bridge.
   */
  void Stop();

  /**
   * Sends a message to Elixir core.
   * @param message Protobuf message to send
   * @return true if successful, false otherwise
   */
  bool SendMessage(const google::protobuf::Message& message);

  /**
   * Receives a message from Elixir core.
   * @param message Protobuf message to receive into
   * @param timeout Timeout in milliseconds
   * @return true if successful, false otherwise
   */
  bool ReceiveMessage(google::protobuf::Message& message, int timeout = 1000);

  /**
   * Sets the message handler for received messages.
   */
  using MessageHandler = std::function<bool(const google::protobuf::Message&)>;
  void SetMessageHandler(MessageHandler handler) { message_handler_ = handler; }

 private:
  class Impl;
  std::unique_ptr<Impl> impl_;
  MessageHandler message_handler_;
};

} // namespace sieben
```

### RenderHandler

Handles off-screen rendering and frame delivery.

```cpp
// apps/sieben-native/include/sieben/render_handler.h
namespace sieben {

class RenderHandler : public CefRenderHandler {
 public:
  /**
   * Creates a new render handler.
   */
  RenderHandler();

  /**
   * Destroys the render handler.
   */
  ~RenderHandler() override;

  /**
   * Gets the view rectangle for the browser.
   */
  bool GetViewRect(CefRefPtr<CefBrowser> browser, CefRect& rect) override;

  /**
   * Called when the browser's device scale factor changes.
   */
  void OnDeviceScaleFactorChanged(CefRefPtr<CefBrowser> browser,
                                 float scale_factor) override;

  /**
   * Called when an element should be painted.
   */
  void OnPaint(CefRefPtr<CefBrowser> browser,
               PaintElementType type,
               const RectList& dirty_rects,
               const void* buffer,
               int width,
               int height) override;

  /**
   * Called when the scroll position changes.
   */
  void OnScrollOffsetChanged(CefRefPtr<CefBrowser> browser) override;

  /**
   * Called when text selection changes.
   */
  void OnTextSelectionChanged(CefRefPtr<CefBrowser> browser,
                             const CefString& selected_text,
                             const CefRange& selected_range) override;

  /**
   * Called when the cursor for a visual element changes.
   */
  bool OnCursorChange(CefRefPtr<CefBrowser> browser,
                     CefCursorHandle cursor,
                     CursorType type,
                     const CefCursorInfo& custom_cursor_info) override;

  /**
   * Sets the frame callback for frame ready events.
   */
  using FrameCallback = std::function<void(int browser_id, const FrameBuffer&)>;
  void SetFrameCallback(FrameCallback callback) { frame_callback_ = callback; }

 private:
  FrameCallback frame_callback_;
  IMPLEMENT_REFCOUNTING(RenderHandler);
};

} // namespace sieben
```

## Racket Plugin APIs

### Plugin API

Main plugin interface and lifecycle management.

```racket
# apps/sieben-racket/src/plugin-api.rkt
#lang racket

(require json)

;; Plugin lifecycle functions
(provide plugin-start
         plugin-stop
         plugin-unload
         plugin-id
         plugin-version)

;; Event system
(provide register-event-hook!
         unregister-event-hook!
         emit-event
         event-registered?)

;; Permission system
(provide request-permission
         check-permission
         revoke-permission
         permission-state)

;; UI integration
(provide create-widget
         modify-widget
         remove-widget
         widget-exists?
         register-action
         show-notification
         hide-notification)

;; Network access
(provide http-request
         websocket-connect
         websocket-send
         websocket-close
         download-file)

;; Configuration management
(provide get-config
         set-config!
         save-config
         load-config
         get-all-configs)

;; Utility functions
(provide log-debug
         log-info
         log-warning
         log-error
         spawn-thread
         sleep-thread
         string-contains?
         string-replace)

;; Plugin initialization
(define (plugin-start)
  "Initialize plugin and return status"
  (log-info "Plugin starting...")
  (initialize-resources!)
  (register-event-hooks!)
  "Plugin started successfully")

(define (plugin-stop)
  "Stop plugin and clean up resources"
  (log-info "Plugin stopping...")
  (cleanup-resources!)
  (unregister-event-hooks!)
  "Plugin stopped successfully")

(define (plugin-unload)
  "Unload plugin from memory"
  (log-info "Plugin unloading...")
  (final-cleanup!)
  "Plugin unloaded")

;; Event hook management
(define (register-event-hook! event-name callback)
  "Register a callback for an event"
  (when (not (procedure? callback))
    (raise-argument-error 'register-event-hook! "procedure?" callback))
  (hash-update! event-hooks event-name
                (λ (callbacks) (cons callback callbacks))
                '()))

(define (unregister-event-hook! event-name callback)
  "Unregister a callback for an event"
  (when (hash-has-key? event-hooks event-name)
    (hash-set! event-hooks event-name
               (remove callback (hash-ref event-hooks event-name)))))

(define (emit-event event-name . args)
  "Emit an event to registered callbacks"
  (when (hash-has-key? event-hooks event-name)
    (for ([callback (hash-ref event-hooks event-name)])
      (with-handlers ([exn? (λ (e) (log-error "Event callback error: ~a" (exn-message e)))])
        (apply callback args)))))

;; Permission management
(define (request-permission permission)
  "Request a permission from the user"
  (match (send-ipc-message 'request-permission `((permission . ,permission)))
    [(hash-table ('decision . decision))] (string->symbol decision)
    [_ 'denied]))

(define (check-permission permission)
  "Check if a permission is granted"
  (match (send-ipc-message 'check-permission `((permission . ,permission)))
    [(hash-table ('granted . #t))] #t
    [_ #f]))

;; UI integration
(define (create-widget widget-type . kwargs)
  "Create a UI widget"
  (match (send-ipc-message 'create-widget
                           `(,@(list 'widget-type widget-type) ,@kwargs))
    [(hash-table ('widget-id . id))] id
    [_ #f]))

(define (modify-widget widget-id . updates)
  "Modify an existing widget"
  (send-ipc-message 'modify-widget
                   `(,@(list 'widget-id widget-id) ,@updates)))

(define (register-action action-name callback)
  "Register an action callback"
  (when (not (procedure? callback))
    (raise-argument-error 'register-action "procedure?" callback))
  (hash-set! action-registry action-name callback))

;; Network access
(define (http-request url . options)
  "Make an HTTP request"
  (define request-data `(,@(list 'url url) ,@options))
  (send-ipc-message 'http-request request-data))

(define (download-file url file-path progress-callback)
  "Download a file with progress callback"
  (send-ipc-message 'download-file
                   `(,@(list 'url url 'file-path file-path 'progress-callback progress-callback)))

;; Configuration management
(define (get-config key default-value)
  "Get a configuration value"
  (match (send-ipc-message 'get-config `((key . ,key)))
    [(hash-table ('value . value))] value
    [_ default-value]))

(define (set-config! key value)
  "Set a configuration value"
  (send-ipc-message 'set-config! `((key . ,key) (value . ,value))))

;; Utility functions
(define (log-info message)
  "Log an info message"
  (send-ipc-message 'log-info `((message . ,message))))

(define (spawn-thread thunk)
  "Spawn a new thread"
  (thread thunk))

(define (string-contains? haystack needle)
  "Check if haystack contains needle"
  (not (false? (string-contains haystack needle))))

;; Internal data structures
(define event-hooks (make-hash))
(define action-registry (make-hash))

;; IPC message sending
(define (send-ipc-message method params)
  "Send an IPC message and return the response"
  ;; Implementation would connect to Elixir IPC router
  (hash-table))
```

### Theme Engine

Theme compilation and application interface.

```racket
# apps/sieben-racket/src/theme-engine.rkt
#lang racket

(require racket/file
         racket/string
         json)

(provide compile-theme
         load-theme
         apply-theme
         validate-theme
         theme-variables
         set-theme-variable!)

(define (compile-theme theme-path output-path)
  "Compile a theme from EDC source to EDJ"
  (define edc-content (file->string theme-path))
  (define output-file (build-path output-path (path-replace-suffix
                                              (file-name-from-path theme-path)
                                              ".edj")))

  ;; Call edje_cc compiler
  (define process (subprocess #f #f #f
                              "edje_cc"
                              "-id" (directory-part theme-path)
                              "-fd" (directory-part theme-path)
                              "-o" output-file
                              theme-path))

  (subprocess-wait process)
  (if (eq? (subprocess-status process) 0)
      output-file
      (error 'compile-theme "Failed to compile theme: ~a" theme-path)))

(define (load-theme theme-path)
  "Load a theme from an EDJ file"
  ;; Validate theme structure
  (validate-theme theme-path)

  ;; Load theme metadata
  (define theme-metadata (load-theme-metadata theme-path))

  ;; Parse theme variables and settings
  (define theme-vars (parse-theme-variables theme-metadata))

  (hash-set! loaded-themes (theme-metadata 'name)
            (hash 'path theme-path
                  'metadata theme-metadata
                  'variables theme-vars)))

(define (apply-theme theme-name)
  "Apply a loaded theme to the UI"
  (when (hash-has-key? loaded-themes theme-name)
    (define theme (hash-ref loaded-themes theme-name))
    (send-ipc-message 'apply-theme theme)))

(define (validate-theme theme-path)
  "Validate theme structure and content"
  (define edc-content (file->string theme-path))

  ;; Check for required groups
  (define required-groups '("sieben/main_window"
                           "sieben/address_bar"
                           "sieben/tab_container"))
  (for ([group required-groups])
    (when (not (regexp-match (format #rx"group.*name.*~a" (regexp-quote group)) edc-content))
      (error 'validate-theme "Missing required group: ~a" group)))

  ;; Check for required color classes
  (define required-colors '("base" "accent" "neon" "text"))
  (for ([color required-colors])
    (when (not (regexp-match (format #rx"color_class.*~a" (regexp-quote color)) edc-content))
      (error 'validate-theme "Missing required color class: ~a" color)))

(define (theme-variables theme-name)
  "Get theme variables"
  (when (hash-has-key? loaded-themes theme-name)
    (hash-ref (hash-ref loaded-themes theme-name) 'variables)))

(define (set-theme-variable! theme-name var-name var-value)
  "Set a theme variable"
  (when (hash-has-key? loaded-themes theme-name)
    (define theme (hash-ref loaded-themes theme-name))
    (hash-set! (hash-ref theme 'variables) var-name var-value)
    (send-ipc-message 'update-theme-variables
                     `(,@(list 'theme-name theme-name 'variables (hash-ref theme 'variables))))))

;; Internal functions
(define loaded-themes (make-hash))

(define (load-theme-metadata theme-path)
  "Load theme metadata from EDJ file"
  ;; This would parse the EDJ file to extract metadata
  (hash 'name (path->string (file-name-from-path theme-path))
        'version "1.0.0"
        'author "Unknown"
        'description "A Vaelix theme"))

(define (parse-theme-variables metadata)
  "Parse theme variables from metadata"
  ;; This would extract variables from theme metadata
  (hash))
```

## EFL UI APIs

### Window Manager

Main window and UI container management.

```cpp
// apps/sieben-ui/include/window_manager.h
namespace sieben {
namespace ui {

class WindowManager {
 public:
  WindowManager();
  ~WindowManager();

  /**
   * Creates the main application window.
   */
  bool CreateMainWindow(const std::string& title, int width, int height);

  /**
   * Shows the main window.
   */
  void ShowWindow();

  /**
   * Hides the main window.
   */
  void HideWindow();

  /**
   * Closes the main window.
   */
  void CloseWindow();

  /**
   * Sets the window title.
   */
  void SetTitle(const std::string& title);

  /**
   * Resizes the window.
   */
  void Resize(int width, int height);

  /**
   * Gets the window size.
   */
  std::pair<int, int> GetSize() const;

  /**
   * Gets the window position.
   */
  std::pair<int, int> GetPosition() const;

  /**
   * Sets the window icon.
   */
  void SetIcon(const std::string& icon_path);

  /**
   * Sets the window opacity (0.0 to 1.0).
   */
  void SetOpacity(double opacity);

  /**
   * Maximizes the window.
   */
  void Maximize();

  /**
   * Minimizes the window.
   */
  void Minimize();

  /**
   * Restores the window from maximized/minimized state.
   */
  void Restore();

  /**
   * Sets the window fullscreen state.
   */
  void SetFullscreen(bool fullscreen);

  /**
   * Gets whether the window is fullscreen.
   */
  bool IsFullscreen() const;

  /**
   * Toggles the window fullscreen state.
   */
  void ToggleFullscreen();

  /**
   * Sets the background color.
   */
  void SetBackgroundColor(int r, int g, int b, int a = 255);

  /**
   * Adds a child widget to the window.
   */
  void AddWidget(std::shared_ptr<Widget> widget);

  /**
   * Removes a child widget from the window.
   */
  void RemoveWidget(std::shared_ptr<Widget> widget);

  /**
   * Gets the main window's Evas object.
   */
  Evas_Object* GetEvasObject() const { return window_; }

 private:
  Evas_Object* window_;
  Ecore_Evas* ecore_evas_;
  std::vector<std::shared_ptr<Widget>> widgets_;

  bool CreateEcoreEvas();
  void SetupCallbacks();
  static void OnDelete(void* data, Evas_Object* obj, void* event_info);
  static void OnMove(void* data, Evas_Object* obj, void* event_info);
  static void OnResize(void* data, Evas_Object* obj, void* event_info);
};

} // namespace ui
} // namespace sieben
```

### Widget System

Base widget interface and widget management.

```cpp
// apps/sieben-ui/include/widget.h
namespace sieben {
namespace ui {

class Widget {
 public:
  enum class WidgetType {
    Button,
    Label,
    Entry,
    Image,
    Container,
    TabBar,
    AddressBar,
    Menu,
    Dialog
  };

  Widget(const std::string& name, WidgetType type);
  virtual ~Widget() = default;

  /**
   * Gets the widget name.
   */
  const std::string& GetName() const { return name_; }

  /**
   * Gets the widget type.
   */
  WidgetType GetType() const { return type_; }

  /**
   * Gets the Evas object.
   */
  Evas_Object* GetEvasObject() const { return evas_object_; }

  /**
   * Sets the widget position.
   */
  void SetPosition(int x, int y);

  /**
   * Gets the widget position.
   */
  std::pair<int, int> GetPosition() const;

  /**
   * Sets the widget size.
   */
  void SetSize(int width, int height);

  /**
   * Gets the widget size.
   */
  std::pair<int, int> GetSize() const;

  /**
   * Sets whether the widget is visible.
   */
  void SetVisible(bool visible);

  /**
   * Gets whether the widget is visible.
   */
  bool IsVisible() const;

  /**
   * Sets the widget alpha (0.0 to 1.0).
   */
  void SetAlpha(double alpha);

  /**
   * Sets the widget theme group.
   */
  void SetThemeGroup(const std::string& group);

  /**
   * Sets the widget minimum size.
   */
  void SetMinSize(int width, int height);

  /**
   * Sets the widget maximum size (-1 for unlimited).
   */
  void SetMaxSize(int width, int height);

  /**
   * Sets the widget size hints.
   */
  void SetSizeHints(int min_w, int min_h, int max_w, int max_h,
                   int weight_w, int weight_h, int align_x, int align_y);

  /**
   * Adds a callback for widget events.
   */
  void AddCallback(const std::string& event, std::function<void()> callback);

  /**
   * Removes a callback for widget events.
   */
  void RemoveCallback(const std::string& event);

  /**
   * Emits a widget event.
   */
  void EmitEvent(const std::string& event);

  /**
   * Shows the widget.
   */
  virtual void Show();

  /**
   * Hides the widget.
   */
  virtual void Hide();

  /**
   * Updates the widget.
   */
  virtual void Update();

 protected:
  std::string name_;
  WidgetType type_;
  Evas_Object* evas_object_;
  std::vector<std::shared_ptr<Widget>> children_;

 private:
  virtual void CreateEvasObject() = 0;
  void SetupBaseCallbacks();
  static void OnShow(void* data, Evas_Object* obj, void* event_info);
  static void OnHide(void* data, Evas_Object* obj, void* event_info);
  static void OnMove(void* data, Evas_Object* obj, void* event_info);
  static void OnResize(void* data, Evas_Object* obj, void* event_info);
};

} // namespace ui
} // namespace sieben
```

### Theme Manager

Theme loading and application system.

```cpp
// apps/sieben-ui/include/theme_manager.h
namespace sieben {
namespace ui {

class ThemeManager {
 public:
  ThemeManager();
  ~ThemeManager();

  /**
   * Loads a theme from an EDJ file.
   */
  bool LoadTheme(const std::string& theme_path);

  /**
   * Unloads the current theme.
   */
  void UnloadTheme();

  /**
   * Applies a loaded theme to widgets.
   */
  void ApplyTheme();

  /**
   * Gets the current theme information.
   */
  ThemeInfo GetCurrentTheme() const;

  /**
   * Sets a theme variable.
   */
  void SetThemeVariable(const std::string& name, const std::string& value);

  /**
   * Gets a theme variable.
   */
  std::string GetThemeVariable(const std::string& name) const;

  /**
   * Gets all theme variables.
   */
  std::map<std::string, std::string> GetAllThemeVariables() const;

  /**
   * Validates a theme file.
   */
  bool ValidateTheme(const std::string& theme_path);

  /**
   * Gets the list of available themes.
   */
  std::vector<ThemeInfo> GetAvailableThemes() const;

  /**
   * Sets the theme directory.
   */
  void SetThemeDirectory(const std::string& directory);

 private:
  std::string current_theme_;
  Edje_Group* current_group_;
  std::map<std::string, std::string> theme_variables_;
  std::string theme_directory_;

  bool InitializeEdje();
  void CleanupEdje();
  bool LoadThemeFile(const std::string& theme_path);
  bool ValidateThemeGroups();
};

struct ThemeInfo {
  std::string name;
  std::string path;
  std::string version;
  std::string author;
  std::string description;
  std::map<std::string, std::string> metadata;
};

} // namespace ui
} // namespace sieben
```

## IPC Protocols

### Control Protocol

Primary control protocol between Elixir and C++ components.

```protobuf
// libs/proto/control.proto
syntax = "proto3";

package sieben.control;

message TabId {
  string id = 1;
}

message BrowserInfo {
  TabId tab_id = 1;
  string url = 2;
  string title = 3;
  int32 width = 4;
  int32 height = 5;
  bool is_loading = 6;
  bool has_focus = 7;
  int64 created_timestamp = 8;
  int64 last_activity = 9;
}

message StartTabRequest {
  string url = 1;
  TabId tab_id = 2;
  repeated string headers = 3;
  map<string, string> options = 4;
}

message StartTabResponse {
  bool success = 1;
  string error = 2;
  int32 socket_fd = 3;
  BrowserInfo browser_info = 4;
}

message NavigateRequest {
  TabId tab_id = 1;
  string url = 2;
  repeated string headers = 3;
}

message NavigateResponse {
  bool success = 1;
  string error = 2;
}

message CloseTabRequest {
  TabId tab_id = 1;
}

message CloseTabResponse {
  bool success = 1;
  string error = 2;
}

message GetTabInfoRequest {
  TabId tab_id = 1;
}

message GetTabInfoResponse {
  bool success = 1;
  string error = 2;
  BrowserInfo browser_info = 3;
}

message FrameReady {
  TabId tab_id = 1;
  int32 width = 2;
  int32 height = 3;
  int32 buffer_fd = 4;
  string format = 5;
  int64 timestamp = 6;
}

message TabClosed {
  TabId tab_id = 1;
}

message PermissionRequest {
  string requester_id = 1;
  string permission = 2;
  string resource = 3;
}

message PermissionResponse {
  string requester_id = 1;
  string permission = 2;
  string decision = 3;  // "granted", "denied", "pending"
}
```

### UI Events Protocol

UI event protocol between Elixir and EFL components.

```json
{
  "jsonrpc": "2.0",
  "method": "ui_event",
  "params": {
    "event_type": "navigation_requested",
    "widget_id": "address_bar",
    "data": {
      "url": "https://example.com",
      "source": "user_input"
    },
    "timestamp": "2025-11-28T18:25:01.000Z"
  },
  "id": 123
}
```

**UI Event Types:**
- `navigation_requested`: User wants to navigate to a URL
- `tab_selected`: User selected a different tab
- `tab_closed`: User closed a tab
- `bookmark_clicked`: User clicked on a bookmark
- `menu_item_selected`: User selected a menu item
- `widget_focused`: Widget received focus
- `widget_blurred`: Widget lost focus
- `widget_resized`: Widget was resized
- `window_resized`: Main window was resized
- `window_focus_changed`: Window focus state changed

**UI Command Types:**
- `show_tab`: Display a tab's content
- `hide_tab`: Hide a tab
- `update_tab_title`: Update tab title
- `update_address_bar`: Update address bar content
- `show_notification`: Display a notification
- `animate_widget`: Animate a widget
- `update_theme`: Apply theme changes

## Configuration APIs

### System Configuration

Main system configuration interface.

```elixir
# apps/sieben-elixir/lib/sieben/config/manager.ex
defmodule Sieben.Config.Manager do
  @moduledoc """
  Manages system configuration and settings.
  """

  use GenServer

  # Configuration key types
  @config_types ~w(
    browser
    ui
    security
    performance
    network
    plugins
    themes
  )a

  # API Functions

  @spec get_config(key :: atom(), default :: term()) :: term()
  def get_config(key, default \\ nil) do
    GenServer.call(__MODULE__, {:get_config, key, default})
  end

  @spec set_config(key :: atom(), value :: term()) :: :ok
  def set_config(key, value) do
    GenServer.call(__MODULE__, {:set_config, key, value})
  end

  @spec get_section(section :: atom()) :: map()
  def get_section(section) do
    GenServer.call(__MODULE__, {:get_section, section})
  end

  @spec set_section(section :: atom(), config :: map()) :: :ok
  def set_section(section, config) do
    GenServer.call(__MODULE__, {:set_section, section, config})
  end

  @spec delete_config(key :: atom()) :: :ok
  def delete_config(key) do
    GenServer.call(__MODULE__, {:delete_config, key})
  end

  @spec get_all_config() :: map()
  def get_all_config do
    GenServer.call(__MODULE__, :get_all_config)
  end

  @spec save_config() :: :ok | {:error, reason :: String.t()}
  def save_config do
    GenServer.call(__MODULE__, :save_config)
  end

  @spec load_config() :: :ok | {:error, reason :: String.t()}
  def load_config do
    GenServer.call(__MODULE__, :load_config)
  end

  @spec reset_config(section :: atom() | :all) :: :ok
  def reset_config(section) do
    GenServer.call(__MODULE__, {:reset_config, section})
  end

  @spec export_config(format :: :json | :xml | :yaml) :: String.t()
  def export_config(format) do
    GenServer.call(__MODULE__, {:export_config, format})
  end

  @spec import_config(config_data :: String.t(), format :: :json | :xml | :yaml) ::
          :ok | {:error, reason :: String.t()}
  def import_config(config_data, format) do
    GenServer.call(__MODULE__, {:import_config, config_data, format})
  end

  @spec validate_config(config :: map(), schema :: map()) ::
          :ok | {:error, reason :: String.t()}
  def validate_config(config, schema) do
    GenServer.call(__MODULE__, {:validate_config, config, schema})
  end
end
```

### User Preferences

User preference management.

```elixir
# apps/sieben-elixir/lib/sieben/config/preferences.ex
defmodule Sieben.Config.Preferences do
  @moduledoc """
  Manages user preferences and personal settings.
  """

  # Preference categories
  @preference_categories ~w(
    general
    privacy
    appearance
    performance
    accessibility
    advanced
  )a

  # API Functions

  @spec get_preference(category :: atom(), key :: String.t(), default :: term()) ::
          term()
  def get_preference(category, key, default \\ nil) do
    GenServer.call(__MODULE__, {:get_preference, category, key, default})
  end

  @spec set_preference(category :: atom(), key :: String.t(), value :: term()) :: :ok
  def set_preference(category, key, value) do
    GenServer.call(__MODULE__, {:set_preference, category, key, value})
  end

  @spec get_category_preferences(category :: atom()) :: map()
  def get_category_preferences(category) do
    GenServer.call(__MODULE__, {:get_category_preferences, category})
  end

  @spec reset_preferences(category :: atom() | :all) :: :ok
  def reset_preferences(category) do
    GenServer.call(__MODULE__, {:reset_preferences, category})
  end

  @spec import_preferences(prefs :: map()) :: :ok
  def import_preferences(prefs) do
    GenServer.call(__MODULE__, {:import_preferences, prefs})
  end

  @spec export_preferences(category :: atom() | :all) :: map()
  def export_preferences(category) do
    GenServer.call(__MODULE__, {:export_preferences, category})
  end
end
```

## Extension APIs

### Plugin Manager API

Plugin lifecycle and management.

```elixir
# apps/sieben-elixir/lib/sieben/plugin/manager.ex
defmodule Sieben.Plugin.Manager do
  @moduledoc """
  Manages plugin lifecycle and coordination.
  """

  use GenServer

  # Plugin states
  @plugin_states ~w(loading loaded active stopping stopped error)a

  # API Functions

  @spec load_plugin(plugin_path :: String.t()) ::
          {:ok, plugin_id()} | {:error, reason :: String.t()}
  def load_plugin(plugin_path) do
    GenServer.call(__MODULE__, {:load_plugin, plugin_path})
  end

  @spec unload_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def unload_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:unload_plugin, plugin_id})
  end

  @spec reload_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def reload_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:reload_plugin, plugin_id})
  end

  @spec enable_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def enable_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:enable_plugin, plugin_id})
  end

  @spec disable_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def disable_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:disable_plugin, plugin_id})
  end

  @spec get_plugin_info(plugin_id()) ::
          {:ok, plugin_info()} | {:error, reason :: String.t()}
  def get_plugin_info(plugin_id) do
    GenServer.call(__MODULE__, {:get_plugin_info, plugin_id})
  end

  @spec list_plugins() :: [plugin_info()]
  def list_plugins do
    GenServer.call(__MODULE__, :list_plugins)
  end

  @spec get_plugin_status(plugin_id()) ::
          {:ok, state :: atom()} | {:error, reason :: String.t()}
  def get_plugin_status(plugin_id) do
    GenServer.call(__MODULE__, {:get_plugin_status, plugin_id})
  end

  @spec send_message_to_plugin(plugin_id(), message :: term()) ::
          :ok | {:error, reason :: String.t()}
  def send_message_to_plugin(plugin_id, message) do
    GenServer.call(__MODULE__, {:send_message, plugin_id, message})
  end

  @spec broadcast_message_to_plugins(message :: term()) :: :ok
  def broadcast_message_to_plugins(message) do
    GenServer.cast(__MODULE__, {:broadcast_message, message})
  end

  @spec install_plugin(plugin_url :: String.t()) ::
          {:ok, plugin_id()} | {:error, reason :: String.t()}
  def install_plugin(plugin_url) do
    GenServer.call(__MODULE__, {:install_plugin, plugin_url})
  end

  @spec uninstall_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def uninstall_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:uninstall_plugin, plugin_id})
  end

  @spec update_plugin(plugin_id()) :: :ok | {:error, reason :: String.t()}
  def update_plugin(plugin_id) do
    GenServer.call(__MODULE__, {:update_plugin, plugin_id})
  end

  @spec get_plugin_repository() :: {:ok, [plugin_info()]} | {:error, reason :: String.t()}
  def get_plugin_repository do
    GenServer.call(__MODULE__, :get_plugin_repository)
  end

  # Plugin information structure
  @type plugin_id :: String.t()
  @type plugin_info :: %{
          id: plugin_id(),
          name: String.t(),
          version: String.t(),
          author: String.t(),
          description: String.t(),
          path: String.t(),
          state: atom(),
          permissions: [String.t()],
          loaded_at: non_neg_integer(),
          last_activity: non_neg_integer(),
          error_message: String.t() | nil
        }
end
```

### Event System API

Event routing and management system.

```elixir
# apps/sieben-elixir/lib/sieben/event/router.ex
defmodule Sieben.Event.Router do
  @moduledoc """
  Routes events between components and plugins.
  """

  use GenServer

  # Event types
  @event_types ~w(
    navigation
    tab
    ui
    security
    network
    plugin
    system
    custom
  )a

  # API Functions

  @spec subscribe(event_type :: atom(), event_name :: String.t(), callback :: function()) ::
          :ok | {:error, reason :: String.t()}
  def subscribe(event_type, event_name, callback) do
    GenServer.call(__MODULE__, {:subscribe, event_type, event_name, callback})
  end

  @spec unsubscribe(event_type :: atom(), event_name :: String.t(), callback :: function()) ::
          :ok
  def unsubscribe(event_type, event_name, callback) do
    GenServer.call(__MODULE__, {:unsubscribe, event_type, event_name, callback})
  end

  @spec emit_event(event_type :: atom(), event_name :: String.t(), data :: term()) ::
          :ok
  def emit_event(event_type, event_name, data) do
    GenServer.cast(__MODULE__, {:emit_event, event_type, event_name, data})
  end

  @spec emit_event_async(event_type :: atom(), event_name :: String.t(), data :: term()) ::
          :ok
  def emit_event_async(event_type, event_name, data) do
    GenServer.cast(__MODULE__, {:emit_event_async, event_type, event_name, data})
  end

  @spec register_event(event_type :: atom(), event_name :: String.t(), schema :: map()) ::
          :ok | {:error, reason :: String.t()}
  def register_event(event_type, event_name, schema) do
    GenServer.call(__MODULE__, {:register_event, event_type, event_name, schema})
  end

  @spec validate_event(event_type :: atom(), event_name :: String.t(), data :: term()) ::
          :ok | {:error, reason :: String.t()}
  def validate_event(event_type, event_name, data) do
    GenServer.call(__MODULE__, {:validate_event, event_type, event_name, data})
  end

  @spec get_event_subscribers(event_type :: atom(), event_name :: String.t()) ::
          [subscriber_info()]
  def get_event_subscribers(event_type, event_name) do
    GenServer.call(__MODULE__, {:get_subscribers, event_type, event_name})
  end

  @spec get_event_history(event_type :: atom(), event_name :: String.t(), limit :: non_neg_integer()) ::
          [event_record()]
  def get_event_history(event_type, event_name, limit \\ 100) do
    GenServer.call(__MODULE__, {:get_history, event_type, event_name, limit})
  end

  @spec clear_event_history(event_type :: atom(), event_name :: String.t()) :: :ok
  def clear_event_history(event_type, event_name) do
    GenServer.call(__MODULE__, {:clear_history, event_type, event_name})
  end

  @type subscriber_info :: %{
          id: String.t(),
          callback: function(),
          subscribed_at: non_neg_integer()
        }

  @type event_record :: %{
          type: atom(),
          name: String.t(),
          data: term(),
          timestamp: non_neg_integer(),
          source: String.t()
        }
end
```

---

*This API reference document provides comprehensive documentation for all Vaelix components and interfaces. For more detailed examples and use cases, see the specific component documentation files.*
