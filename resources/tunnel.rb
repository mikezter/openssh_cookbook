def initialize(*args)
  super
  @name = args.first
  @action = :create
  @user = 'tunnel'
  @key = '/root/.ssh/tunnel_id_rsa'
  @port = 22
end

actions :start, :stop

attribute :name, :kind_of => String, :name_attribute => true, :regex => /^\w$/
attribute :forwarding, :kind_of => String, :required => true
attribute :host, :kind_of => String, :required => true
attribute :key, :kind_of => String
attribute :user, :kind_of => String
attribute :port, :kind_of  => [String, Integer]