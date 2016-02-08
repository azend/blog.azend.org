---
layout: post
title:  "GitLab + Proxmox"
date:   2016-02-07 19:49:40
categories: server homelab
comments: true
---
Use Proxmox 4.0 they said. It would be easy they said. From what I've seen LXC is never simple. Let us begin...

In a Proxmox based LXC container, sysctl is read only. GitLab does not like this and will not configure without outside intervention. As a hack until a proper patch is created, one can simply comment out the line which tries to apply sysctl rules.

In `/opt/gitlab/embedded/cookbooks/gitlab/definitions/sysctl.rb`
{% highlight ruby %}
# Load the settings right away
execute "load sysctl conf" do
	#command "cat /etc/sysctl.conf /etc/sysctl.d/*.conf  | sysctl -e -p -"
	action :nothing
end
{% endhighlight %}

[https://gitlab.com/gitlab-org/omnibus-gitlab/issues/893](https://gitlab.com/gitlab-org/omnibus-gitlab/issues/893)

Now GitLab will configure and try to start up. When this happens, AppArmor on the Proxmox host repermissions the socket so that nginx can't talk to unicorn. To fix this, you can either fight with AppArmor or move the socket location to another place where it does not get repermissioned.

In `/etc/gitlab/gitlab.rb`:
{% highlight ruby %}
gitlab_git_http_server['listen_addr'] = '/tmp/gitlab-workhorse.socket'
{% endhighlight %}

Once you're done, `gitlab-ctl reconfigure` to make Chef move the socket location.

[https://github.com/gitlabhq/gitlabhq/issues/9936](https://github.com/gitlabhq/gitlabhq/issues/9936)

