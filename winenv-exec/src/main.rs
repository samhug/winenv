mod config;

use gumdrop::Options;
use std::fs::{self, File};
use std::io::{stdin, BufReader, Read, Write};

#[derive(Debug, Options)]
struct MyOptions {
    #[options(help = "print help message")]
    help: bool,

    #[options(help = "read config from file instead of stdin")]
    config: Option<String>,
}

fn main() {
    let opts = MyOptions::parse_args_default_or_exit();

    let cfg = match opts.config {
        Some(path) => {
            let reader = File::open(&path)
                .map(|file| BufReader::new(file))
                .expect(&format!("unable to read config file ({})", path));
            parse_config(reader)
        }
        None => parse_config(stdin().lock()),
    }
    .unwrap_or_else(|err| {
        eprintln!("config error:\n{}", err);
        std::process::exit(1);
    });

    instantiate_config(&cfg).unwrap_or_else(|err| {
        eprintln!("instantiation error: {}", err);
        std::process::exit(1);
    });
}

// Read the JSON contents of a reader and return a an instance of Config.
fn parse_config(reader: impl Read) -> Result<config::Config, String> {
    serde_json::from_reader(reader).map_err(|err| err.to_string())
}

fn instantiate_config(cfg: &config::Config) -> Result<(), String> {

    // Instantiate filesystem declarations
    for fs_decl in &cfg.filesystem {
        println!(
            "[filesystem_declaration] path={:?}, filename={:?}",
            &fs_decl.path, fs_decl.name
        );

        match fs_decl.ensure {
            config::Ensure::Absent => {
                // TODO: support ensuring absence (deleting files)
                unimplemented!();
            }
            config::Ensure::Present => {
                let mut path = std::path::PathBuf::from(&fs_decl.path);

                fs::create_dir_all(&path)
                    .map_err(|err| format!("unable to create parent directory: {}", err))?;

                path.push(&fs_decl.name);

                let mut file =
                    File::create(&path).map_err(|err| format!("unable to open file: {}", err))?;
                file.write_all(fs_decl.text.as_deref().unwrap().as_bytes())
                    .map_err(|err| format!("unable to write to file: {}", err))?;
            }
        }

        println!("SUCCESS");
    }

    // Execute activation hooks
    for ah_decl in &cfg.activation_hooks {
        println!(
            "[activation_hook] {:?} {:?}",
            &ah_decl.command, &ah_decl.args
        );

        let status = std::process::Command::new(&ah_decl.command)
            .args(&ah_decl.args[..])
            .status()
            .expect("failed to execute process");

        if status.success() {
            println!("SUCCESS");
        } else {
            eprintln!(
                "FAILURE{}",
                status
                    .code()
                    .map(|c| format!(" - exit code {}", c))
                    .unwrap_or_default()
            );
            return Err("activation_hook failed".to_string());
        }
    }

    Ok(())
}
