# Tales of a Kubernetes Newbie - Installing my first service

I absolutely love containers and containerisation technologies in general.  Whenever I get a chance I migrate apps to Docker and extol the virtues of them to anyone who will listen.

I've used them a lot for Development and CI but haven't had a chance to do much in an Ops setting (apart from single-container workloads here and there).  The obvious one to go for is Kubernetes, but I've never had a chance to actually use it to build something "real".

This is where the [DigitalOcean Kubernetes Challenge](https://www.digitalocean.com/community/pages/kubernetes-challenge) comes in!  An opportunity to learn about Kubernetes by getting my hands dirty?  Sign me up!  Which is exactly what I did :-).  And now, a couple of weeks later, I've got a real thing running in Kubernetes!  This was both fun and frustrating and I've learned a lot along the way.

## The goal

I went for the `Deploy an internal container registry` challenge, which involves setting up a Docker registtry on a K8s cluster.  This was one of their beginner challenges and sounded both well-defined and straight-forward for a first attempt.  Within this I chose to deploy [trow](https://trow.io/), simply because it had less pre-requisites to setup beforehand!

My ultimate goal however was to take this one step further and use an ingress controller and Lets Encrypt to make it publicly available.  This is partially because, at the time, I thought this was the only way to make a K8s service available to a browser (it isn't!).

## Getting Kubernetes up and running

This was by far the easiest bit.  Once I had my DigitalOcean account setup, I just went to `Kubernetes` on the left-hand pane and created a new cluster.  

While it was provisioning, I went through the setup instructions for the `doctl` and `kubectl` tools.  This made actually talking to my cluster super-easy - just run a couple of commands and suddenly everything "Just Works"!  This also meant that I could focus on the important part of getting my registry installed.

## Ingress

I intially wanted to use haproxy as my ingress controller, because I've used haproxy before and feel pretty comfortable with it.  I went ahead and succesfully installed it using helm... but then had no idea what to do next!  After trying and failing to find "haproxy ingress on K8s" documentation, I gave up and moved to nginx.  This appears to be a lot more common \ favoured and there was so much more beginner-level documentation available for me to pore over.

In terms of installation, DO provide a one-click installer on the admin panel for nginx.  This was useful but a bit too magical for me - I didn't understand what it actually did and didn't want to have to delve too far into K8s internals trying to find out.  So I followed the alternative [DO installation guide](https://kubernetes.github.io/ingress-nginx/deploy/#digital-ocean) given by the Kubernetes docs.  This was still fairly magical (in that it was a single-command install), but it felt a lot more transparent, since it was based on manifests.  I also suspect they essentially do the same thing.

## Adding a Loadbalancer

Another thing I knew I would need is some form of loadbalancer, so that all traffic came in from a single public IP.  I initially created this Loadbalancer manually in the DO console, but it never worked.  Even more strangely, other LB instances would just (seemingly) magically pop up from nowhere!

After some head-scratching and reading more docs (specifically [this section](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)), I found out that Loadbalancers can be magically created by specific cloud providers (like DO).  So, by following the ingress installation above, I get my Loadbalancer for free!

## LetsEncrypt

Next, I wanted to get the TLS certificate infrastructure up and running, so I can get LetsEncrypt certificates for trow.  After some searching, it quickly became clear that the weapon of choice is `cert-manager`.  Installing it via Helm was simple but it was a while until I was convinced it was actually working.

Luckily, the cert-mnager docs give details on how to [verify cert-manager is working](https://cert-manager.io/next-docs/installation/verify/).  Once I had done that, I was much happier!

## Installing Trow

Trow provide a "quick install", which gets a functioning trow deployed with a single command.  Unfrotunately I couldn't use this, because it only works on Docker-based hosts (and the DO nodes use Containerd).  There's a [GitHub issue](https://github.com/ContainerSolutions/trow/issues/78) open to support this going forwards.

Once again, I used Helm to complete a "standard install" of trow and, once again, it was pretty simple, especially after reading through their [Helm installation notes](https://github.com/ContainerSolutions/trow/blob/main/docs/HELM_INSTALL.md). One thing that did intially confuse me was the structure of the values file you can give Helm - I thought there may be some sort of template I had to follow to pass in the various details.  Once I had found an example (and seen how simple it actually is), it was easy enough.

## Trow availability

The standard install of Trow requires a working domain name and a valid TLS certificate.  The domain name was easy enough; now that I had a working Loadbalancer, I just added an A record pointing to the "External IP".

The certificate part was a lot harder though and, in fact, this is where I had the most difficulty.  No matter what I tried, it always gave me the "Fake Kubernetes" certificate.  Delving deeper into the cert-manager internals showed me the error messages, but they were pretty cryptic at best.  Once I had finally confirmed cert-manager was installed correctly, I turned my attention to trow, to see if my configuration values made sense.

This is where the problem ultimately lay, specifically in the networking setup.  Initially I set it to use the `Loadbalancer` type, because I thought that meant "use the existing loadbalancer for connectivity".  This is not the case; it actually means "give me a new loadbalancer".  Once again, I only questioned this after seeing multiple LBs pop up in the console.  After changing this to something more sensible (NodePort in my case), things started moving forwards and I was getting more useful errors.

The final thing that got it working was setting the ingress class to nginx, so it knew what it was listening too.  Suddenly, the certificate request was successful and I had a working LetsEncrypt certificate for my trow domain!  To say I was ecstatic undersells it somewhat!

## What I learned

**I <3 Helm** - Using Helm made things so much easier!  It Just Works and using values files to pass configuration is nice from an "Infrastructure as Code" point of view.

**Things are changing rapidly** - K8s tooling still appears to be in it's infancy and a lot of tools are changing rapidly.  There were a few instances where I found conflicting information for the same thing, which didn't help matters.

**Stick to the beaten track** - Starting off with haproxy was a bad way to begin - it just left me confused before I had even properly started.  It would have been better to start with the most common tools from the beginning and only branch out when comfortable.

**Read the Docs** - I ended up getting confused around the principles of Kubernetes itself, rather than how to use the various bits and pieces.  Whilst I have read about K8s generally, I should have reminded myself about the variois components before diving in head-first and getting lost.

**No, seriously, read the docs!** - This one feels so important it should be said twice!

**kubectl describe is your friend** - When things went wrong, `kubectl describe` was instrumental in understanding what was happening and seeing error messages. I found it a bit cumbersome initially, but I think I've got the hang of it.

## What I would do differently

**Use Terraform for the K8s setup** - I'm a big fan of Terraform and I wasn't aware there was a provider for DigitalOcean until I had finished building everything manually.  Given I had to rebuild the cluster a few times, this would have saved me some time!

**Take my time** - I tried to run before I could walk and ended up making some pretty glaring errors (like all the fun I had with loadbalancers).  Next time, before starting in earnest, I think I should remind myself about the various component types and plan what I need to get things up and running.

## Summary

Looking back, whilst it was frustrating at times, I really enjoyed the challenge and I feel I've gained some useful experience in something I've always wanted to use.  I'm by no means ready to run a cluster but I do feel more prepared to try some more things.  Something I would love to try is setting up on-demand GitLab runners in K8s; maybe I'll try that next.

Finally, I want to say thanks to DigitalOcean for running the challenge!
