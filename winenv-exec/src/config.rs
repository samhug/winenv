use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Config {
    pub filesystem: Vec<FilesystemDecl>,
    pub activation_hooks: Vec<ActivationHookDecl>,
}

#[derive(Debug, Deserialize)]
pub enum Ensure {
    Absent,
    Present,
}

#[derive(Debug, Deserialize)]
pub struct FilesystemDecl {
    pub ensure: Ensure,
    pub path: String,
    pub name: String,
    pub text: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct ActivationHookDecl {
    pub command: String,
    pub args: Vec<String>,
}
