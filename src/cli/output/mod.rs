//! Output formatting module for CLI

mod html;
mod json;
mod markdown;
mod sarif;
mod terminal;

pub use html::HtmlReport;
pub use json::JsonOutput;
pub use markdown::MarkdownReport;
pub use sarif::SarifOutput;
pub use terminal::TerminalOutput;

use crate::actions::plan::ActionPlan;
use crate::rules::results::AuditResults;
use anyhow::Result;

/// Trait for rendering plan output
pub trait OutputRenderer {
    fn render_plan(&self, results: &AuditResults, plan: &ActionPlan) -> Result<String>;
}

/// Trait for rendering report output
pub trait ReportRenderer {
    fn render_report(&self, results: &AuditResults) -> Result<String>;
}
