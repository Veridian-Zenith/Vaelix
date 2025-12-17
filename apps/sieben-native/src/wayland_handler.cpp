#include "wayland_handler.h"
#include <iostream>
#include <cstring>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <linux/input.h>

// Vulkan Wayland extension
#define VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME "VK_KHR_wayland_surface"

WaylandHandler::WaylandHandler() {
    // Initialize members to null/default values
    display_ = nullptr;
    registry_ = nullptr;
    compositor_ = nullptr;
    shell_ = nullptr;
    surface_ = nullptr;
    egl_window_ = nullptr;
    egl_display_ = EGL_NO_DISPLAY;
    egl_config_ = nullptr;
    egl_surface_ = EGL_NO_SURFACE;
    egl_context_ = EGL_NO_CONTEXT;
    xkb_context_ = nullptr;
    xkb_keymap_ = nullptr;
    xkb_state_ = nullptr;
    va_display_ = nullptr;
    va_config_id_ = VA_INVALID_ID;
    va_context_id_ = VA_INVALID_ID;
    vulkan_instance_ = VK_NULL_HANDLE;
    vulkan_physical_device_ = VK_NULL_HANDLE;
    vulkan_device_ = VK_NULL_HANDLE;
}

WaylandHandler::~WaylandHandler() {
    Cleanup();
}

bool WaylandHandler::Initialize() {
    if (!SetupWaylandConnection()) {
        std::cerr << "Failed to setup Wayland connection" << std::endl;
        return false;
    }

    if (!SetupEGL()) {
        std::cerr << "Failed to setup EGL" << std::endl;
        return false;
    }

    return true;
}

bool WaylandHandler::SetupWaylandConnection() {
    // Connect to Wayland display
    display_ = wl_display_connect(nullptr);
    if (!display_) {
        std::cerr << "Failed to connect to Wayland display" << std::endl;
        return false;
    }

    // Get registry
    registry_ = wl_display_get_registry(display_);
    if (!registry_) {
        std::cerr << "Failed to get Wayland registry" << std::endl;
        return false;
    }

    // Set up registry listener
    static const wl_registry_listener registry_listener = {
        RegistryGlobalHandler,
        RegistryGlobalRemoveHandler
    };

    wl_registry_add_listener(registry_, &registry_listener, this);

    // Roundtrip to receive registry events
    wl_display_roundtrip(display_);

    if (!compositor_ || !shell_) {
        std::cerr << "Failed to bind required Wayland interfaces" << std::endl;
        return false;
    }

    // Initialize XKB context
    xkb_context_ = xkb_context_new(XKB_CONTEXT_NO_FLAGS);
    if (!xkb_context_) {
        std::cerr << "Failed to create XKB context" << std::endl;
        return false;
    }

    return true;
}

bool WaylandHandler::SetupEGL() {
    // Get EGL display
    egl_display_ = eglGetDisplay((EGLNativeDisplayType)display_);
    if (egl_display_ == EGL_NO_DISPLAY) {
        std::cerr << "Failed to get EGL display" << std::endl;
        return false;
    }

    // Initialize EGL
    EGLint major, minor;
    if (!eglInitialize(egl_display_, &major, &minor)) {
        std::cerr << "Failed to initialize EGL" << std::endl;
        return false;
    }

    std::cout << "EGL version: " << major << "." << minor << std::endl;

    // Choose EGL config
    const EGLint config_attrs[] = {
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_ALPHA_SIZE, 8,
        EGL_DEPTH_SIZE, 24,
        EGL_STENCIL_SIZE, 8,
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_NONE
    };

    EGLint num_configs;
    if (!eglChooseConfig(egl_display_, config_attrs, &egl_config_, 1, &num_configs) || num_configs == 0) {
        std::cerr << "Failed to choose EGL config" << std::endl;
        return false;
    }

    // Create EGL context
    const EGLint context_attrs[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };

    egl_context_ = eglCreateContext(egl_display_, egl_config_, EGL_NO_CONTEXT, context_attrs);
    if (egl_context_ == EGL_NO_CONTEXT) {
        std::cerr << "Failed to create EGL context" << std::endl;
        return false;
    }

    return true;
}

