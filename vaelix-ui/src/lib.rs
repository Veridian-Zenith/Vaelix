use eframe::egui::{self, Color32, FontDefinitions, FontFamily, Style, Visuals};

pub fn launch_ui() {
    let options = eframe::NativeOptions::default();
    eframe::run_native("Vaelix Browser", options, Box::new(|cc| Box::new(VaelixApp::new(cc))))
        .unwrap();
}

pub struct VaelixApp {
    theme: Style,
    search_query: String,
    search_engine: SearchEngine,
    results: Vec<String>,
}

#[derive(Default, Clone, Copy, PartialEq)]
pub enum SearchEngine {
    #[default]
    Google,
    Naver,
    Bing,
    DuckDuckGo,
    Ecosia,
}

impl SearchEngine {
    pub fn as_str(&self) -> &'static str {
        match self {
            SearchEngine::Google => "Google",
            SearchEngine::Naver => "Naver",
            SearchEngine::Bing => "Bing",
            SearchEngine::DuckDuckGo => "DuckDuckGo",
            SearchEngine::Ecosia => "Ecosia",
        }
    }
    pub fn url(&self, query: &str) -> String {
        let q = urlencoding::encode(query);
        match self {
            SearchEngine::Google => format!("https://www.google.com/search?q={}", q),
            SearchEngine::Naver => format!("https://search.naver.com/search.naver?query={}", q),
            SearchEngine::Bing => format!("https://www.bing.com/search?q={}", q),
            SearchEngine::DuckDuckGo => format!("https://duckduckgo.com/?q={}", q),
            SearchEngine::Ecosia => format!("https://www.ecosia.org/search?q={}", q),
        }
    }
}

impl VaelixApp {
    pub fn new(cc: &eframe::CreationContext<'_>) -> Self {
        let mut fonts = FontDefinitions::default();
        fonts.font_data.insert(
            "Gamja Flower".to_owned(),
            egui::FontData::from_static(include_bytes!(
                "../../assets/fonts/GamjaFlower-Regular.ttf"
            )),
        );
        fonts
            .families
            .entry(FontFamily::Proportional)
            .or_default()
            .insert(0, "Gamja Flower".to_owned());
        cc.egui_ctx.set_fonts(fonts);
        cc.egui_ctx.set_style(gold_aura_dark_theme());
        Self {
            theme: gold_aura_dark_theme(),
            search_query: String::new(),
            search_engine: SearchEngine::Google,
            results: vec![],
        }
    }
}

impl eframe::App for VaelixApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::TopBottomPanel::top("nav_bar").show(ctx, |ui| {
            ui.horizontal_centered(|ui| {
                ui.add_space(8.0);
                ui.label(
                    egui::RichText::new("🟡 Vaelix")
                        .font(egui::FontId::proportional(28.0))
                        .color(Color32::from_rgb(255, 215, 0)),
                );
                ui.add_space(16.0);
                egui::Frame::none()
                    .fill(Color32::from_rgba_unmultiplied(30, 30, 30, 220))
                    .rounding(12.0)
                    .stroke(egui::Stroke::new(1.0, Color32::from_rgb(255, 215, 0)))
                    .show(ui, |ui| {
                        ui.set_min_width(400.0);
                        let search_bar = egui::TextEdit::singleline(&mut self.search_query)
                            .hint_text("Search the web...")
                            .font(egui::FontId::proportional(22.0));
                        let search = ui.add(search_bar);
                        if search.lost_focus() && ui.input(|i| i.key_pressed(egui::Key::Enter)) {
                            let url = self.search_engine.url(&self.search_query);
                            open::that(url).ok();
                        }
                    });
                ui.add_space(8.0);
                egui::ComboBox::from_id_source("search_engine")
                    .selected_text(self.search_engine.as_str())
                    .width(120.0)
                    .show_ui(ui, |ui| {
                        for engine in [
                            SearchEngine::Google,
                            SearchEngine::Naver,
                            SearchEngine::Bing,
                            SearchEngine::DuckDuckGo,
                            SearchEngine::Ecosia,
                        ] {
                            ui.selectable_value(&mut self.search_engine, engine, engine.as_str());
                        }
                    });
                ui.add_space(8.0);
                let go_btn = ui.add_sized(
                    [48.0, 40.0],
                    egui::Button::new(egui::RichText::new("→").size(22.0)),
                );
                if go_btn.clicked() {
                    let url = self.search_engine.url(&self.search_query);
                    open::that(url).ok();
                }
            });
        });
        egui::CentralPanel::default()
            .frame(
                egui::Frame::none()
                    .fill(Color32::from_rgba_unmultiplied(20, 20, 20, 220))
                    .rounding(16.0)
                    .shadow(egui::epaint::Shadow {
                        offset: egui::vec2(0.0, 12.0),
                        blur: 32.0,
                        spread: 0.0,
                        color: Color32::from_rgba_unmultiplied(0, 0, 0, 120),
                    }),
            )
            .show(ctx, |ui| {
                ui.vertical_centered(|ui| {
                    ui.add_space(64.0);
                    ui.label(
                        egui::RichText::new("Welcome to Vaelix Browser!")
                            .font(egui::FontId::proportional(32.0))
                            .color(Color32::from_rgb(255, 215, 0)),
                    );
                    ui.add_space(16.0);
                    ui.label(
                        egui::RichText::new("A modern, privacy-focused browser for the next era.")
                            .font(egui::FontId::proportional(20.0))
                            .color(Color32::from_rgb(230, 190, 138)),
                    );
                    ui.add_space(32.0);
                    ui.label(
                        egui::RichText::new(
                            "Type a query above and select a search engine to begin.",
                        )
                        .font(egui::FontId::proportional(18.0))
                        .color(Color32::from_gray(180)),
                    );
                });
            });
    }
}

