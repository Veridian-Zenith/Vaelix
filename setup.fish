#!/usr/bin/env fish

# === CONFIG ===
set project_name "Vaelix"
set author_name "Dae Euhwa <daedaevibin@proton.me>"

# === FUNCTION ===
function create_crate --argument crate_path
    echo "📦 Creating crate: $crate_path"
    cargo new $crate_path --lib
end

# === BEGIN ===
echo "🚀 Setting up Rust workspace for $project_name..."

# 1. Create Crates First
create_crate "tiamat-core"
create_crate "vaelix-shell"
create_crate "vaelix-ui"
create_crate "vaelix-law"
create_crate "vaelix-privacy"
create_crate "vaelix-ext"

# 2. NOW Add Workspace Cargo.toml
echo "[workspace]
members = [
    \"tiamat-core\",
    \"vaelix-shell\",
    \"vaelix-ui\",
    \"vaelix-law\",
    \"vaelix-privacy\",
    \"vaelix-ext\"
]
" > Cargo.toml

# 3. Generate README
echo "# $project_name

**Vaelix** is a fully independent, privacy-first browser engine and UI, built in Rust.

## Modules

- \`tiamat-core\`: HTML/CSS/DOM/rendering/networking/JS engine
- \`vaelix-shell\`: Tab/session/navigation controller, process isolation
- \`vaelix-ui\`: UI shell, window management, themes, accessibility
- \`vaelix-law\`: Legal compliance (GDPR/ePrivacy/DSA/CCPA)
- \`vaelix-privacy\`: Ad/tracker/fingerprint blocking, shield mode
- \`vaelix-ext\`: Extension system (Chrome API, native plugins)
" > README.md

# 4. LICENSE
echo "MIT License

(c) 2025 $author_name

Permission is hereby granted, free of charge..." > LICENSE

# 5. .gitignore
echo "
/target
**/*.rs.bk
Cargo.lock
.DS_Store
.idea/
.vscode/
*.log
*.tmp
*.swp
node_modules/
" > .gitignore

# 6. Populate Basic lib.rs Files
echo "pub fn hello() {
    println!(\"Tiamat Core initialized.\");
}" > tiamat-core/src/lib.rs

echo "pub fn boot_shell() {
    println!(\"Shell ready.\");
}" > vaelix-shell/src/lib.rs

echo "pub fn launch_ui() {
    println!(\"UI rendering.\");
}" > vaelix-ui/src/lib.rs

echo "pub fn enforce_rules() {
    println!(\"GDPR/ePrivacy/DSA compliance enabled.\");
}" > vaelix-law/src/lib.rs

echo "pub fn init_shield() {
    println!(\"Privacy shield active.\");
}" > vaelix-privacy/src/lib.rs

echo "pub fn ext_api() {
    println!(\"Extension system loaded.\");
}" > vaelix-ext/src/lib.rs

# 7. Done
echo "✅ $project_name setup complete. No git involved, and all crates registered cleanly."
echo "➡️ Run 'cargo build' to verify workspace integrity."