bool WaylandHandler::CreateSurface(int width, int height) {
    width_ = width;
    height_ = height;

    // Create Wayland surface
    surface_ = wl_compositor_create_surface(compositor_);
    if (!surface_) {
        std::cerr << "Failed to create Wayland surface" << std::endl;
        return false;
    }

    // Create EGL window
    egl_window_ = wl_egl_window_create(surface_, width_, height_);
    if (!egl_window_) {
        std::cerr << "Failed to create EGL window" << std::endl;
        return false;
    }

    // Create EGL surface
    egl_surface_ = eglCreateWindowSurface(egl_display_, egl_config_, (EGLNativeWindowType)egl_window_, nullptr);
    if (egl_surface_ == EGL_NO_SURFACE) {
        std::cerr << "Failed to create EGL surface" << std::endl;
        return false;
    }

    // Make current
    if (!eglMakeCurrent(egl_display_, egl_surface_, egl_surface_, egl_context_)) {
        std::cerr << "Failed to make EGL context current" << std::endl;
        return false;
    }

    return true;
}

void WaylandHandler::HandleEvents() {
    while (wl_display_dispatch(display_) != -1) {
        // Handle events
    }
}

bool WaylandHandler::SetupVAAPI() {
    // Get DRM device
    int drm_fd = open("/dev/dri/renderD128", O_RDWR | O_CLOEXEC);
    if (drm_fd < 0) {
        std::cerr << "Failed to open DRM device" << std::endl;
        return false;
    }

    // Initialize VA display
    va_display_ = vaGetDisplayDRM(drm_fd);
    if (!va_display_) {
        std::cerr << "Failed to get VA display" << std::endl;
        close(drm_fd);
        return false;
    }

    // Initialize VA
    int major_version, minor_version;
    VAStatus va_status = vaInitialize(va_display_, &major_version, &minor_version);
    if (va_status != VA_STATUS_SUCCESS) {
        std::cerr << "Failed to initialize VA: " << vaErrorStr(va_status) << std::endl;
        close(drm_fd);
        return false;
    }

    std::cout << "VA-API version: " << major_version << "." << minor_version << std::endl;

    // Find config
    VAConfigAttrib config_attrib;
    config_attrib.type = VAConfigAttribRTFormat;
    config_attrib.value = VA_RT_FORMAT_YUV420;

    va_status = vaCreateConfig(va_display_, VAProfileNone, VAEntrypointVLD,
                              &config_attrib, 1, &va_config_id_);
    if (va_status != VA_STATUS_SUCCESS) {
        std::cerr << "Failed to create VA config: " << vaErrorStr(va_status) << std::endl;
        close(drm_fd);
        return false;
    }

    // Create context
    va_status = vaCreateContext(va_display_, va_config_id_, width_, height_,
                              VA_PROGRESSIVE, nullptr, 0, &va_context_id_);
    if (va_status != VA_STATUS_SUCCESS) {
        std::cerr << "Failed to create VA context: " << vaErrorStr(va_status) << std::endl;
        close(drm_fd);
        return false;
    }

    close(drm_fd);
    return true;
}

