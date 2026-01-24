//! Rules module - Audit rules and evaluation engine

pub mod engine;
pub mod results;
pub mod categories;
pub mod patterns;

pub use results::{Finding, Severity};
