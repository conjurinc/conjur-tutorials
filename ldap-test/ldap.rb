policy "ldap-#{ENV['CONJUR_POLICY_VERSION']}" do

     josh = user "josh"
     kevin = user "kevin"


     devs = group "devs" do
          add_member josh
     end
     ops  = group "ops" do
          add_member kevin
     end

     layer = layer "tomcats" do
       add_member "use_host", devs
       add_member "use_host", ops
     end
end
