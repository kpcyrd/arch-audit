use std::io::stdout;
use std::path::PathBuf;

use clap::CommandFactory;
use clap::{ArgAction, Args as ClapArgs, Parser, Subcommand, ValueEnum};
use clap_complete::{generate, Shell};

use lazy_static::lazy_static;
use strum_macros::{Display, EnumString, VariantNames};

#[derive(Parser, Debug)]
#[command(about="A utility like pkg-audit for Arch Linux.", author, version, long_about = None)]
pub struct Args {
    /// Show only vulnerable package names and their versions. Set twice to hide the versions as well.
    #[arg(long, short = 'q', action = ArgAction::Count)]
    pub quiet: u8,
    /// Prints packages that depend on vulnerable packages and are thus potentially vulnerable as well. Set twice to show ALL the packages that requires them.
    #[arg(long, short = 'r', action = ArgAction::Count)]
    pub recursive: u8,
    /// Show packages which are in the [testing] repos. See https://wiki.archlinux.org/index.php/Official_repositories#Testing_repositories
    #[arg(long = "show-testing", short = 't')]
    pub testing: bool,
    /// Show only packages that have already been fixed
    #[arg(long, short = 'u', long)]
    pub upgradable: bool,
    /// Bypass tty detection for colors
    #[arg(long, short = 'C', default_value = "auto")]
    pub color: Color,
    /// Set an alternate database location
    #[arg(long, short = 'b', default_value = "/var/lib/pacman")]
    pub dbpath: PathBuf,
    /// Specify a format to control the output. Placeholders are %n (pkgname), %c (CVEs), %v (fixed version), %t (type), %s (severity), and %r (required by, only when -r is also used).
    #[arg(long, short = 'f')]
    pub format: Option<String>,
    /// Print json output
    #[arg(long)]
    pub json: bool,
    /// Specify the URL or file path to the security tracker json data
    #[arg(long)]
    pub source: Option<String>,
    /// Send requests through a proxy
    #[arg(long)]
    pub proxy: Option<String>,
    /// Do not use a proxy even if one is configured
    #[arg(long)]
    pub no_proxy: bool,
    /// Specify how to sort the output
    #[arg(long, use_value_delimiter = true, default_value = &**SORT_BY_DEFAULT_VALUE)]
    pub sort: Vec<SortBy>,
    /// Print the CVE numbers.
    #[arg(long, short = 'c')]
    pub show_cve: bool,
    #[command(subcommand)]
    pub subcommand: Option<SubCommand>,
}

#[derive(Debug, Subcommand)]
pub enum SubCommand {
    /// Generate shell completions
    #[clap(name = "completions")]
    Completions(Completions),
}

#[derive(Debug, Clone, Display, EnumString, VariantNames, ValueEnum)]
#[strum(serialize_all = "lowercase")]
pub enum Color {
    Auto,
    Always,
    Never,
}

impl Default for Color {
    fn default() -> Self {
        Self::Auto
    }
}

#[derive(Debug, Clone, Display, EnumString, VariantNames, ValueEnum)]
#[strum(serialize_all = "snake_case")]
pub enum SortBy {
    Severity,
    Pkgname,
    Upgradable,
    Reverse,
}

lazy_static! {
    static ref SORT_BY_DEFAULT_VALUE: String = vec![SortBy::Severity, SortBy::Pkgname,]
        .iter()
        .map(|e| e.to_string())
        .collect::<Vec<String>>()
        .join(",");
}

#[derive(Debug, ClapArgs)]
pub struct Completions {
    pub shell: Shell,
}

pub fn gen_completions(completions: &Completions) {
    let mut cmd = Args::command();
    let bin_name = cmd.get_name().to_string();
    generate(completions.shell, &mut cmd, &bin_name, &mut stdout());
}
