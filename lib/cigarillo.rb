module Cigarillo
  module Integration
    autoload :Checkout  , "cigarillo/integration/checkout"
    autoload :Runner    , "cigarillo/integration/runner"
    autoload :TimeNazi  , "cigarillo/integration/time_nazi"
    autoload :CiSetup   , "cigarillo/integration/ci_setup"
    autoload :YmSetup   , "cigarillo/integration/ym_setup"
    autoload :GithubPing, "cigarillo/integration/github_ping"
    autoload :ProgressLog, "cigarillo/integration/progress_log"
  end

  module Coordinator
    autoload :Igor, "cigarillo/coordinator/igor"
    autoload :Repo, "cigarillo/coordinator/repo"
    autoload :Build, "cigarillo/coordinator/build"
  end

  module Utils
    autoload :Repo,     "cigarillo/utils/repo"
    autoload :Progress, "cigarillo/utils/progress"
    autoload :LineProgress, "cigarillo/utils/line_progress"
    autoload :Db,       "cigarillo/utils/db"
  end

  def self.root
    @root ||= Pathname('../..').expand_path(__FILE__)
  end

  def self.workbench
    @workbench ||= (root+'workbench').tap {|b| b.mkpath}
  end
end
