#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby wrapper for the bash implementation placed next to this file.
# This keeps RuboCop happy while delegating real work to bash.

script_dir = File.expand_path(__dir__)
bash_script = File.join(script_dir, 'install-packages')

exec('bash', bash_script)