bool WaylandHandler::SetupVulkan() {
    // Create Vulkan instance
    VkApplicationInfo app_info = {};
    app_info.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    app_info.pApplicationName = "Sieben Native";
    app_info.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    app_info.pEngineName = "Vaelix";
    app_info.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    app_info.apiVersion = VK_API_VERSION_1_2;

    VkInstanceCreateInfo create_info = {};
    create_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    create_info.pApplicationInfo = &app_info;

    // Enable Wayland surface extension
    const char* extensions[] = {
        VK_KHR_WAYLAND_SURFACE_EXTENSION_NAME,
        VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME
    };
    create_info.enabledExtensionCount = 2;
    create_info.ppEnabledExtensionNames = extensions;

    if (vkCreateInstance(&create_info, nullptr, &vulkan_instance_) != VK_SUCCESS) {
        std::cerr << "Failed to create Vulkan instance" << std::endl;
        return false;
    }

    // Get physical device (prefer Intel)
    uint32_t device_count = 0;
    vkEnumeratePhysicalDevices(vulkan_instance_, &device_count, nullptr);
    if (device_count == 0) {
        std::cerr << "No Vulkan devices found" << std::endl;
        return false;
    }

    VkPhysicalDevice devices[device_count];
    vkEnumeratePhysicalDevices(vulkan_instance_, &device_count, devices);

    // Look for Intel device
    for (uint32_t i = 0; i < device_count; i++) {
        VkPhysicalDeviceProperties props;
        vkGetPhysicalDeviceProperties(devices[i], &props);

        if (strstr(props.deviceName, "Intel") != nullptr) {
            vulkan_physical_device_ = devices[i];
            std::cout << "Using Intel Vulkan device: " << props.deviceName << std::endl;
            break;
        }
    }

    if (!vulkan_physical_device_) {
        vulkan_physical_device_ = devices[0];
        std::cout << "Using default Vulkan device" << std::endl;
    }

    // Create logical device
    float queue_priority = 1.0f;
    VkDeviceQueueCreateInfo queue_info = {};
    queue_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    queue_info.queueFamilyIndex = 0;
    queue_info.queueCount = 1;
    queue_info.pQueuePriorities = &queue_priority;

    VkDeviceCreateInfo device_info = {};
    device_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    device_info.queueCreateInfoCount = 1;
    device_info.pQueueCreateInfos = &queue_info;

    if (vkCreateDevice(vulkan_physical_device_, &device_info, nullptr, &vulkan_device_) != VK_SUCCESS) {
        std::cerr << "Failed to create Vulkan device" << std::endl;
        return false;
    }

    return true;
}

void WaylandHandler::Cleanup() {
    // Cleanup Vulkan
    if (vulkan_device_ != VK_NULL_HANDLE) {
        vkDestroyDevice(vulkan_device_, nullptr);
    }
    if (vulkan_instance_ != VK_NULL_HANDLE) {
        vkDestroyInstance(vulkan_instance_, nullptr);
    }

    // Cleanup VA-API
    if (va_context_id_ != VA_INVALID_ID) {
        vaDestroyContext(va_display_, va_context_id_);
    }
    if (va_config_id_ != VA_INVALID_ID) {
        vaDestroyConfig(va_display_, va_config_id_);
    }
    if (va_display_) {
        vaTerminate(va_display_);
    }

    // Cleanup EGL
    if (egl_display_ != EGL_NO_DISPLAY) {
        eglMakeCurrent(egl_display_, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (egl_context_ != EGL_NO_CONTEXT) {
            eglDestroyContext(egl_display_, egl_context_);
        }
        if (egl_surface_ != EGL_NO_SURFACE) {
            eglDestroySurface(egl_display_, egl_surface_);
        }
        eglTerminate(egl_display_);
    }

    // Cleanup Wayland EGL window
    if (egl_window_) {
        wl_egl_window_destroy(egl_window_);
    }

    // Cleanup XKB
    if (xkb_state_) {
        xkb_state_unref(xkb_state_);
    }
    if (xkb_keymap_) {
        xkb_keymap_unref(xkb_keymap_);
    }
    if (xkb_context_) {
        xkb_context_unref(xkb_context_);
    }

    // Cleanup Wayland objects
    if (surface_) {
        wl_surface_destroy(surface_);
    }
    if (shell_) {
        wl_shell_destroy(shell_);
    }
    if (compositor_) {
        wl_compositor_destroy(compositor_);
    }
    if (registry_) {
        wl_registry_destroy(registry_);
    }
    if (display_) {
        wl_display_disconnect(display_);
    }
}

void WaylandHandler::RegistryGlobalHandler(void* data, wl_registry* registry,
                                        uint32_t id, const char* interface,
                                        uint32_t version) {
    auto* handler = static_cast<WaylandHandler*>(data);

    if (strcmp(interface, wl_compositor_interface.name) == 0) {
        handler->compositor_ = static_cast<wl_compositor*>(wl_registry_bind(registry, id, &wl_compositor_interface, 1));
    } else if (strcmp(interface, wl_shell_interface.name) == 0) {
        handler->shell_ = static_cast<wl_shell*>(wl_registry_bind(registry, id, &wl_shell_interface, 1));
    }
}

void WaylandHandler::RegistryGlobalRemoveHandler(void* data, wl_registry* registry,
                                              uint32_t id) {
    // Handle interface removal
}