fn gold_aura_dark_theme() -> Style {
    let mut style = Style::default();
    style.visuals = Visuals::dark();
    style.visuals.override_text_color = Some(Color32::from_rgb(255, 215, 0)); // Gold
    style.visuals.widgets.noninteractive.bg_fill = Color32::from_rgb(0, 0, 0);
    style.visuals.widgets.inactive.bg_fill = Color32::from_rgb(17, 17, 17);
    style.visuals.widgets.hovered.bg_fill = Color32::from_rgb(17, 17, 17);
    style.visuals.widgets.active.bg_fill = Color32::from_rgb(230, 190, 138);
    style.visuals.window_rounding = 12.0.into();
    style.visuals.window_shadow = egui::epaint::Shadow {
        offset: egui::vec2(0.0, 8.0),
        blur: 32.0,
        spread: 0.0,
        color: Color32::from_rgba_unmultiplied(0, 0, 0, 160),
    };
    style.visuals.window_fill = Color32::from_rgb(0, 0, 0);
    style.visuals.faint_bg_color = Color32::from_rgb(17, 17, 17);
    style.visuals.extreme_bg_color = Color32::from_rgb(0, 0, 0);
    style.visuals.selection.bg_fill = Color32::from_rgb(230, 190, 138);
    style.visuals.selection.stroke = egui::Stroke::new(2.0, Color32::from_rgb(255, 215, 0));
    style.visuals.widgets.hovered.fg_stroke =
        egui::Stroke::new(2.0, Color32::from_rgb(255, 215, 0));
    style.visuals.widgets.active.fg_stroke = egui::Stroke::new(2.0, Color32::from_rgb(0, 0, 0));
    style.visuals.widgets.inactive.fg_stroke =
        egui::Stroke::new(1.0, Color32::from_rgb(255, 215, 0));
    style.visuals.widgets.noninteractive.fg_stroke =
        egui::Stroke::new(1.0, Color32::from_rgb(230, 190, 138));
    style.visuals.widgets.hovered.bg_stroke =
        egui::Stroke::new(2.0, Color32::from_rgb(255, 215, 0));
    style.visuals.widgets.active.bg_stroke = egui::Stroke::new(2.0, Color32::from_rgb(255, 215, 0));
    style.visuals.widgets.inactive.bg_stroke =
        egui::Stroke::new(1.0, Color32::from_rgb(230, 190, 138));
    style.visuals.widgets.noninteractive.bg_stroke =
        egui::Stroke::new(1.0, Color32::from_rgb(230, 190, 138));
    style.visuals.window_stroke = egui::Stroke::new(2.0, Color32::from_rgb(230, 190, 138));
    style.visuals.menu_rounding = 12.0.into();
    style.visuals.popup_shadow = egui::epaint::Shadow {
        offset: egui::vec2(0.0, 4.0),
        blur: 8.0,
        spread: 0.0,
        color: Color32::from_rgba_unmultiplied(0, 0, 0, 120),
    };
    style.visuals.text_cursor = egui::Stroke::new(2.0, Color32::from_rgb(255, 215, 0));
    style
}
