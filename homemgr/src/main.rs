mod modules;

fn main() {

    let file1 = modules::file::File::new("file1");

    let modules: Vec<&dyn modules::Module> = vec![
        &file1,
    ];


    for module in modules {
        println!("[{}] Installing...", module.get_name());
        module.install();

        println!("[{}] Checking Install...", module.get_name());
        module.install_check();

        println!("[{}] Done", module.get_name());
    }

}
