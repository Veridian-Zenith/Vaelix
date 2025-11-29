# Vaelix Plugin API Documentation

This document provides comprehensive documentation for the Vaelix Plugin API, allowing developers to create extensions and enhancements for the browser.

## Table of Contents

1. [Plugin System Overview](#plugin-system-overview)
2. [Plugin Lifecycle](#plugin-lifecycle)
3. [Core API Reference](#core-api-reference)
4. [Event System](#event-system)
5. [Permission System](#permission-system)
6. [UI Integration](#ui-integration)
7. [Network Access](#network-access)
8. [Configuration Management](#configuration-management)
9. [Plugin Examples](#plugin-examples)
10. [Best Practices](#best-practices)

## Plugin System Overview

Vaelix plugins run in a sandboxed Racket environment, isolated from the core browser process for security and stability. The plugin system provides:

- **Secure Execution**: Sandboxed environment with resource limits
- **Event-Driven Architecture**: Plugins respond to browser events
- **Permission-Based Access**: Controlled access to browser features
- **Dynamic Loading**: Plugins can be loaded/unloaded at runtime
- **Theme Integration**: Plugins can modify the browser's appearance

### Plugin Architecture

```
┌─────────────────────────────────────────────────┐
│                  Plugin Manager                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │  Plugin     │  │ Permission  │  │ Event    │ │
│  │  Loader     │  │  Manager    │  │ Router   │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────┬───────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────┐
│               Racket Sandbox                    │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │   Plugin    │  │   Theme     │  │ Config   │ │
│  │   Runtime   │  │   Engine    │  │ Engine   │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
```

## Plugin Lifecycle

### Plugin States

```racket
(define plugin-states '(stopped loading active unloading error))
```

**Lifecycle Flow:**
1. **Loading**: Plugin is being loaded and initialized
2. **Active**: Plugin is running and processing events
3. **Stopping**: Plugin is being shut down
4. **Stopped**: Plugin is unloaded
5. **Error**: Plugin encountered an error

### Plugin Lifecycle Functions

```racket
#lang racket

(require sieben/plugin-api)

(define (plugin-start)
  "Called when the plugin is first loaded"
  (log-info "Plugin starting...")
  (initialize-resources!)
  (register-event-hooks!)
  "Plugin started successfully")

(define (plugin-stop)
  "Called when the plugin is being stopped"
  (log-info "Plugin stopping...")
  (cleanup-resources!)
  (unregister-event-hooks!)
  "Plugin stopped successfully")

(define (plugin-unload)
  "Called just before the plugin is unloaded"
  (log-info "Plugin unloading...")
  (final-cleanup!)
  "Plugin unloaded")
```

### Plugin Manifest

```racket
#lang racket

(define plugin-manifest
  '(#(name "My Awesome Plugin")
    #(version "1.0.0")
    #(description "An awesome Vaelix plugin")
    #(author "Your Name")
    #(license "MIT")
    #(dependencies ("json" "web-server"))
    #(permissions (network-access file-access))
    #(min-api-version "1.0.0")))
```

## Core API Reference

### Module Exports

Every plugin must export the following functions:

```racket
(provide plugin-start
         plugin-stop
         plugin-unload
         plugin-manifest)
```

### Sieben Plugin API

```racket
#lang racket

(require sieben/plugin-api)

;; Plugin initialization and lifecycle
(provide plugin-start plugin-stop plugin-unload)

;; Event system
(provide register-event-hook!
         unregister-event-hook!
         emit-event)

;; Permission system
(provide request-permission
         check-permission
         revoke-permission)

;; UI integration
(provide create-widget
         modify-widget
         register-action
         show-notification)

;; Network access
(provide http-request
         websocket-connect
         download-file)

;; Configuration
(provide get-config
         set-config!
         save-config
         load-config)
```

### Utility Functions

```racket
;; Logging
(log-debug "Debug message")
(log-info "Information message")
(log-warning "Warning message")
(log-error "Error message")

;; Threading
(spawn-thread (λ () (do-work)))
(sleep-thread 5)  ; Sleep for 5 seconds

;; String utilities
(string-contains? "hello world" "hello")
(string-replace "hello world" "world" "Vaelix")

;; File operations
(read-file "/path/to/file")
(write-file "/path/to/file" "content")
(list-directory "/path/to/directory")
```

## Event System

### Available Events

Browser events that plugins can hook into:

#### Navigation Events
- `on-navigate-before`: Before navigation occurs
- `on-navigate`: Navigation has started
- `on-navigate-complete`: Navigation completed
- `on-navigate-error`: Navigation failed
- `on-new-tab`: New tab created
- `on-close-tab`: Tab closed

#### User Interface Events
- `on-page-load`: Page content loaded
- `on-page-focus`: Page received focus
- `on-page-blur`: Page lost focus
- `on-text-selected`: Text was selected
- `on-context-menu`: Right-click context menu
- `on-scrolled`: Page was scrolled

#### Plugin System Events
- `on-plugin-loaded`: Another plugin loaded
- `on-plugin-unloaded`: Another plugin unloaded
- `on-permission-request`: Permission request received
- `on-config-changed`: Configuration was modified

### Event Hook Registration

```racket
#lang racket

(require sieben/plugin-api)

;; Register event hooks
(register-event-hook! 'on-navigate
  (λ (url tab-id timestamp)
    (log-info "Navigating to:" url)
    (when (string-contains? url "example.com")
      (log-warning "Navigating to potentially untrusted site"))))

(register-event-hook! 'on-page-load
  (λ (tab-id url title)
    (log-info "Page loaded:" title)
    (when (string-contains? title "error")
      (show-notification "Page contains error in title" "warning"))))

;; Multiple event hooks for same event
(register-event-hook! 'on-navigate
  (λ (url tab-id timestamp)
    (record-navigation url)))  ; Analytics plugin

(register-event-hook! 'on-navigate
  (λ (url tab-id timestamp)
    (update-bookmark-suggestions url)))  ; Bookmark plugin
```

### Event Emission

```racket
;; Emit custom events for other plugins
(emit-event 'my-custom-event
  '(#(data "some data")
    #(timestamp ,(current-seconds))))
```

### Event Filtering

```racket
;; Filter events based on conditions
(register-event-hook! 'on-navigate
  (λ (url tab-id timestamp)
    (when (permission-granted? 'track-navigation)
      (track-user-navigation url))))
```

## Permission System

### Permission Types

Plugins must request permissions before accessing certain features:

#### Core Permissions
- `network-access`: Make HTTP/HTTPS requests
- `file-access`: Read/write local files
- `ui-injection`: Modify UI elements
- `tab-control`: Create/close tabs
- `history-access`: Read browser history
- `cookie-access`: Access cookies
- `local-storage`: Use local storage

#### Extended Permissions
- `camera-access`: Access system camera
- `microphone-access`: Access microphone
- `notification-access`: Send notifications
- `clipboard-access`: Access clipboard
- `system-info`: Access system information

### Permission Management

```racket
#lang racket

(require sieben/plugin-api)

;; Request permissions at startup
(define (request-required-permissions)
  (request-permission 'network-access)
  (request-permission 'ui-injection)
  (request-permission 'local-storage))

;; Check if permission is granted
(define (check-permissions)
  (when (check-permission 'network-access)
    (log-info "Network access granted"))

  (when (check-permission 'ui-injection)
    (log-info "UI injection allowed")))

;; Handle permission requests
(register-event-hook! 'on-permission-request
  (λ (permission plugin-id reason)
    (log-info "Permission request:" permission "from" plugin-id)
    (cond
      [(eq? permission 'network-access) #t]  ; Always allow network
      [(eq? permission 'file-access) #f]    ; Never allow file access
      [else #f])))  ; Default deny

;; Request permission dynamically
(define (request-network-permission)
  (match (request-permission 'network-access)
    ['granted (log-info "Network access granted")]
    ['denied (log-warning "Network access denied")]
    ['pending (log-info "Network access pending user decision")]))
```

### Permission Examples

```racket
;; Safe plugin (minimal permissions)
(define safe-plugin
  (plugin
   #:name "safe-plugin"
   #:permissions '())  ; No permissions needed

;; Network plugin (requires network access)
(define network-plugin
  (plugin
   #:name "network-plugin"
   #:permissions '(network-access)))

;; UI plugin (requires UI modification)
(define ui-plugin
  (plugin
   #:name "ui-plugin"
   #:permissions '(ui-injection)))

;; Comprehensive plugin (many permissions)
(define comprehensive-plugin
  (plugin
   #:name "comprehensive-plugin"
   #:permissions '(network-access
                   ui-injection
                   tab-control
                   notification-access)))
```

## UI Integration

### Widget Creation

```racket
#lang racket

(require sieben/plugin-api)

;; Create basic UI elements
(define (create-ui-widgets)
  ;; Create a button
  (define button-id (create-widget 'button
                                  #:text "Click Me"
                                  #:position '(10 10)
                                  #:size '(100 30)
                                  #:on-click (λ () (on-button-click))))

  ;; Create a text input
  (define input-id (create-widget 'input
                                 #:placeholder "Enter URL"
                                 #:position '(10 50)
                                 #:size '(300 25)))

  ;; Create a status indicator
  (define status-id (create-widget 'status
                                  #:text "Ready"
                                  #:position '(10 90)))

  (values button-id input-id status-id))

;; Handle widget interactions
(define (on-button-click)
  (show-notification "Button clicked!" "info")
  (modify-widget 'status #:text "Processing..."))

;; Advanced widget creation
(define (create-advanced-ui)
  ;; Create a tab panel
  (define tab-panel (create-widget 'tab-panel
                                  #:tabs '(("Home" home-tab)
                                          ("Settings" settings-tab))
                                  #:position '(0 0)
                                  #:size '(800 600)))

  ;; Create a context menu
  (define context-menu (create-widget 'context-menu
                                     #:items '(("Copy" copy-action)
                                              ("Paste" paste-action))
                                     #:position '(100 100)))

  ;; Create a modal dialog
  (define modal (create-widget 'modal
                              #:title "Plugin Settings"
                              #:content settings-content
                              #:buttons '(("OK" ok-action)
                                         ("Cancel" cancel-action))))
```

### Widget Modification

```racket
;; Modify existing widgets
(modify-widget button-id
               #:text "Updated Text"
               #:enabled #f
               #:visible #t)

;; Animate widgets
(modify-widget button-id
               #:animation '(fade-in 0.5)
               #:position '(20 20))

;; Hide/show widgets
(modify-widget status-id #:visible #f)
(modify-widget button-id #:visible #t)

;; Update widget appearance
(modify-widget button-id
               #:style '(border-radius 5px)
               #:background-color "#4285f4"
               #:text-color "white")
```

### Action Registration

```racket
;; Register actions for widgets
(register-action 'copy-action
  (λ ()
    (clipboard-copy (get-selected-text))
    (show-notification "Copied to clipboard" "success")))

(register-action 'paste-action
  (λ ()
    (when (check-permission 'clipboard-access)
      (paste-from-clipboard))))

;; Keyboard shortcuts
(register-action 'ctrl-c
  (λ ()
    (copy-selection)))

(register-action 'f5
  (λ ()
    (refresh-current-page)))
```

### Notification System

```racket
;; Show various types of notifications
(show-notification "Welcome to Vaelix!" "info")
(show-notification "Download complete" "success")
(show-notification "Network connection lost" "warning")
(show-notification "Critical error occurred" "error")

;; Advanced notifications
(show-notification-with-actions
 "Update Available"
 "A new version is available"
 '((#(text "Update Now" action update-now-action)
    #(text "Later" action update-later-action))))

;; Progress notifications
(define progress-id (show-progress-notification "Loading..." 0))
(sleep 2)
(update-progress-notification progress-id 50)
(sleep 2)
(update-progress-notification progress-id 100)
(hide-notification progress-id)
```

## Network Access

### HTTP Requests

```racket
#lang racket

(require sieben/plugin-api)
(require net/http-client)
(require net/url)

;; Basic HTTP request
(define response (http-request "https://api.example.com/data"))
(when response
  (log-info "Response:" response))

;; HTTP request with headers
(define response2
  (http-request "https://api.example.com/data"
                #:headers '(("Content-Type" . "application/json")
                           ("Authorization" . "Bearer token123"))))

;; POST request with JSON data
(define post-response
  (http-request "https://api.example.com/submit"
                #:method 'POST
                #:headers '(("Content-Type" . "application/json"))
                #:body "{\"name\":\"Vaelix\",\"version\":\"1.0\"}"))

;; Form data submission
(define form-response
  (http-request "https://example.com/form"
                #:method 'POST
                #:headers '(("Content-Type" . "application/x-www-form-urlencoded"))
                #:body "field1=value1&field2=value2"))

;; Download file
(download-file "https://example.com/file.pdf"
               "/path/to/save/file.pdf"
               (λ (bytes-total bytes-received)
                 (log-info "Downloaded" bytes-received "of" bytes-total "bytes")))
```

### WebSocket Connections

```racket
;; WebSocket connection
(define ws-connection
  (websocket-connect "wss://echo.websocket.org"
                     (λ (message)
                       (log-info "Received:" message))
                     #:on-open (λ () (log-info "WebSocket opened"))
                     #:on-close (λ () (log-info "WebSocket closed"))
                     #:on-error (λ (error) (log-error "WebSocket error:" error))))

;; Send message over WebSocket
(websocket-send ws-connection "Hello from Vaelix plugin!")

;; Close WebSocket connection
(websocket-close ws-connection)
```

### API Integration Examples

```racket
;; Weather plugin example
(define (get-weather location)
  (when (check-permission 'network-access)
    (let* ((api-key "your-api-key")
           (url (format #f "http://api.weather.com/v1/current?location=~a&apikey=~a"
                       location api-key))
           (response (http-request url)))
      (when response
        (parse-weather-response response)))))

;; News aggregator example
(define (fetch-news)
  (when (check-permission 'network-access)
    (define sources '("http://feeds.bbci.co.uk/news/rss.xml"
                     "http://rss.cnn.com/rss/edition.rss"))
    (map (λ (source)
           (match (http-request source)
             ['ok (parse-rss-feed source)]
             [_ '()))
         sources)))
```

## Configuration Management

### Configuration Storage

```racket
#lang racket

(require sieben/plugin-api)
(require json)

;; Get configuration value
(define api-key (get-config "api-key" "default-key"))
(define theme (get-config "theme" "light"))
(define enable-notifications (get-config "notifications" #t))

;; Set configuration value
(set-config! "api-key" "new-api-key")
(set-config! "theme" "dark")
(set-config! "notifications" #f)

;; Save configuration to disk
(save-config)

;; Load configuration from disk
(load-config)

;; Configuration schema
(define config-schema
  '((api-key #:type string #:required #t #:default "default-key")
    (theme #:type symbol #:required #f #:default 'light)
    (notifications #:type boolean #:required #f #:default #t)
    (cache-size #:type number #:required #f #:default 100)))

;; Validate configuration
(define (validate-config)
  (match (validate-against-schema (get-all-configs) config-schema)
    ['ok (log-info "Configuration valid")]
    [(list 'error reason) (log-error "Configuration error:" reason)]))
```

### Persistent Storage

```racket
;; Save data to plugin storage
(define (save-plugin-data data)
  (set-config! "plugin-data" (json-encode data))
  (save-config))

;; Load plugin data
(define (load-plugin-data)
  (match (get-config "plugin-data")
    [#f '()]  ; No data stored
    [json-data (json-decode json-data)]
    [_ '()])) ; Invalid data

;; Complex data storage
(define (save-user-preferences preferences)
  (set-config! "preferences"
               (json-encode preferences))
  (save-config))

(define (load-user-preferences)
  (match (get-config "preferences")
    [#f (default-preferences)]  ; Use defaults
    [json (json-decode json)]
    [_ (default-preferences)])) ; Invalid data, use defaults
```

### Default Configuration

```racket
;; Create plugin with default configuration
(define-plugin "my-plugin"
  (λ ()  ; Plugin initialization
    (initialize-config!
     '((api-key . "default-key")
       (theme . "light")
       (cache-enabled . #t)
       (max-cache-size . 1000)))
    (log-info "Plugin initialized with default configuration")))
```

## Plugin Examples

### Basic Plugin Examples

#### 1. Simple Bookmark Plugin

```racket
#lang racket

(require sieben/plugin-api)

(define bookmarks '())

(define (plugin-start)
  (register-event-hook! 'on-page-load add-bookmark)
  (register-event-hook! 'on-new-tab create-bookmark-ui)
  (load-bookmarks!)
  (log-info "Bookmark plugin started"))

(define (plugin-stop)
  (unregister-event-hook! 'on-page-load add-bookmark)
  (unregister-event-hook! 'on-new-tab create-bookmark-ui)
  (save-bookmarks!)
  (log-info "Bookmark plugin stopped"))

(define (add-bookmark tab-id url title)
  (when (and url title)
    (set! bookmarks (cons (list url title (current-seconds)) bookmarks))
    (show-notification (format "Bookmarked: ~a" title) "info")))

(define (create-bookmark-ui tab-id)
  (when (check-permission 'ui-injection)
    (create-widget 'bookmark-bar
                   #:bookmarks bookmarks
                   #:position '(0 0)
                   #:size '(800 30))))

(define bookmarks-file "~/.vaelix/bookmarks.rktd")

(define (save-bookmarks!)
  (call-with-output-file bookmarks-file
    (λ (port) (write bookmarks port))
    #:exists 'replace))

(define (load-bookmarks!)
  (when (file-exists? bookmarks-file)
    (with-input-from-file bookmarks-file
      (λ () (set! bookmarks (read))))))
```

#### 2. Network Monitor Plugin

```racket
#lang racket

(require sieben/plugin-api)
(require net/http-client)

(define (plugin-start)
  (register-event-hook! 'on-navigate log-network-activity)
  (request-permission 'network-access)
  (log-info "Network monitor started"))

(define (log-network-activity url tab-id timestamp)
  (when (check-permission 'network-access)
    (let ((domain (extract-domain url)))
      (record-request domain url timestamp)
      (when (suspicious-domain? domain)
        (show-notification (format "Suspicious domain: ~a" domain)
                          "warning")))))

(define (extract-domain url)
  (string-trim (url->string (url url)) #px"^https?://"))

(define (suspicious-domain? domain)
  (or (string-contains? domain ".tk")
      (string-contains? domain ".ml")
      (string-contains? domain ".cf")))

(define requests '())

(define (record-request domain url timestamp)
  (set! requests (cons (list domain url timestamp) requests))
  (when (> (length requests) 1000)  ; Keep only recent 1000
    (set! requests (take requests 1000))))
```

#### 3. Theme Manager Plugin

```racket
#lang racket

(require sieben/plugin-api)
(require json)

(define current-theme "default")
(define available-themes '())

(define (plugin-start)
  (register-event-hook! 'on-plugin-loaded check-theme-compatibility)
  (request-permission 'ui-injection)
  (load-available-themes!)
  (initialize-theme-manager-ui!))

(define (load-available-themes!)
  (set! available-themes
        '("default" "dark" "light" "high-contrast" "sevenring")))

(define (initialize-theme-manager-ui!)
  (when (check-permission 'ui-injection)
    (create-widget 'theme-selector
                   #:themes available-themes
                   #:current-theme current-theme
                   #:on-change apply-theme!)))

(define (apply-theme! theme-name)
  (set! current-theme theme-name)
  (set-config! "current-theme" theme-name)
  (emit-event 'theme-changed (list theme-name))
  (show-notification (format "Applied theme: ~a" theme-name) "success"))
```

### Advanced Plugin Examples

#### 4. Developer Tools Plugin

```racket
#lang racket

(require sieben/plugin-api)
(require syntax/parse)

(define dev-tools-enabled? #f)

(define (plugin-start)
  (register-keyboard-shortcut "F12" toggle-dev-tools)
  (register-event-hook! 'on-page-load inject-dev-tools)
  (request-permission 'ui-injection))

(define (toggle-dev-tools)
  (set! dev-tools-enabled? (not dev-tools-enabled?))
  (if dev-tools-enabled?
      (show-dev-tools!)
      (hide-dev-tools!)))

(define (show-dev-tools!)
  (create-widget 'dev-tools-panel
                 #:position '(0 400)
                 #:size '(800 200)
                 #:tabs '(("Elements" elements-tab)
                         ("Console" console-tab)
                         ("Network" network-tab)
                         ("Sources" sources-tab))))

(define (hide-dev-tools!)
  (remove-widget 'dev-tools-panel))

(define (inject-dev-tools tab-id url)
  (when dev-tools-enabled?
    (inject-javascript tab-id "console.log('Developer tools active')")))
```

#### 5. Content Blocker Plugin

```racket
#lang racket

(require sieben/plugin-api)

(define blocked-domains '())
(define blocked-urls '())

(define (plugin-start)
  (register-event-hook! 'on-navigate-before check-blocklist)
  (register-event-hook! 'on-navigate-blocked handle-blocked-navigation)
  (load-blocklist!)
  (initialize-content-blocker-ui!))

(define (check-blocklist url tab-id timestamp)
  (define domain (extract-domain url))
  (cond
    [(member domain blocked-domains) 'blocked]
    [(member url blocked-urls) 'blocked]
    [else 'allowed]))

(define (handle-blocked-navigation url tab-id reason)
  (show-notification (format "Blocked: ~a" url) "warning")
  (inject-blocked-page tab-id url reason))

(define (inject-blocked-page tab-id url reason)
  (when (check-permission 'ui-injection)
    (let ((blocked-page (format "<html><body><h1>Content Blocked</h1><p>URL: ~a</p><p>Reason: ~a</p></body></html>"
                               url reason)))
      (inject-javascript tab-id (format "document.body.innerHTML = '~a'" blocked-page)))))

(define (load-blocklist!)
  (set! blocked-domains '("ads.example.com" "tracker.example.com"))
  (set! blocked-urls '("https://malware.example.com/bad.exe")))

(define (initialize-content-blocker-ui!)
  (create-widget 'blocklist-manager
                 #:blocked-domains blocked-domains
                 #:blocked-urls blocked-urls
                 #:on-add-domain add-domain-to-blocklist!
                 #:on-remove-domain remove-domain-from-blocklist!))

(define (add-domain-to-blocklist! domain)
  (set! blocked-domains (cons domain blocked-domains))
  (save-blocklist!))

(define (remove-domain-from-blocklist! domain)
  (set! blocked-domains (remove domain blocked-domains))
  (save-blocklist!))
```

## Best Practices

### Security Best Practices

1. **Request Minimal Permissions**: Only request permissions you actually need
2. **Validate Inputs**: Always validate user inputs and network responses
3. **Handle Errors Gracefully**: Provide meaningful error messages
4. **Sanitize Data**: Sanitize all data before processing
5. **Use Secure Communication**: Always use HTTPS for network requests

```racket
;; Secure plugin template
#lang racket

(require sieben/plugin-api)

(define (plugin-start)
  (register-event-hook! 'on-navigate validate-and-process)
  (request-permission 'network-access)  ; Only request what you need
  (log-info "Secure plugin started"))

(define (validate-and-process url tab-id timestamp)
  (cond
    [(not (string? url)) (log-warning "Invalid URL type")]
    [(string-empty? url) (log-warning "Empty URL")]
    [(not (valid-url? url)) (log-warning "Malformed URL")]
    [else (process-url url tab-id timestamp)]))

(define (valid-url? url)
  (and (string? url)
       (>= (string-length url) 4)
       (or (string-prefix? url "http://")
           (string-prefix? url "https://"))
       (not (string-contains? url "<script"))))
```

### Performance Best Practices

1. **Use Lazy Loading**: Load resources only when needed
2. **Implement Caching**: Cache frequently accessed data
3. **Avoid Blocking Operations**: Use asynchronous operations
4. **Manage Memory**: Clean up resources when done
5. **Use Efficient Data Structures**: Choose appropriate data structures

```racket
;; Efficient plugin with caching
#lang racket

(require sieben/plugin-api)
(require (only-in racket/cache!))

(define cache (make-hash))

(define (get-cached-data key)
  (hash-ref cache key #f))

(define (set-cached-data! key data)
  (hash-set! cache key data)
  (when (> (hash-count cache) 1000)  ; Limit cache size
    (clear-old-cache-entries!)))

(define (clear-old-cache-entries!)
  (for ([(key value) (in-hash cache)])
    (when (cache-entry-expired? key)
      (hash-remove! cache key))))

(define (async-request url callback)
  (spawn-thread
   (λ ()
     (define result (http-request url))
     (callback result))))
```

### User Experience Best Practices

1. **Provide Clear Feedback**: Show loading states and progress
2. **Handle Edge Cases**: Handle network errors, timeouts, etc.
3. **Respect User Preferences**: Honor browser settings
4. **Maintain Consistency**: Follow UI guidelines
5. **Document Features**: Provide clear documentation

```racket
;; User-friendly plugin
#lang racket

(require sieben/plugin-api)

(define (show-loading-state action-name)
  (show-notification (format "~a..." action-name) "info")
  (set-config! "loading" #t))

(define (show-success-state action-name)
  (show-notification (format "~a completed" action-name) "success")
  (set-config! "loading" #f))

(define (show-error-state action-name error-message)
  (show-notification (format "~a failed: ~a" action-name error-message) "error")
  (set-config! "loading" #f))

(define (perform-action-with-feedback action-name action-fn)
  (show-loading-state action-name)
  (call-with-exception-handler
   (λ (exn)
     (show-error-state action-name (exn-message exn))
     (raise exn))
   (λ ()
     (define result (action-fn))
     (show-success-state action-name)
     result)))
```

### Plugin Testing

```racket
#lang racket

(require rackunit)
(require sieben/plugin-api)

(module+ test
  (define-test-suite plugin-api-tests
    (test-case "Event hook registration"
      (register-event-hook! 'test-event (λ () 'test))
      (check-true (event-hook-registered? 'test-event)))

    (test-case "Configuration management"
      (set-config! "test-key" "test-value")
      (check-equal? (get-config "test-key") "test-value"))

    (test-case "Permission checking"
      (request-permission 'network-access)
      (check-true (check-permission 'network-access)))

    (test-case "UI widget creation"
      (define widget-id (create-widget 'button))
      (check-true (widget-exists? widget-id)))))
```

---

*This plugin API documentation is actively maintained. For the latest updates and additional examples, visit our [plugin development guide](https://github.com/veridian-zenith/vaelix/wiki/Plugin-Development).*
