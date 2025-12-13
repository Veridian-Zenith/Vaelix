# WPE + EFL Migration Todo List

## Overview
Complete migration from CEF to WPE WebKit using EFL (Enlightenment Foundation Libraries) instead of GTK4, as CEF has proven too complex and problematic.

## Current Status Assessment
- ✅ **CMakeLists.txt**: Partially updated (but incorrectly using GTK4 instead of EFL)
- ❌ **main.cc**: Still using CEF completely
- ❌ **browser_manager.h**: Uses WPE concepts but needs EFL integration
- ❌ **Browser implementation**: Still CEF-based
- ❌ **Window integration**: Needs EFL adaptation

## Migration Tasks

### Phase 1: Build System Correction
- [ ] Fix CMakeLists.txt to remove GTK4 dependencies
- [ ] Add proper EFL dependencies (elementary, evas, ecore)
- [ ] Update pkg-config modules to use EFL exclusively
- [ ] Verify WPE WebKit + EFL integration builds

### Phase 2: Main Application Migration
- [ ] Rewrite main.cc to use WPE + EFL instead of CEF
- [ ] Replace CEF initialization with WPE Platform initialization
- [ ] Update event loop to use EFL main loop
- [ ] Remove all CEF includes and dependencies
- [ ] Update application lifecycle management

### Phase 3: Browser Manager Implementation
- [ ] Implement WPE WebView creation using EFL widgets
- [ ] Replace TabInfo::web_view with proper WebKitWebView*
- [ ] Implement navigation handling with WPE APIs
- [ ] Add loading state management for WPE
- [ ] Implement JavaScript execution via WPE

### Phase 4: Window Integration
- [ ] Adapt window_manager.h for EFL window management
- [ ] Implement EFL-based window creation and management
- [ ] Integrate WPE WebView with EFL windows
- [ ] Handle window lifecycle events

### Phase 5: IPC Bridge Update
- [ ] Update IPC bridge to work with WPE event model
- [ ] Ensure IPC communication still works with new browser backend
- [ ] Test cross-language communication (Elixir ↔ WPE)

### Phase 6: Render Handler Migration
- [ ] Replace CefRenderHandler with WPE drawing delegates
- [ ] Implement EFL surface integration for rendering
- [ ] Handle web content drawing and display

### Phase 7: Testing and Validation
- [ ] Build application with new WPE + EFL setup
- [ ] Test basic navigation functionality
- [ ] Verify window management works correctly
- [ ] Test IPC bridge communication
- [ ] Validate rendering pipeline
- [ ] Ensure JavaScript execution works

### Phase 8: Cleanup
- [ ] Remove all remaining CEF includes and dependencies
- [ ] Delete unused CEF-related files
- [ ] Update documentation to reflect WPE + EFL usage
- [ ] Update build instructions

## Key Technical Requirements

### WPE + EFL Integration Points
- **WebView Container**: WebKitWebView as EFL widget
- **Event Loop**: EFL main loop instead of CEF message loop
- **Window Management**: EFL Elementary windows
- **Rendering**: EFL canvas with WPE surfaces
- **Signals**: EFL signal system for event handling

### API Mapping Changes
- `CefApp` → WPE Platform initialization + EFL app
- `CefBrowser` → WebKitWebView in EFL container
- `CefWindowInfo` → EFL Elementary window
- `CefClient` → WPE navigation delegates + EFL callbacks
- `CefRenderHandler` → WPE drawing + EFL surface

### Build Dependencies
```cmake
# Required packages
EFL: efl, ecore, elementary, evas, eina
WPE: wpewebkit, glib-2.0
Remove: gtk4 (not used)
```

## Benefits of WPE + EFL Over CEF
1. **Simplified Integration**: Direct EFL integration vs complex CEF embedding
2. **Better Performance**: Optimized for embedded systems
3. **Maintainable**: EFL + WPE are actively maintained and simpler
4. **Consistent UI**: Unified EFL widget system
5. **Reduced Dependencies**: Eliminates CEF's massive dependency tree

## Success Criteria
- [ ] Application builds without CEF dependencies
- [ ] Basic browser functionality works (navigation, loading)
- [ ] Window management integrated with EFL
- [ ] IPC communication preserved
- [ ] Rendering works correctly with WPE + EFL
- [ ] Code is significantly simpler and more maintainable
