#ifndef WAYLAND_HANDLER_H
#define WAYLAND_HANDLER_H

#include <EGL/egl.h>
#include <gbm.h>
#include <memory>
#include <string>
#include <va/va.h>
#include <va/va_drm.h>
#include <vulkan/vulkan.h>
#include <wayland-client.h>
#include <wayland-egl.h>
#include <xkbcommon/xkbcommon.h>

class WaylandHandler {
public:
  WaylandHandler();
  ~WaylandHandler();

  // Initialize Wayland connection and setup
  bool Initialize();

  // Create Wayland surface and EGL context
  bool CreateSurface(int width, int height);

  // Handle Wayland events
  void HandleEvents();

  // Get Wayland display
  wl_display *GetDisplay() const { return display_; }

  // Get Wayland surface
  wl_surface *GetSurface() const { return surface_; }

  // Get EGL display
  EGLDisplay GetEGLDisplay() const { return egl_display_; }

  // Get EGL surface
  EGLSurface GetEGLSurface() const { return egl_surface_; }

  // Get EGL context
  EGLContext GetEGLContext() const { return egl_context_; }

  // Intel-specific: Setup VA-API for hardware acceleration
  bool SetupVAAPI();

  // Intel-specific: Setup Vulkan for rendering
  bool SetupVulkan();

private:
  // Wayland objects
  wl_display *display_ = nullptr;
  wl_registry *registry_ = nullptr;
  wl_compositor *compositor_ = nullptr;
  wl_shell *shell_ = nullptr;
  wl_surface *surface_ = nullptr;
  wl_egl_window *egl_window_ = nullptr;

  // EGL objects
  EGLDisplay egl_display_ = EGL_NO_DISPLAY;
  EGLConfig egl_config_ = nullptr;
  EGLSurface egl_surface_ = EGL_NO_SURFACE;
  EGLContext egl_context_ = EGL_NO_CONTEXT;

  // XKB for keyboard input
  struct xkb_context *xkb_context_ = nullptr;
  struct xkb_keymap *xkb_keymap_ = nullptr;
  struct xkb_state *xkb_state_ = nullptr;

  // Intel VA-API for hardware acceleration
  VADisplay va_display_ = nullptr;
  VAConfigID va_config_id_ = VA_INVALID_ID;
  VAContextID va_context_id_ = VA_INVALID_ID;

  // Vulkan for rendering
  VkInstance vulkan_instance_ = VK_NULL_HANDLE;
  VkPhysicalDevice vulkan_physical_device_ = VK_NULL_HANDLE;
  VkDevice vulkan_device_ = VK_NULL_HANDLE;

  // Dimensions
  int width_ = 1280;
  int height_ = 720;

  // Private methods
  bool SetupWaylandConnection();
  bool SetupEGL();
  bool CreateEGLWindow();
  void Cleanup();

  // Static registry listener
  static void RegistryGlobalHandler(void *data, wl_registry *registry,
                                    uint32_t id, const char *interface,
                                    uint32_t version);
  static void RegistryGlobalRemoveHandler(void *data, wl_registry *registry,
                                          uint32_t id);
};

#endif // WAYLAND_HANDLER_H
