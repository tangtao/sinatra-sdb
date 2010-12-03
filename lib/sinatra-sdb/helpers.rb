Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each {|r| require r }

module SDB
  module Helpers

    protected

    def generate_secret
      abc = %{ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz}
      (1..40).map { abc[rand(abc.size),1] }.join
    end

    def generate_key
      abc = %{ABCDEF0123456789}
      (1..20).map { abc[rand(abc.size),1] }.join
    end

  end
end
