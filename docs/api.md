# Vaelix Public API Contracts (Initial Draft)

## tiamat-core
- HTML5 parser/tokenizer: `parse_html(input: &str) -> DomTree`
- DOM tree: `DomNode`, `DomTree`, mutation observer, shadow DOM
- CSS parser: `parse_css(input: &str) -> CssStylesheet`
- Renderer: `render(dom: &DomTree, css: &CssStylesheet) -> FrameBuffer`
- Networking: `fetch(url: &str, options: FetchOptions) -> Response`
- JS engine: `execute_js(script: &str, context: &DomTree) -> JsResult`

## vaelix-shell
- Tab/session manager: `open_tab(url: &str)`, `close_tab(id: TabId)`, `list_tabs() -> Vec<TabInfo>`
- Navigation: `navigate(tab: TabId, url: &str)`
- IPC: `send_message(target: Module, msg: Message)`

## vaelix-ui
- Window management: `open_window()`, `close_window(id: WindowId)`
- Theme engine: `set_theme(theme: Theme)`
- Accessibility: `enable_accessibility()`

## vaelix-law
- Consent manager: `request_consent(type: ConsentType) -> ConsentResult`
- Audit logging: `log_event(event: LawEvent)`
- Compliance reporting: `generate_report() -> ComplianceReport`

## vaelix-privacy
- Ad/tracker blocking: `update_blocklists(lists: Vec<Blocklist>)`
- Shield mode: `enable_shield(tab: TabId)`

## vaelix-ext
- Extension API: `register_extension(ext: ExtensionManifest)`
- Native plugin API: `register_plugin(plugin: PluginManifest)`

---
This is a living document. Update as APIs are designed and implemented.
