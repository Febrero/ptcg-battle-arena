class GetBuildVersionControl < ApplicationService
  def call(build_version)
    @build_version = build_version

    {
      status: status,
      current_build: current_build_data,
      latest_build: latest_build_data
    }
  end

  private

  def scope
    @scope ||= StandaloneBuild.where(visibility: "public")
  end

  def latest_build
    builds = @scope.to_a
    builds_ordered = builds.sort_by { |build| Gem::Version.new(build.version) }
    @latest_build ||= builds_ordered.last
  end

  def current_build
    @current_build ||= scope.where(version: @build_version).first
  end

  def latest_build_data
    if latest_build
      {
        version: latest_build.version,
        notes: latest_build.notes
      }
    end
  end

  def current_build_data
    if current_build
      {
        version: current_build.version,
        notes: current_build.notes
      }
    end
  end

  def status
    if !current_build
      "not_found"
    elsif Gem::Version.new(current_build.version) == Gem::Version.new(latest_build.version)
      "latest"
    elsif Gem::Version.new(current_build.version) < Gem::Version.new(latest_build.version)
      if current_build.force_update
        "force_update"
      else
        "suggest_update"
      end
    end
  end
end
