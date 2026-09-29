//! # {{project-name}}
//!
//! {{description}}
#![warn(missing_docs)]

/// Adds two numbers.
pub fn add(left: u64, right: u64) -> u64 {
  left + right
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn it_works() {
    assert_eq!(add(2, 2), 4);
  }
}
