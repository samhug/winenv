mod config;

use gumdrop::Options;
use std::path::Path;

use std::io::prelude::*;

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

    // Read the JSON contents of the file as an instance of `Config`.
    serde_json::from_reader(reader).map_err(|err| err.to_string())
}

fn instantiate_config(cfg: &config::Config) -> Result<(), String> {
    // println!("parsed config:\n{:#?}", cfg);

    for fs_decl in &cfg.filesystem {
        println!(
            "[filesystem_declaration] {:?} {:?}",
            &fs_decl.path, fs_decl.name
        );

        match fs_decl.ensure {
            config::Ensure::Absent => {
                unimplemented!();
            }
            config::Ensure::Present => {
                let mut path = std::path::PathBuf::from(&fs_decl.path);

                std::fs::create_dir_all(&path)
                    .map_err(|err| format!("unable to create parent directory: {}", err))?;

                path.push(&fs_decl.name);

                let mut file = std::fs::File::create(&path)
                    .map_err(|err| format!("unable to open file: {}", err))?;
                file.write_all(fs_decl.text.as_deref().unwrap().as_bytes())
                    .map_err(|err| format!("unable to write to file: {}", err))?;
            }
        }

        println!("SUCCESS");
    }

    // for reg_decl in &cfg.registry {
    //     println!("{:#?}", reg_decl);
    //     match reg_decl.ensure {
    //         config::Ensure::Absent => {
    //             unimplemented!();
    //         },
    //         config::Ensure::Present => {
    //             unimplemented!();
    //         },
    //     }
    // }

    for ah_decl in &cfg.activation_hooks {
        println!(
            "[activation_hook] {:?} {:?}",
            &ah_decl.command, &ah_decl.args
        );

        let output = std::process::Command::new(&ah_decl.command)
            .args(&ah_decl.args[..])
            .output()
            .expect("failed to execute process");

        if output.status.success() {
            println!("SUCCESS: {}", std::str::from_utf8(&output.stdout).unwrap());
        } else {
            eprintln!(
                "FAILURE: {}\n{}",
                std::str::from_utf8(&output.stdout).unwrap(),
                std::str::from_utf8(&output.stderr).unwrap()
            );
            return Err("activation_hook failed".to_string());
        }
    }

    // Err("unimplemented")
    Ok(())
}
