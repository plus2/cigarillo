require 'core_ext/blank'
require 'core_ext/try'

module Cigarillo
  module Integration
    autoload :Checkout   , "cigarillo/integration/checkout"
    autoload :Runner     , "cigarillo/integration/runner"
    autoload :TimeNazi   , "cigarillo/integration/time_nazi"
    autoload :CiSetup    , "cigarillo/integration/ci_setup"
    autoload :YmSetup    , "cigarillo/integration/ym_setup"
    autoload :GithubPing , "cigarillo/integration/github_ping"
    autoload :ProgressLog, "cigarillo/integration/progress_log"
  end

  module Coordinator
    autoload :Igor            , "cigarillo/coordinator/igor"
    autoload :ProgressRecorder, "cigarillo/coordinator/progress_recorder"
    autoload :ResultRecorder  , "cigarillo/coordinator/result_recorder"
    autoload :SkipWipCommits  , "cigarillo/coordinator/skip_wip_commits"

    autoload :Repo            , "cigarillo/coordinator/repo"
    autoload :Build           , "cigarillo/coordinator/build"
    autoload :ExampleResult   , "cigarillo/coordinator/example_result"
  end

  module Utils
    autoload :Repo              , "cigarillo/utils/repo"
    autoload :Progress          , "cigarillo/utils/progress"
    autoload :LineProgress      , "cigarillo/utils/line_progress"
    autoload :Db                , "cigarillo/utils/db"
    autoload :Result            , "cigarillo/utils/result"
    autoload :ANSI              , "cigarillo/utils/ansi"
    autoload :Words             , "cigarillo/utils/words"
    autoload :StructuredProgress, "cigarillo/utils/structured_progress"
    autoload :CheckoutCleaner, "cigarillo/utils/checkout_cleaner"
  end

  module Ui
    autoload :App, "cigarillo/ui/app"
  end

  def self.root
    @root ||= Pathname('../..').expand_path(__FILE__)
  end

  def self.workbench
    @workbench ||= (root+'workbench').tap {|b| b.mkpath}
  end
end
