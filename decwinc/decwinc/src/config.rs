use std::collections::HashMap;

use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct Config {
    pub filesystem: HashMap<String, FilesystemDecl>,
    pub registry: HashMap<String, RegistryDecl>,
    pub activationHooks: Vec<ActivationHookDecl>,
}

#[derive(Debug, Deserialize)]
pub enum Ensure {
    Absent,
    Present,
}

#[derive(Debug, Deserialize)]
pub struct FilesystemDecl {
    pub ensure: Ensure,
    pub name: String,
    pub text: Option<String>,
}

#[derive(Debug, Deserialize)]
pub enum RegistryValueType {
    Dword,
    Qword,
}

#[derive(Debug, Deserialize)]
pub struct RegistryDecl {
    pub ensure: Ensure,
    pub name: String,
    #[serde(rename = "type")]
    pub valueType: Option<RegistryValueType>,
    pub value: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct ActivationHookDecl {
    pub command: String,
    pub args: Vec<String>,
}
