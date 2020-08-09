use std::string::ToString;

use crate::modules::Module;

pub struct File {
    name: String,
}

impl File {
    pub fn new<T: ToString>(name: T) -> Self {
        File{
            name: name.to_string(),
        }
    }
}

impl Module for File {
    fn get_name(&self) -> &str {
        self.name.as_str()
    }

    fn install(&self) {

    }

    fn install_check(&self) {

    }

    fn uninstall(&self) {

    }
}
