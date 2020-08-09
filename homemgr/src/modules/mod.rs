pub mod file;

pub trait Module {
    fn get_name(&self) -> &str;
    fn install(&self);
    fn install_check(&self);
    fn uninstall(&self);
}