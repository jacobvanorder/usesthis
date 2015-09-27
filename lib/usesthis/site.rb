module UsesThis
  class Site < Dimples::Site
    attr_accessor :hardware
    attr_accessor :software
    attr_accessor :inspired_links
    attr_accessor :personal_links

    def initialize(config = {})
      super

      @hardware = {}
      @software = {}

      @inspired_links = []
      @personal_links = []

      @output_paths[:wares] = File.join(@source_paths[:root], 'data', 'gear')
      @output_paths[:links] = File.join(@source_paths[:root], 'data', 'links')

      @post_class = UsesThis::Interview
    end

    def scan_files
      %w[hardware software].each do |type|
        Dir.glob(File.join(@output_paths[:wares], type, '*.yml')).each do |path|
          ware = UsesThis::Ware.new(path)
          self.send(type)[ware.slug] = ware
        end
      end

      %w[inspired personal].each do |type|
        Dir.glob(File.join(@output_paths[:links], type, '*.yml')).each do |path|
          self.send("#{type}_links") << UsesThis::Link.new(path)
        end
      end

      super
    end

    def generate_files
      super
      generate_stats
    end

    def generate_stats
      client = Redis.new
      @stats = {hardware: {all: {}}, software: {all: {}}}

      %w[hardware software].each do |type|
        type_key = "#{type}:all"
        year_keys = {}

        @posts.each do |post|
          year_key = "#{type}:#{post.year}"

          post.send(type).each_value do |item|
            [type_key, year_key].each do |key|
              client.zincrby(key, 1, item.slug)
            end
          end

          year_keys[post.year] ||= year_key
        end

        @stats[type.to_sym][:all] = client.zrevrange(type_key, 0, 9)

        year_keys.each do |year, year_key|
          @stats[type.to_sym][year.to_sym] = client.zrevrange(year_key, 0, 9)
        end
      end
    end
  end
end