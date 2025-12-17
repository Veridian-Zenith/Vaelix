#include "wayland_handler.h"
#include <chrono>
#include <iostream>
#include <thread>

// CEF includes
#include <cef_app.h>
#include <cef_base.h>
#include <cef_browser.h>
#include <cef_client.h>
#include <cef_command_line.h>
#include <cef_scheme.h>
#include <wrapper/cef_helpers.h>

// CEF Application implementation
class SiebenApp : public CefApp,
                  public CefClient,
                  public CefBrowserProcessHandler {
public:
  SiebenApp() = default;

  // CefBase methods (reference counting)
  void AddRef() const override {}
  bool Release() const override { return true; }
  bool HasOneRef() const override { return false; }
  bool HasAtLeastOneRef() const override { return false; }

  // CefClient methods
  CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override {
    return this;
  }

  // CefBrowserProcessHandler methods
  void OnContextInitialized() override {
    CEF_REQUIRE_UI_THREAD();

    // Command line settings
    CefRefPtr<CefCommandLine> command_line =
        CefCommandLine::GetGlobalCommandLine();

    // Enable GPU acceleration
    command_line->AppendSwitch("enable-gpu");
    command_line->AppendSwitch("enable-gpu-rasterization");
    command_line->AppendSwitch("enable-zero-copy");
    command_line->AppendSwitch("use-gl=egl");

    // Intel-specific optimizations
    command_line->AppendSwitch(
        "enable-features=VaapiVideoDecoder,VaapiVideoEncoder");
    command_line->AppendSwitch(
        "disable-features=UseChromeOSDirectVideoDecoder");
    command_line->AppendSwitch("use-vulkan");

    // Wayland-specific settings
    command_line->AppendSwitch("ozone-platform=wayland");
    command_line->AppendSwitch("enable-wayland-server");

    // Create browser window
    CefWindowInfo window_info;
    CefBrowserSettings browser_settings;

    // Set window info for Wayland
    window_info.SetAsWindowless(0); // We'll handle windowing via Wayland

    // Create browser
    CefBrowserHost::CreateBrowser(window_info, this, "https://www.google.com",
                                  browser_settings, nullptr, nullptr);
  }

  void OnBeforeCommandLineProcessing(
      const CefString &process_type,
      CefRefPtr<CefCommandLine> command_line) override {
    // Set up command line arguments before processing
    command_line->AppendSwitch("enable-gpu");
    command_line->AppendSwitch("enable-gpu-rasterization");
    command_line->AppendSwitch("enable-zero-copy");
    command_line->AppendSwitch("use-gl=egl");
    command_line->AppendSwitch("ozone-platform=wayland");
    command_line->AppendSwitch("enable-wayland-server");
    command_line->AppendSwitch(
        "enable-features=VaapiVideoDecoder,VaapiVideoEncoder");
    command_line->AppendSwitch("use-vulkan");
  }
};

// Main function
int main(int argc, char *argv[]) {
  std::cout << "Sieben Native - Wayland CEF Browser" << std::endl;
  std::cout << "Intel-optimized with VA-API and Vulkan support" << std::endl;

  // Initialize Wayland handler
  WaylandHandler wayland_handler;

  if (!wayland_handler.Initialize()) {
    std::cerr << "Failed to initialize Wayland handler" << std::endl;
    return 1;
  }

  // Create Wayland surface
  if (!wayland_handler.CreateSurface(1280, 720)) {
    std::cerr << "Failed to create Wayland surface" << std::endl;
    return 1;
  }

  // Setup Intel hardware acceleration
  if (!wayland_handler.SetupVAAPI()) {
    std::cerr << "Warning: Failed to setup VA-API, continuing without hardware "
                 "acceleration"
              << std::endl;
  }

  if (!wayland_handler.SetupVulkan()) {
    std::cerr
        << "Warning: Failed to setup Vulkan, continuing with fallback rendering"
        << std::endl;
  }

  // CEF main args
  CefMainArgs main_args(argc, argv);

  // CEF settings
  CefSettings settings;
  settings.no_sandbox = true; // For development, disable sandbox
  settings.multi_threaded_message_loop = true;
  settings.external_message_pump = true;
  settings.windowless_rendering_enabled = true;

  // Initialize CEF
  CefRefPtr<SiebenApp> app(new SiebenApp());

  // Execute CEF main
  int exit_code = CefExecuteProcess(main_args, app.get(), nullptr);
  if (exit_code >= 0) {
    return exit_code;
  }

  // Initialize CEF
  if (!CefInitialize(main_args, settings, app.get(), nullptr)) {
    std::cerr << "Failed to initialize CEF" << std::endl;
    return 1;
  }

  std::cout << "CEF initialized successfully" << std::endl;
  std::cout << "Running message loop..." << std::endl;

  // Run CEF message loop
  CefRunMessageLoop();

  // Cleanup CEF
  CefShutdown();

  std::cout << "Browser exited cleanly" << std::endl;
  return 0;
}
