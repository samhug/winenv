mod config;

use gumdrop::Options;
use std::path::Path;

#[derive(Debug, Options)]
struct MyOptions {
    #[options(help = "print help message")]
    help: bool,

    #[options(help = "path to config to instantiate", required)]
    config: String,
}

fn main() {
    let opts = MyOptions::parse_args_default_or_exit();

    let config_path = Path::new(&opts.config);

    let cfg = parse_config(config_path).unwrap_or_else(|err| {
        eprintln!("config error: {}", err);
        std::process::exit(1);
    });

    instantiate_config(&cfg).unwrap_or_else(|err| {
        eprintln!("instantiation error: {}", err);
        std::process::exit(1);
    });
}

fn parse_config(path: &Path) -> Result<config::Config, String> {
    // Open the file in read-only mode with buffer.
    let file =
        std::fs::File::open(path).map_err(|err| format!("unable to open config file: {}", err))?;
    let reader = std::io::BufReader::new(file);

    use serde::Deserialize;

    // Read the JSON contents of the file as an instance of `Config`.
    serde_json::from_reader(reader).map_err(|err| err.to_string())
}

fn instantiate_config(cfg: &config::Config) -> Result<(), &str> {
    // println!("parsed config:\n{:#?}", cfg);

    for fs_decl in &cfg.filesystem {
        println!("{:#?}", fs_decl);
        match fs_decl.ensure {
            config::Ensure::Absent => {
                unimplemented!();
            },
            config::Ensure::Present => {
                unimplemented!();

                // let path = std::path::PathBuf::from(fs_decl.path);
                // path.push(fs_decl.name);
                
                // let mut file = File::create(&path)?;
                // file.write_all(fs_decl.text)?;
            },
        }
    }

    for reg_decl in &cfg.registry {
        println!("{:#?}", reg_decl);
        match reg_decl.ensure {
            config::Ensure::Absent => {
                unimplemented!();
            },
            config::Ensure::Present => {
                unimplemented!();
            },
        }
    }


    for ah_decl in &cfg.activationHooks {
        let output = std::process::Command::new(&ah_decl.command)
            .args(&ah_decl.args[..])
            .output()
            .expect("failed to execute process");

        println!("{}",  std::str::from_utf8(&output.stdout).unwrap());
        // println!("{:#?}", ah_decl);
    }

    // Err("unimplemented")
    Ok(())
}
